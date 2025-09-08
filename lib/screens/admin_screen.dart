import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/booking_service.dart';
import '../services/user_service.dart';
import '../services/car_service_optimized.dart';
import '../models/booking.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'map_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // System configuration state
  bool _notificationsEnabled = true;
  bool _maintenanceMode = false;
  bool _twoFactorAuth = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);

    // Load mock data after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);
      // bookingService.loadMockBookings(); // Removed automatic loading of mock bookings
      userService.loadMockUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showAddCarDialog(BuildContext context, CarServiceOptimized carService) {
    final _formKey = GlobalKey<FormState>();
    final _brandController = TextEditingController();
    final _modelController = TextEditingController();
    final _yearController = TextEditingController();
    final _priceController = TextEditingController();
    final _seatsController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _imagePathController = TextEditingController();

    String _selectedTransmission = 'Automatic';
    String _selectedFuelType = 'Gasoline';
    String _selectedCategory = 'Sedan';
    bool _available = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Vehicle'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: 'Brand',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter brand';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: 'Model',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter model';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter year';
                          }
                          final year = int.tryParse(value);
                          if (year == null ||
                              year < 1900 ||
                              year > DateTime.now().year + 1) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imagePathController,
                        decoration: const InputDecoration(
                          labelText: 'Image Path',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., assets/car_image.png',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter image path';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price per Day (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedTransmission,
                        decoration: const InputDecoration(
                          labelText: 'Transmission',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Automatic',
                            child: Text('Automatic'),
                          ),
                          DropdownMenuItem(
                            value: 'Manual',
                            child: Text('Manual'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTransmission = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedFuelType,
                        decoration: const InputDecoration(
                          labelText: 'Fuel Type',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Gasoline',
                            child: Text('Gasoline'),
                          ),
                          DropdownMenuItem(
                            value: 'Diesel',
                            child: Text('Diesel'),
                          ),
                          DropdownMenuItem(
                            value: 'Electric',
                            child: Text('Electric'),
                          ),
                          DropdownMenuItem(
                            value: 'Hybrid',
                            child: Text('Hybrid'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFuelType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _seatsController,
                        decoration: const InputDecoration(
                          labelText: 'Number of Seats',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of seats';
                          }
                          final seats = int.tryParse(value);
                          if (seats == null || seats < 1 || seats > 20) {
                            return 'Please enter a valid number of seats (1-20)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Sedan',
                            child: Text('Sedan'),
                          ),
                          DropdownMenuItem(value: 'SUV', child: Text('SUV')),
                          DropdownMenuItem(
                            value: 'Hatchback',
                            child: Text('Hatchback'),
                          ),
                          DropdownMenuItem(
                            value: 'Sports',
                            child: Text('Sports'),
                          ),
                          DropdownMenuItem(
                            value: 'Supercar',
                            child: Text('Supercar'),
                          ),
                          DropdownMenuItem(
                            value: 'Luxury',
                            child: Text('Luxury'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Available'),
                        subtitle: const Text(
                          'Make this vehicle available for booking',
                        ),
                        value: _available,
                        onChanged: (value) {
                          setState(() {
                            _available = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final success = await carService.addCar(
                          brand: _brandController.text,
                          model: _modelController.text,
                          year: int.parse(_yearController.text),
                          imagePath: _imagePathController.text,
                          pricePerDay: double.parse(_priceController.text),
                          transmission: _selectedTransmission,
                          fuelType: _selectedFuelType,
                          seats: int.parse(_seatsController.text),
                          category: _selectedCategory,
                          description: _descriptionController.text,
                          available: _available,
                        );

                        if (success) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${_brandController.text} ${_modelController.text} added successfully!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to add vehicle. Please try again.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error adding vehicle: ${e.toString().replaceFirst('Exception: ', '')}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Add Vehicle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context, UserService userService) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _passwordController = TextEditingController();
    final _idNumberController = TextEditingController();
    String _selectedUserType = 'customer';
    String? _selectedIdType;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New User'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedUserType,
                        decoration: const InputDecoration(
                          labelText: 'User Type',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'customer',
                            child: Text('Customer'),
                          ),
                          DropdownMenuItem(
                            value: 'staff',
                            child: Text('Staff'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedUserType = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a user type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        value: _selectedIdType,
                        decoration: const InputDecoration(
                          labelText: 'ID Type (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text('None')),
                          DropdownMenuItem(
                            value: 'ghana_card',
                            child: Text('Ghana Card'),
                          ),
                          DropdownMenuItem(
                            value: 'driver_license',
                            child: Text('Driver License'),
                          ),
                          DropdownMenuItem(
                            value: 'voter_id',
                            child: Text('Voter ID'),
                          ),
                          DropdownMenuItem(
                            value: 'passport',
                            child: Text('Passport'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedIdType = value;
                          });
                        },
                      ),
                      if (_selectedIdType != null) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _idNumberController,
                          decoration: const InputDecoration(
                            labelText: 'ID Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_selectedIdType != null &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter ID number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await userService.registerUser(
                          name: _nameController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                          password: _passwordController.text,
                          userType: _selectedUserType,
                          idNumber: _idNumberController.text.isNotEmpty
                              ? _idNumberController.text
                              : null,
                          idType: _selectedIdType,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'User ${_nameController.text} created successfully!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error creating user: ${e.toString().replaceFirst('Exception: ', '')}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Create User'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'payment_approved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'admin':
        return Colors.orange;
      case 'staff':
        return Colors.purple;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAdminBookingCard(
    Booking booking,
    BookingService bookingService,
    UserService userService,
  ) {
    final user = userService.getUserById(booking.userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced User Information Section
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  backgroundImage: user?.profileImage != null
                      ? NetworkImage(user!.profileImage!) as ImageProvider
                      : null,
                  child: user?.profileImage == null
                      ? Icon(Icons.person, color: Colors.blue[800], size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            booking.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getUserTypeColor(user.userType),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.userType.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        booking.userEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        booking.userPhone,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      if (user?.address != null && user!.address!.isNotEmpty)
                        Text(
                          user.address!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (user != null)
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                user.isActive ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: user.isActive
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              backgroundColor: user.isActive
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Chip(
                              label: Text(
                                user.registrationStatus.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: user.registrationStatus == 'approved'
                                      ? Colors.green
                                      : user.registrationStatus == 'pending'
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                              ),
                              backgroundColor:
                                  user.registrationStatus == 'approved'
                                  ? Colors.green[50]
                                  : user.registrationStatus == 'pending'
                                  ? Colors.orange[50]
                                  : Colors.red[50],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Car Information Section
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    booking.carImage,
                    width: 60,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 40,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.car_rental,
                          size: 20,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.carName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${booking.totalPrice.toStringAsFixed(2)} • ${booking.durationInDays} days',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Dates: ${booking.startDate.toString().split(' ')[0]} to ${booking.endDate.toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Booked on: ${booking.createdAt.toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (booking.approvedBy != null)
              Text(
                'Approved by: ${booking.approvedBy}',
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            if (booking.rejectedBy != null)
              Text(
                'Rejected by: ${booking.rejectedBy}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            if (booking.approvedAt != null)
              Text(
                'Approved on: ${booking.approvedAt!.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (booking.rejectedAt != null)
              Text(
                'Rejected on: ${booking.rejectedAt!.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (booking.status == 'pending')
                  ElevatedButton(
                    onPressed: () =>
                        bookingService.confirmBooking(booking.id, 'Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm Booking'),
                  ),
                if (booking.status == 'payment_approved')
                  ElevatedButton(
                    onPressed: () =>
                        bookingService.confirmBooking(booking.id, 'Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm Booking'),
                  ),
                if (booking.status == 'confirmed')
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            bookingService.cancelBooking(booking.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final currentContext = context;
                          try {
                            await bookingService.startTrackingCar(booking.id);
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'GPS tracking started for ${booking.carName}',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to start tracking: ${e.toString().replaceFirst('Exception: ', 'Please enable location services. ')}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Start Tracking'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    User user,
    UserService userService,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete user ${user.name} (${user.email})? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  userService.deleteUser(user.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'User ${user.name} deleted successfully!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error deleting user: ${e.toString().replaceFirst('Exception: ', '')}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(User user, UserService userService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, color: Colors.blue[800]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        user.phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(user.userType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.userType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    user.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  backgroundColor: user.isActive
                      ? Colors.green[50]
                      : Colors.red[50],
                ),
                const SizedBox(width: 8),
                Text(
                  'Joined: ${user.createdAt.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, user, userService),
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSTrackingTab(
    BookingService bookingService,
    CarServiceOptimized carService,
  ) {
    final activeBookings = bookingService.bookings
        .where((booking) => booking.status == 'confirmed')
        .toList();

    final totalCars = carService.getAllCars().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Active Bookings',
                activeBookings.length.toString(),
                Colors.blue,
              ),
              _buildStatCard('Total Cars', totalCars.toString(), Colors.grey),
              _buildStatCard(
                'Available',
                (totalCars - activeBookings.length).toString(),
                Colors.green,
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Live Vehicle Tracking - Active Bookings Only',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: activeBookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No active bookings',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'GPS tracking will show here when cars are booked',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      height: 300,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 64, color: Colors.blue),
                            const SizedBox(height: 16),
                            Text(
                              '${activeBookings.length} Active Vehicles',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tracking ${activeBookings.length} booked vehicles',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Vehicles: ${activeBookings.map((b) => b.carName).join(', ')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.map),
                      label: const Text('Open Full Map View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Active Bookings: ${activeBookings.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab(
    BookingService bookingService,
    UserService userService,
    List<Booking> bookings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total Bookings',
                bookings.length.toString(),
                Colors.blue,
              ),
              _buildStatCard(
                'Confirmed',
                bookings
                    .where((b) => b.status == 'confirmed')
                    .length
                    .toString(),
                Colors.green,
              ),
              _buildStatCard(
                'Cancelled',
                bookings
                    .where((b) => b.status == 'cancelled')
                    .length
                    .toString(),
                Colors.red,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'All Bookings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No bookings yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : StreamBuilder(
                  stream: bookingService.getBookingsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No bookings found'));
                    }
                    final bookings = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return _buildAdminBookingCard(
                          booking,
                          bookingService,
                          userService,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(UserService userService, List<User> users) {
    String searchQuery = '';
    List<User> displayedUsers = users;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total Users',
                      userService.totalUsers.toString(),
                      Colors.purple,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Active',
                      userService.activeUsersCount.toString(),
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Customers',
                      userService.customersCount.toString(),
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Admins',
                      userService.adminsCount.toString(),
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Staff',
                      userService.staffCount.toString(),
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText:
                            'Search users by name, email, phone, or type...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          if (value.isEmpty) {
                            displayedUsers = users;
                          } else {
                            displayedUsers = userService.searchUsers(value);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      userService.loadMockUsers();
                      setState(() {
                        searchQuery = '';
                        displayedUsers = users;
                      });
                    },
                    tooltip: 'Refresh Users',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddUserDialog(context, userService);
                    },
                    icon: Icon(Icons.person_add),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'All Users',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: displayedUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            searchQuery.isEmpty ? Icons.people : Icons.search,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? 'No users found'
                                : 'No users match "$searchQuery"',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayedUsers.length,
                      itemBuilder: (context, index) {
                        final user = displayedUsers[index];
                        return _buildUserCard(user, userService);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportsTab(
    BookingService bookingService,
    UserService userService,
  ) {
    final bookings = bookingService.bookings;
    final users = userService.users;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Reports & Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Revenue',
                  '\$${bookings.where((b) => b.status == 'confirmed').fold(0.0, (sum, b) => sum + b.totalPrice).toStringAsFixed(0)}',
                  Colors.green,
                ),
                _buildStatCard(
                  'Active Users',
                  users.where((u) => u.isActive).length.toString(),
                  Colors.blue,
                ),
                _buildStatCard(
                  'Pending Bookings',
                  bookings
                      .where((b) => b.status == 'pending')
                      .length
                      .toString(),
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Status Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Confirmed',
                        bookings
                            .where((b) => b.status == 'confirmed')
                            .length
                            .toString(),
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Pending',
                        bookings
                            .where((b) => b.status == 'pending')
                            .length
                            .toString(),
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Cancelled',
                        bookings
                            .where((b) => b.status == 'cancelled')
                            .length
                            .toString(),
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Registration Trends',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Customers',
                        users
                            .where((u) => u.userType == 'customer')
                            .length
                            .toString(),
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Staff',
                        users
                            .where((u) => u.userType == 'staff')
                            .length
                            .toString(),
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Admins',
                        users
                            .where((u) => u.userType == 'admin')
                            .length
                            .toString(),
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemConfigTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'System Configuration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Application Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Send push notifications to users'),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Notifications ${value ? 'enabled' : 'disabled'}',
                            ),
                            backgroundColor: value
                                ? Colors.green
                                : Colors.orange,
                          ),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Maintenance Mode'),
                    subtitle: const Text('Put the system in maintenance mode'),
                    trailing: Switch(
                      value: _maintenanceMode,
                      onChanged: (value) {
                        setState(() {
                          _maintenanceMode = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Maintenance mode ${value ? 'enabled' : 'disabled'}',
                            ),
                            backgroundColor: value
                                ? Colors.orange
                                : Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Two-Factor Authentication'),
                    subtitle: const Text('Require 2FA for admin accounts'),
                    trailing: Switch(
                      value: _twoFactorAuth,
                      onChanged: (value) {
                        setState(() {
                          _twoFactorAuth = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Two-Factor Authentication ${value ? 'enabled' : 'disabled'}',
                            ),
                            backgroundColor: value
                                ? Colors.green
                                : Colors.orange,
                          ),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Session Timeout'),
                    subtitle: const Text(
                      'Auto logout after inactivity (minutes)',
                    ),
                    trailing: const Text('30'),
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Database Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement backup functionality
                    },
                    icon: Icon(Icons.backup),
                    label: const Text('Create Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement restore functionality
                    },
                    icon: Icon(Icons.restore),
                    label: const Text('Restore from Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessAnalyticsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Business Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Analytics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Revenue trends and projections will be displayed here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Revenue Chart Placeholder'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Insights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Customer behavior and preferences analysis.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Customer Insights Chart Placeholder'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Metrics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Key performance indicators and business metrics.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Performance Metrics Chart Placeholder'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetManagementTab(CarServiceOptimized carService) {
    final allCars = carService.getAllCars();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Fleet Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Cars',
                  allCars.length.toString(),
                  Colors.blue,
                ),
                _buildStatCard(
                  'Available',
                  allCars.where((c) => c.available).length.toString(),
                  Colors.green,
                ),
                _buildStatCard(
                  'In Use',
                  allCars.where((c) => !c.available).length.toString(),
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fleet Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Manage your vehicle fleet, maintenance schedules, and availability.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddCarDialog(context, carService);
                    },
                    icon: Icon(Icons.add),
                    label: const Text('Add New Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maintenance Schedule',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Track and schedule vehicle maintenance.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Maintenance Schedule Placeholder'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Current status of all vehicles in the fleet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Vehicle Status List Placeholder'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = Provider.of<BookingService>(context);
    final userService = Provider.of<UserService>(context);
    final carService = Provider.of<CarServiceOptimized>(context);
    final bookings = bookingService.bookings;
    final users = userService.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.calendar_today), text: 'Bookings'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.location_on), text: 'GPS Tracking'),
            Tab(icon: Icon(Icons.analytics), text: 'Reports'),
            Tab(icon: Icon(Icons.settings), text: 'System Config'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Business Analytics'),
            Tab(icon: Icon(Icons.build), text: 'Fleet Management'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsTab(bookingService, userService, bookings),
          _buildUsersTab(userService, users),
          _buildGPSTrackingTab(bookingService, carService),
          _buildReportsTab(bookingService, userService),
          _buildSystemConfigTab(),
          _buildBusinessAnalyticsTab(),
          _buildFleetManagementTab(carService),
        ],
      ),
    );
  }
}
