import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class BookingScreen extends StatefulWidget {
  final Car car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _pickupTime;
  String _paymentMethod = 'credit_card';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _mobileMoneyProviderController = TextEditingController();
  final TextEditingController _mobileMoneyPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userService = Provider.of<UserService>(context, listen: false);
    final currentUser = userService.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _emailController.text = currentUser.email;
      _phoneController.text = currentUser.phone;
    }
  }

  double get _totalPrice {
    if (_startDate == null || _endDate == null) return 0.0;
    final days = _endDate!.difference(_startDate!).inDays;
    return days * widget.car.pricePerDay;
  }

  bool get _isPickupTimeValid {
    if (_pickupTime == null || _pickupTime!.isEmpty) return false;
    final regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(_pickupTime!)) return false;
    final parts = _pickupTime!.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    if (hour < 0 || hour > 23) return false;
    if (minute < 0 || minute > 59) return false;
    return true;
  }

  bool get _isFormValid {
    final basicInfoValid = _startDate != null &&
        _endDate != null &&
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _isPickupTimeValid;

    if (_paymentMethod == 'credit_card') {
      return basicInfoValid &&
          _cardNumberController.text.isNotEmpty &&
          _expiryDateController.text.isNotEmpty &&
          _cvvController.text.isNotEmpty;
    } else {
      return basicInfoValid &&
          _mobileMoneyProviderController.text.isNotEmpty &&
          _mobileMoneyPhoneController.text.isNotEmpty;
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectPickupTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _pickupTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }


  Future<void> _submitBooking() async {
    if (!_isFormValid) return;

    Map<String, dynamic> paymentDetails = {};
    if (_paymentMethod == 'credit_card') {
      paymentDetails = {
        'cardLast4': _cardNumberController.text.length > 4
            ? _cardNumberController.text.substring(_cardNumberController.text.length - 4)
            : _cardNumberController.text,
        'cardBrand': 'Visa',
      };
    } else {
      paymentDetails = {
        'provider': _mobileMoneyProviderController.text,
        'phoneNumber': _mobileMoneyPhoneController.text,
      };
    }

    final userService = Provider.of<UserService>(context, listen: false);
    try {
      final booking = Booking(
        userId: userService.currentUser?.id ?? '',
        userName: userService.currentUser?.name ?? '',
        userEmail: userService.currentUser?.email ?? '',
        userPhone: userService.currentUser?.phone ?? '',
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        carId: widget.car.id,
        carName: widget.car.fullName,
        carImage: widget.car.imagePath,
        startDate: _startDate!,
        endDate: _endDate!,
        pickupTime: _pickupTime,
        totalPrice: _totalPrice,
        status: 'pending',
        createdAt: DateTime.now(),
        paymentMethod: _paymentMethod,
        paymentDetails: paymentDetails,
      );

  final bookingService = Provider.of<BookingService>(context, listen: false);
  // Persist booking to Firestore as well as local list
  await bookingService.addBookingAndPersist(booking);

      // Show success dialog - booking submitted for staff review
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Submitted!'),
          content: Text(
            'Your booking request for ${widget.car.fullName} has been submitted successfully.\n\n'
            'Total: \$${_totalPrice.toStringAsFixed(2)}\n'
            'Dates: ${_startDate!.toString().split(' ')[0]} to ${_endDate!.toString().split(' ')[0]}\n'
            'Pickup Time: ${_pickupTime ?? 'Not specified'}\n'
            'Payment Method: ${_paymentMethod == 'credit_card' ? 'Credit Card' : 'Mobile Money'}\n\n'
            'Your booking is now awaiting staff approval. You will be notified once it\'s reviewed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close any open dialogs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process payment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Car'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor.withAlpha(13),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor.withAlpha(51)),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 300;
                          return isSmallScreen
                              ? Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        widget.car.imagePath,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: 120,
                                            color: Colors.grey[200],
                                            child: Icon(Icons.car_rental, color: Colors.grey, size: 48),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.car.fullName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '\$${widget.car.pricePerDay.toStringAsFixed(2)}/day',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        widget.car.imagePath,
                                        width: 80,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 80,
                                            height: 60,
                                            color: Colors.grey[200],
                                            child: Icon(Icons.car_rental, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.car.fullName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '\$${widget.car.pricePerDay.toStringAsFixed(2)}/day',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Select Dates',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 400;
                        return isSmallScreen
                            ? Column(
                                children: [
                                  GestureDetector(
                                    onTap: _selectStartDate,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Start Date',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _startDate == null
                                                ? 'Select date'
                                                : _startDate!.toString().split(' ')[0],
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: _startDate == null ? null : _selectEndDate,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _startDate == null ? Colors.grey[100] : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'End Date',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _endDate == null
                                                ? 'Select date'
                                                : _endDate!.toString().split(' ')[0],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _startDate == null ? Colors.grey[400] : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _selectStartDate,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Start Date',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              _startDate == null
                                                  ? 'Select date'
                                                  : _startDate!.toString().split(' ')[0],
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _startDate == null ? null : _selectEndDate,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: _startDate == null ? Colors.grey[100] : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'End Date',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              _endDate == null
                                                  ? 'Select date'
                                                  : _endDate!.toString().split(' ')[0],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: _startDate == null ? Colors.grey[400] : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Pickup Time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _selectPickupTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pickup Time',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _pickupTime ?? 'Select time',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 32),

                    if (_startDate != null && _endDate != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallScreen = constraints.maxWidth < 250;
                            return isSmallScreen
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Price:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${_totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Price:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '\$${_totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ),

                    const SizedBox(height: 24),

                    const Text(
                      'Payment Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.payment, size: 20, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 350;
                              return isSmallScreen
                                  ? Column(
                                      children: [
                                        ListTile(
                                          title: const Text('Credit Card'),
                                          leading: Radio<String>(
                                            value: 'credit_card',
                                            groupValue: _paymentMethod,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _paymentMethod = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text('Mobile Money'),
                                          leading: Radio<String>(
                                            value: 'mobile_money',
                                            groupValue: _paymentMethod,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _paymentMethod = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            title: const Text('Credit Card'),
                                            leading: Radio<String>(
                                              value: 'credit_card',
                                              groupValue: _paymentMethod,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _paymentMethod = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            title: const Text('Mobile Money'),
                                            leading: Radio<String>(
                                              value: 'mobile_money',
                                              groupValue: _paymentMethod,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _paymentMethod = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                            },
                          ),
                          const SizedBox(height: 12),

                          if (_paymentMethod == 'credit_card') ...[
                            TextField(
                              controller: _cardNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Card Number',
                                border: OutlineInputBorder(),
                                hintText: '1234 5678 9012 3456',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 19,
                              onChanged: (value) {
                                if (value.isNotEmpty && value.length % 5 == 0 && value[value.length - 1] != ' ') {
                                  final formatted = '${value.substring(0, value.length - 1)} ${value.substring(value.length - 1)}';
                                  _cardNumberController
                                    ..text = formatted
                                    ..selection = TextSelection.collapsed(offset: formatted.length);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen = constraints.maxWidth < 300;
                                return isSmallScreen
                                    ? Column(
                                        children: [
                                          TextField(
                                            controller: _expiryDateController,
                                            decoration: const InputDecoration(
                                              labelText: 'Expiry Date (MM/YY)',
                                              border: OutlineInputBorder(),
                                              hintText: 'MM/YY',
                                            ),
                                            keyboardType: TextInputType.number,
                                            maxLength: 5,
                                            onChanged: (value) {
                                              if (value.length == 2 && !value.contains('/')) {
                                                _expiryDateController
                                                  ..text = '$value/'
                                                  ..selection = TextSelection.collapsed(offset: 3);
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _cvvController,
                                            decoration: const InputDecoration(
                                              labelText: 'CVV',
                                              border: OutlineInputBorder(),
                                              hintText: '123',
                                            ),
                                            keyboardType: TextInputType.number,
                                            maxLength: 3,
                                            obscureText: true,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _expiryDateController,
                                              decoration: const InputDecoration(
                                                labelText: 'Expiry Date (MM/YY)',
                                                border: OutlineInputBorder(),
                                                hintText: 'MM/YY',
                                              ),
                                              keyboardType: TextInputType.number,
                                              maxLength: 5,
                                              onChanged: (value) {
                                                if (value.length == 2 && !value.contains('/')) {
                                                  _expiryDateController
                                                    ..text = '$value/'
                                                    ..selection = TextSelection.collapsed(offset: 3);
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextField(
                                              controller: _cvvController,
                                              decoration: const InputDecoration(
                                                labelText: 'CVV',
                                                border: OutlineInputBorder(),
                                                hintText: '123',
                                              ),
                                              keyboardType: TextInputType.number,
                                              maxLength: 3,
                                              obscureText: true,
                                            ),
                                          ),
                                        ],
                                      );
                              },
                            ),
                          ] else ...[
                            DropdownButtonFormField<String>(
                              value: _mobileMoneyProviderController.text.isEmpty ? null : _mobileMoneyProviderController.text,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Money Provider',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem(value: 'MTN Mobile Money', child: Text('MTN Mobile Money')),
                                DropdownMenuItem(value: 'Telecel Cash', child: Text('Telecel Cash')),
                                DropdownMenuItem(value: 'AirtelTigo Money', child: Text('AirtelTigo Money')),
                              ],
                              onChanged: (value) {
                                _mobileMoneyProviderController.text = value ?? '';
                              },
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _mobileMoneyPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                                hintText: '+233000000000',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Icon(Icons.lock, size: 16, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Payment secured with SSL encryption',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFormValid ? _submitBooking : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirm Booking',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
  }
}
