class Booking {
  final String id;
  final String carId;
  final String carName;
  final String carImage;
  final DateTime startDate;
  final DateTime endDate;
  final String? pickupTime;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;
  final Map<String, dynamic> paymentDetails;
  final bool isBeingTracked;
  final double? currentLatitude;
  final double? currentLongitude;

  // User information
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;

  // Staff/Admin action tracking
  final String? approvedBy;
  final String? rejectedBy;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

  Booking({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carImage,
    required this.startDate,
    required this.endDate,
    this.pickupTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.paymentMethod = 'credit_card',
    this.paymentDetails = const {},
    this.isBeingTracked = false,
    this.currentLatitude,
    this.currentLongitude,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    this.approvedBy,
    this.rejectedBy,
    this.approvedAt,
    this.rejectedAt,
  });

  int get durationInDays => endDate.difference(startDate).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'carName': carName,
      'carImage': carImage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'pickupTime': pickupTime,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'isBeingTracked': isBeingTracked,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'approvedBy': approvedBy,
      'rejectedBy': rejectedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      carId: map['carId'],
      carName: map['carName'],
      carImage: map['carImage'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      pickupTime: map['pickupTime'],
      totalPrice: map['totalPrice'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      paymentMethod: map['paymentMethod'] ?? 'credit_card',
      paymentDetails: Map<String, dynamic>.from(map['paymentDetails'] ?? {}),
      isBeingTracked: map['isBeingTracked'] ?? false,
      currentLatitude: map['currentLatitude']?.toDouble(),
      currentLongitude: map['currentLongitude']?.toDouble(),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      approvedBy: map['approvedBy'],
      rejectedBy: map['rejectedBy'],
      approvedAt: map['approvedAt'] != null
          ? DateTime.parse(map['approvedAt'])
          : null,
      rejectedAt: map['rejectedAt'] != null
          ? DateTime.parse(map['rejectedAt'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking &&
        other.id == id &&
        other.carId == carId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, carId, startDate, endDate);
  }

  Booking copyWith({
    String? id,
    String? carId,
    String? carName,
    String? carImage,
    DateTime? startDate,
    DateTime? endDate,
    String? pickupTime,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
    bool? isBeingTracked,
    double? currentLatitude,
    double? currentLongitude,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? approvedBy,
    String? rejectedBy,
    DateTime? approvedAt,
    DateTime? rejectedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      carName: carName ?? this.carName,
      carImage: carImage ?? this.carImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pickupTime: pickupTime ?? this.pickupTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      isBeingTracked: isBeingTracked ?? this.isBeingTracked,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
    );
  }
}
