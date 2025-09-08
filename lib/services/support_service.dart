import 'package:flutter/foundation.dart';

class SupportRequest {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String subject;
  final String message;
  final String status; // 'open', 'pending', 'resolved'
  final String priority; // 'low', 'medium', 'high'
  final DateTime createdAt;
  final DateTime? updatedAt;

  SupportRequest({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.subject,
    required this.message,
    this.status = 'open',
    this.priority = 'medium',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SupportRequest copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? subject,
    String? message,
    String? status,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportRequest(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'subject': subject,
      'message': message,
      'status': status,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      id: json['id'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      subject: json['subject'],
      message: json['message'],
      status: json['status'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class SupportService extends ChangeNotifier {
  final List<SupportRequest> _supportRequests = [];

  List<SupportRequest> get supportRequests => List.unmodifiable(_supportRequests);

  List<SupportRequest> get openRequests =>
      _supportRequests.where((request) => request.status == 'open').toList();

  List<SupportRequest> get pendingRequests =>
      _supportRequests.where((request) => request.status == 'pending').toList();

  List<SupportRequest> get resolvedRequests =>
      _supportRequests.where((request) => request.status == 'resolved').toList();

  // Add a new support request
  void addSupportRequest(SupportRequest request) {
    _supportRequests.add(request);
    notifyListeners();
  }

  // Update support request status
  void updateRequestStatus(String requestId, String newStatus) {
    final index = _supportRequests.indexWhere((request) => request.id == requestId);
    if (index != -1) {
      _supportRequests[index] = _supportRequests[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Update support request priority
  void updateRequestPriority(String requestId, String newPriority) {
    final index = _supportRequests.indexWhere((request) => request.id == requestId);
    if (index != -1) {
      _supportRequests[index] = _supportRequests[index].copyWith(
        priority: newPriority,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Get support request by ID
  SupportRequest? getRequestById(String requestId) {
    try {
      return _supportRequests.firstWhere((request) => request.id == requestId);
    } catch (e) {
      return null;
    }
  }

  // Get requests by customer email
  List<SupportRequest> getRequestsByCustomer(String customerEmail) {
    return _supportRequests
        .where((request) => request.customerEmail == customerEmail)
        .toList();
  }

  // Load mock data for demo purposes
  void loadMockData() {
    if (_supportRequests.isEmpty) {
      final mockRequests = [
        SupportRequest(
          id: '001',
          customerName: 'John Doe',
          customerEmail: 'john.doe@gmail.com',
          customerPhone: '+233501234567',
          subject: 'Car not starting',
          message: 'The car I rented yesterday is not starting. The engine makes a clicking sound but won\'t turn over.',
          status: 'open',
          priority: 'high',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        SupportRequest(
          id: '002',
          customerName: 'Jane Smith',
          customerEmail: 'jane.smith@gmail.com',
          customerPhone: '+233507654321',
          subject: 'Late return inquiry',
          message: 'I returned the car 30 minutes late. Will there be any additional charges?',
          status: 'pending',
          priority: 'medium',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        SupportRequest(
          id: '003',
          customerName: 'Bob Johnson',
          customerEmail: 'bob.johnson@gmail.com',
          customerPhone: '+233549876543',
          subject: 'Navigation system not working',
          message: 'The GPS navigation system in the car is not responding to touch inputs.',
          status: 'resolved',
          priority: 'low',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      _supportRequests.addAll(mockRequests);
      notifyListeners();
    }
  }

  // Clear all requests (for testing)
  void clearAllRequests() {
    _supportRequests.clear();
    notifyListeners();
  }
}
