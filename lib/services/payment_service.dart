import 'dart:async';
import 'package:uuid/uuid.dart';

class PaymentService {
  // Singleton pattern
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final Uuid _uuid = Uuid();

  /// Mock payment processing for credit card
  Future<bool> processCreditCardPayment({
    required int amountCents,
    required String currency,
    required String cardLast4,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    // For demo, always return success
    return true;
  }

  /// Mock payment processing for mobile money
  Future<bool> processMobileMoneyPayment({
    required int amountCents,
    required String currency,
    required String provider,
    required String phoneNumber,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    // For demo, always return success
    return true;
  }

  /// Generate a unique payment transaction ID
  String generateTransactionId() {
    return _uuid.v4();
  }
}
