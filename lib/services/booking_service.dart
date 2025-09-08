import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import '../services/location_service.dart';
import '../services/payment_service.dart';
import '../services/user_service.dart';
import '../services/car_service_optimized.dart';
import '../utils/logger.dart';

class BookingService with ChangeNotifier {
  // Removed unused _firebaseMessaging
  /// Notification stub (expand for email/push)
  /// Auto-assign staff/admin and send notification (stub)
  void _autoAssignAndNotify(String bookingId, String status) async {
    // Example: assign to first available staff/admin
    // You can expand this logic for load balancing, etc.
    final userService = UserService();
    String? assignedUserEmail;
    if (status == 'confirmed' || status == 'payment_approved') {
      final staffList = userService.staff;
      if (staffList.isNotEmpty) {
        assignedUserEmail = staffList.first.email;
      }
    } else {
      final adminList = userService.admins;
      if (adminList.isNotEmpty) {
        assignedUserEmail = adminList.first.email;
      }
    }
    // Update Firestore with assignment
    if (assignedUserEmail != null) {
      await _firestore.collection('bookings').doc(bookingId).update({
        'assignedTo': assignedUserEmail,
      });
    }
    // Notification is now handled by a Firebase Cloud Function.
    // When booking status changes, Firestore is updated and the function sends a push notification.
    // See cloud/functions/sendBookingNotification.js for implementation.
    AppLogger.info(
      'Booking $bookingId status changed to $status. Notification will be sent by backend.',
    );

    /// Notification stub (expand for email/push)

    /// Stub: Lookup device token for user email (replace with real implementation)
  }

  /// Stream bookings from Firestore for real-time updates
  Stream<List<Booking>> getBookingsStream() {
    return _firestore.collection('bookings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Booking(
          id: data['id'],
          carId: data['carId'],
          carName: data['carName'],
          carImage: data['carImage'],
          startDate: DateTime.parse(data['startDate']),
          endDate: DateTime.parse(data['endDate']),
          pickupTime: data['pickupTime'],
          totalPrice: (data['totalPrice'] is int)
              ? (data['totalPrice'] as int).toDouble()
              : data['totalPrice'],
          status: data['status'],
          createdAt: DateTime.parse(data['createdAt']),
          paymentMethod: data['paymentMethod'] ?? 'credit_card',
          paymentDetails: Map<String, dynamic>.from(
            data['paymentDetails'] ?? {},
          ),
          isBeingTracked: data['isBeingTracked'] ?? false,
          currentLatitude: data['currentLatitude'] != null
              ? (data['currentLatitude'] as num).toDouble()
              : null,
          currentLongitude: data['currentLongitude'] != null
              ? (data['currentLongitude'] as num).toDouble()
              : null,
          userId: data['userId'],
          userName: data['userName'],
          userEmail: data['userEmail'],
          userPhone: data['userPhone'],
          approvedBy: data['approvedBy'],
          rejectedBy: data['rejectedBy'],
          approvedAt: data['approvedAt'] != null
              ? DateTime.parse(data['approvedAt'])
              : null,
          rejectedAt: data['rejectedAt'] != null
              ? DateTime.parse(data['rejectedAt'])
              : null,
        );
      }).toList();
    });
  }

  final List<Booking> _bookings = [];
  final LocationService _locationService = LocationService();
  final Map<String, StreamSubscription<Position>> _trackingSubscriptions = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CarServiceOptimized? _carService;

  BookingService() {
    AppLogger.info('BookingService constructor called');
    // Defer heavy initialization to avoid blocking the main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeService();
    });
  }

  Future<void> _initializeService() async {
    try {
      await loadBookingsFromFirestore();
      AppLogger.info('BookingService initialized successfully');
    } catch (e, st) {
      AppLogger.error('Error initializing BookingService: $e', e, st);
    }
  }

  List<Booking> get bookings => _bookings;

  List<Booking> get trackedBookings {
    return _bookings.where((booking) => booking.isBeingTracked).toList();
  }

  set carService(CarServiceOptimized service) {
    _carService = service;
  }

  Future<bool> initiatePaymentForBooking(Booking booking) async {
    final paymentService = PaymentService();

    // Convert total price to cents
    final amountCents = (booking.totalPrice * 100).toInt();
    final currency = 'usd'; // You can make this dynamic if needed

    bool paymentSuccess = false;

    if (booking.paymentMethod == 'credit_card') {
      final cardLast4 = booking.paymentDetails['cardLast4'] ?? '';
      paymentSuccess = await paymentService.processCreditCardPayment(
        amountCents: amountCents,
        currency: currency,
        cardLast4: cardLast4,
      );
    } else if (booking.paymentMethod == 'mobile_money') {
      final provider = booking.paymentDetails['provider'] ?? '';
      final phoneNumber = booking.paymentDetails['phoneNumber'] ?? '';
      paymentSuccess = await paymentService.processMobileMoneyPayment(
        amountCents: amountCents,
        currency: currency,
        provider: provider,
        phoneNumber: phoneNumber,
      );
    }

    if (paymentSuccess) {
      // Update booking status to payment_approved
      final index = _bookings.indexWhere((b) => b.id == booking.id);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: 'payment_approved',
        );
        notifyListeners();
      }
    }

    return paymentSuccess;
  }

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  /// Add booking and persist to Firestore
  Future<void> addBookingAndPersist(Booking booking) async {
    addBooking(booking);
    try {
      final docRef = _firestore.collection('bookings').doc(booking.id);
      await docRef.set(booking.toMap());
      AppLogger.info('Booking saved to Firestore: ${booking.id}');
    } catch (e, st) {
      AppLogger.error('Failed to save booking to Firestore: $e', e, st);
      print('Failed to save booking to Firestore: $e');
      print(st);
    }
  }

  void cancelBooking(String bookingId) {
    _autoAssignAndNotify(bookingId, 'cancelled');
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: 'cancelled');
      notifyListeners();
      // Update Firestore
      _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
    }
  }

  void rejectBooking(String bookingId, String staffName) {
    _autoAssignAndNotify(bookingId, 'rejected');
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: 'rejected',
        rejectedBy: staffName,
        rejectedAt: DateTime.now(),
      );
      notifyListeners();
      // Update Firestore
      _firestore.collection('bookings').doc(bookingId).update({
        'status': 'rejected',
        'rejectedBy': staffName,
        'rejectedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  void confirmBooking(String bookingId, String staffName) {
    _autoAssignAndNotify(bookingId, 'confirmed');
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: 'confirmed',
        approvedBy: staffName,
        approvedAt: DateTime.now(),
      );

      // Update car availability immediately
      _carService?.updateCarAvailabilityForBooking(_bookings[index].carId);

      notifyListeners();
      // Update Firestore
      _firestore.collection('bookings').doc(bookingId).update({
        'status': 'confirmed',
        'approvedBy': staffName,
        'approvedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  void approvePayment(String bookingId) {
    _autoAssignAndNotify(bookingId, 'payment_approved');
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: 'payment_approved');

      // Update car availability immediately
      _carService?.updateCarAvailabilityForBooking(_bookings[index].carId);

      notifyListeners();
      // Update Firestore
      _firestore.collection('bookings').doc(bookingId).update({
        'status': 'payment_approved',
      });
    }
  }

  Future<void> startTrackingCar(String bookingId) async {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      // Request location permission
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        throw Exception(
          'Location permission is required for car tracking. Please enable location services in your device settings.',
        );
      }

      // Start tracking
      _trackingSubscriptions[bookingId] = _locationService
          .getPositionStream()
          .listen(
            (position) {
              final bookingIndex = _bookings.indexWhere(
                (b) => b.id == bookingId,
              );
              if (bookingIndex != -1) {
                _bookings[bookingIndex] = _bookings[bookingIndex].copyWith(
                  isBeingTracked: true,
                  currentLatitude: position.latitude,
                  currentLongitude: position.longitude,
                );
                notifyListeners();
              }
            },
            onError: (error) {
              print('GPS tracking error for booking $bookingId: $error');
            },
          );

      _bookings[index] = _bookings[index].copyWith(isBeingTracked: true);
      notifyListeners();
    }
  }

  void stopTrackingCar(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      _trackingSubscriptions[bookingId]?.cancel();
      _trackingSubscriptions.remove(bookingId);
      _bookings[index] = _bookings[index].copyWith(
        isBeingTracked: false,
        currentLatitude: null,
        currentLongitude: null,
      );
      notifyListeners();
    }
  }

  void stopAllTracking() {
    _trackingSubscriptions.forEach((bookingId, subscription) {
      subscription.cancel();
    });
    _trackingSubscriptions.clear();
    for (var i = 0; i < _bookings.length; i++) {
      if (_bookings[i].isBeingTracked) {
        _bookings[i] = _bookings[i].copyWith(
          isBeingTracked: false,
          currentLatitude: null,
          currentLongitude: null,
        );
      }
    }
    notifyListeners();
  }

  List<Booking> getUserBookings() {
    return _bookings;
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isCarAvailable(
    String carId,
    DateTime startDate,
    DateTime endDate, {
    String? pickupTime,
  }) {
    // Check if the requested dates overlap with any existing bookings for this car
    for (var booking in _bookings) {
      // Skip cancelled and rejected bookings
      if (booking.status == 'cancelled' || booking.status == 'rejected') {
        continue;
      }

      // Check if this booking is for the same car
      if (booking.carId == carId) {
        // Check for date overlap
        bool hasDateOverlap =
            (startDate.isBefore(booking.endDate) ||
                startDate.isAtSameMomentAs(booking.endDate)) &&
            (endDate.isAfter(booking.startDate) ||
                endDate.isAtSameMomentAs(booking.startDate));

        if (hasDateOverlap) {
          // If pickup times are specified for both bookings, check for time conflict
          if (pickupTime != null && booking.pickupTime != null) {
            // Check if both bookings are on the same day and have the same pickup time
            bool sameDay =
                startDate.year == booking.startDate.year &&
                startDate.month == booking.startDate.month &&
                startDate.day == booking.startDate.day;

            if (sameDay && pickupTime == booking.pickupTime) {
              return false; // Car is not available due to pickup time conflict
            }
          } else {
            // If no pickup time specified or existing booking has no pickup time, treat as conflict
            return false; // Car is not available due to booking conflict
          }
        }
      }
    }
    return true; // Car is available for the requested dates and time
  }

  bool hasActiveBooking(String carId) {
    // Check if there are any active (approved/confirmed) bookings for this car
    for (var booking in _bookings) {
      if (booking.carId == carId &&
          (booking.status == 'confirmed' ||
              booking.status == 'payment_approved' ||
              booking.status == 'approved')) {
        return true;
      }
    }
    return false;
  }

  void clearAllBookings() {
    stopAllTracking();
    _bookings.clear();
    notifyListeners();
  }

  /// Load bookings from Firestore
  Future<void> loadBookingsFromFirestore() async {
    try {
      final querySnapshot = await _firestore.collection('bookings').get();
      final bookings = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Booking(
          id: data['id'],
          carId: data['carId'],
          carName: data['carName'],
          carImage: data['carImage'],
          startDate: DateTime.parse(data['startDate']),
          endDate: DateTime.parse(data['endDate']),
          pickupTime: data['pickupTime'],
          totalPrice: (data['totalPrice'] is int)
              ? (data['totalPrice'] as int).toDouble()
              : data['totalPrice'],
          status: data['status'],
          createdAt: DateTime.parse(data['createdAt']),
          paymentMethod: data['paymentMethod'] ?? 'credit_card',
          paymentDetails: Map<String, dynamic>.from(
            data['paymentDetails'] ?? {},
          ),
          isBeingTracked: data['isBeingTracked'] ?? false,
          currentLatitude: data['currentLatitude'] != null
              ? (data['currentLatitude'] as num).toDouble()
              : null,
          currentLongitude: data['currentLongitude'] != null
              ? (data['currentLongitude'] as num).toDouble()
              : null,
          userId: data['userId'],
          userName: data['userName'],
          userEmail: data['userEmail'],
          userPhone: data['userPhone'],
          approvedBy: data['approvedBy'],
          rejectedBy: data['rejectedBy'],
          approvedAt: data['approvedAt'] != null
              ? DateTime.parse(data['approvedAt'])
              : null,
          rejectedAt: data['rejectedAt'] != null
              ? DateTime.parse(data['rejectedAt'])
              : null,
        );
      }).toList();

      _bookings.clear();
      _bookings.addAll(bookings);
      notifyListeners();
      AppLogger.info('Loaded ${bookings.length} bookings from Firestore');
    } catch (e, st) {
      AppLogger.error('Failed to load bookings from Firestore: $e', e, st);
      print('Failed to load bookings from Firestore: $e');
    }
  }
}
