import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/user_service.dart';
import '../models/user.dart';
import '../utils/ghana_id_validator.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../shared/components/primary_button.dart';
import '../shared/components/app_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _idTypeController = TextEditingController();

  File? _profileImage;
  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userService = Provider.of<UserService>(context, listen: false);
    _currentUser = userService.currentUser;
    _populateFormFields();

    // Load saved profile image if it exists
    if (_currentUser != null && _currentUser!.profileImage != null) {
      try {
        final imageFile = File(_currentUser!.profileImage!);
        // Check if file exists and is readable
        if (imageFile.existsSync()) {
          setState(() {
            _profileImage = imageFile;
          });
        } else {
          // If file doesn't exist, clear the profile image reference
          final updatedUser = _currentUser!.copyWith(profileImage: null);
          userService.updateUser(_currentUser!.id, updatedUser);
          setState(() {
            _currentUser = updatedUser;
            _profileImage = null;
          });
        }
      } catch (e) {
        // Handle error silently - clear the invalid image reference
        final updatedUser = _currentUser!.copyWith(profileImage: null);
        userService.updateUser(_currentUser!.id, updatedUser);
        setState(() {
          _currentUser = updatedUser;
          _profileImage = null;
        });
      }
    }
  }

  void _populateFormFields() {
    if (_currentUser != null) {
      _nameController.text = _currentUser!.name;
      _emailController.text = _currentUser!.email;
      _phoneController.text = _currentUser!.phone;
      _addressController.text = _currentUser!.address ?? '';
      _idNumberController.text = _currentUser!.idNumber ?? '';
      _idTypeController.text = _currentUser!.idType ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        // Save the image path to user profile
        final userService = Provider.of<UserService>(context, listen: false);
        if (_currentUser != null) {
          final updatedUser = _currentUser!.copyWith(
            profileImage: pickedFile.path,
          );
          userService.updateUser(_currentUser!.id, updatedUser);
          setState(() {
            _currentUser = updatedUser;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Enhanced error handling for gralloc and graphics buffer issues
      String errorMessage = 'Error picking image';

      if (e.toString().contains('gralloc') ||
          e.toString().contains('GraphicBuffer')) {
        errorMessage =
            'Graphics buffer error. Please try again or restart the app.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please grant gallery access.';
      } else if (e.toString().contains('cancelled')) {
        errorMessage = 'Image selection cancelled.';
        return; // Don't show error for user cancellation
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _pickImage,
          ),
        ),
      );

      // Log the error for debugging
      debugPrint('Image picker error: ${e.toString()}');
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userService = Provider.of<UserService>(context, listen: false);

        if (_currentUser != null) {
          // Validate ID if provided
          final idNumber = _idNumberController.text.trim();
          final idType = _idTypeController.text.trim();

          if (idNumber.isNotEmpty && idType.isNotEmpty) {
            final isValid = GhanaIdValidator.validateId(idNumber, idType);
            if (!isValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Invalid ${GhanaIdValidator.getDisplayName(idType)} format',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => _isLoading = false);
              return;
            }
          }

          final updatedUser = _currentUser!.copyWith(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            idNumber: idNumber.isNotEmpty ? idNumber : null,
            idType: idType.isNotEmpty ? idType : null,
            isIdVerified: idNumber.isNotEmpty && idType.isNotEmpty,
            // In a real app, you'd handle the profile image upload here
          );

          userService.updateUser(_currentUser!.id, updatedUser);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _isEditing = false;
            _currentUser = updatedUser;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text != _currentUser?.password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current password is incorrect'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userService = Provider.of<UserService>(context, listen: false);

      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          password: _newPasswordController.text,
        );

        userService.updateUser(_currentUser!.id, updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isChangingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _currentUser = updatedUser;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing password: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final userService = Provider.of<UserService>(
                  context,
                  listen: false,
                );
                userService.clearCurrentUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _idNumberController.dispose();
    _idTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTheme.headlineMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        automaticallyImplyLeading: false,
        actions: [
          if (!_isEditing && !_isChangingPassword) ...[
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  ),
                  child: IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Switched to ${themeProvider.isDarkMode ? 'Dark' : 'Light'} Mode',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Toggle Theme (Manual Override)',
                  ),
                );
              },
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
              ),
              child: IconButton(
                icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                onPressed: () => setState(() => _isEditing = true),
                tooltip: 'Edit Profile',
              ),
            ),
          ],
        ],
      ),
      body: _currentUser == null
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.surfaceColor,
                          boxShadow: [
                            AppTheme.neumorphicShadow,
                            AppTheme.neumorphicHighlight,
                          ],
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : (_currentUser!.profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(_currentUser!.profileImage!),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child:
                            _profileImage == null &&
                                _currentUser!.profileImage == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: AppTheme.textSecondary,
                              )
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [AppTheme.neumorphicShadow],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: AppTheme.textPrimary,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User Type Badge
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      _currentUser!.userType.toUpperCase(),
                      style: AppTheme.bodySmall.copyWith(
                        color: _currentUser!.isAdmin
                            ? AppTheme.errorColor
                            : _currentUser!.isStaff
                            ? AppTheme.warningColor
                            : AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isChangingPassword) _buildPasswordChangeForm(),
                  if (!_isChangingPassword) _buildProfileForm(),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isEditing || _isChangingPassword)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: PrimaryButton(
                              text: 'Cancel',
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _isChangingPassword = false;
                                  _populateFormFields();
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: PrimaryButton(
                            text: _isChangingPassword
                                ? 'Change Password'
                                : 'Save',
                            onPressed: _isLoading
                                ? () {}
                                : _isChangingPassword
                                ? _changePassword
                                : _saveProfile,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),

                  if (!_isEditing && !_isChangingPassword)
                    Column(
                      children: [
                        PrimaryButton(
                          text: 'Change Password',
                          onPressed: () =>
                              setState(() => _isChangingPassword = true),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: 'Logout',
                            onPressed: _logout,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileForm() {
    final theme = Theme.of(context);
    return AppCard(
      glassmorphic: true,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.email,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.phone,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.location_on,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              enabled: _isEditing,
              maxLines: 2,
            ),

            // ID Verification Section
            const SizedBox(height: 24),
            Text(
              'ID Verification',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // ID Type Dropdown
            DropdownButtonFormField<String>(
              value: _idTypeController.text.isEmpty
                  ? null
                  : _idTypeController.text,
              decoration: InputDecoration(
                labelText: 'ID Type',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.credit_card,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              dropdownColor: theme.colorScheme.surface,
              style: TextStyle(color: theme.colorScheme.onSurface),
              items: GhanaIdValidator.getAvailableIdTypes().map((idType) {
                return DropdownMenuItem<String>(
                  value: idType['value'],
                  child: Text(
                    idType['display']!,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: _isEditing
                  ? (value) {
                      setState(() {
                        _idTypeController.text = value ?? '';
                      });
                    }
                  : null,
              validator: (value) {
                if (_idNumberController.text.isNotEmpty &&
                    (value == null || value.isEmpty)) {
                  return 'Please select ID type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ID Number
            TextFormField(
              controller: _idNumberController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'ID Number',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.numbers,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                hintText: 'e.g., GHA-12345678-9',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              enabled: _isEditing,
              validator: (value) {
                if (_idTypeController.text.isNotEmpty &&
                    (value == null || value.isEmpty)) {
                  return 'Please enter ID number';
                }
                return null;
              },
            ),

            // ID Verification Status
            if (_currentUser != null && _currentUser!.isIdVerified)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  border: Border.all(color: AppTheme.successColor),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: AppTheme.successColor),
                    const SizedBox(width: 8),
                    Text(
                      'ID Verified',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordChangeForm() {
    final theme = Theme.of(context);
    return AppCard(
      glassmorphic: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextFormField(
            controller: _currentPasswordController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Current Password',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              prefixIcon: Icon(
                Icons.lock,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter current password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'New Password',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              prefixIcon: Icon(
                Icons.lock_reset,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm new password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
