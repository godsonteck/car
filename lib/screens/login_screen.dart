import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'admin_screen.dart';
import 'staff_screen.dart';
import '../main.dart';
import 'registration_screen.dart' as registration;
import '../theme/app_theme.dart';
import '../shared/components/primary_button.dart';
import '../shared/components/app_card.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Only load mock users if no users exist (for demo purposes)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);
      print('Checking if mock users need to be loaded...');
      if (userService.allUsers.isEmpty) {
        print('No users found, loading mock users...');
        userService.loadMockUsers();
      } else {
        print('Users already exist, skipping mock data loading');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isDemoUser(String email) {
    return email == 'caradmin1@gmail.com' || email == 'carstaff1@gmail.com';
  }

  String _getDemoPassword(String email) {
    return email == 'caradmin1@gmail.com' ? 'Admin1' : 'Staff1';
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userService = Provider.of<UserService>(context, listen: false);
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        // Use FirebaseAuth to sign in so app matches server-side users
        final fb_auth.FirebaseAuth auth = fb_auth.FirebaseAuth.instance;
        try {
          final cred = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          final uid = cred.user?.uid;

          // Load user document from Firestore
          User appUser;
          if (uid != null) {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();
            if (doc.exists && doc.data() != null) {
              final data = doc.data()!;
              print(
                'Loaded user doc from Firestore for uid $uid: ${data.keys.toList()}',
              );
              appUser = User.fromMap(data);
            } else {
              print(
                'No Firestore user doc for uid $uid, creating fallback user',
              );
              // Fallback: create minimal user object from auth info
              // Check if this is a demo user and set appropriate userType
              String userType = 'customer';
              if (_isDemoUser(email)) {
                userType = email == 'caradmin1@gmail.com' ? 'admin' : 'staff';
                print('Detected demo user, setting userType to: $userType');
              }

              appUser = User(
                id: uid,
                name:
                    cred.user?.displayName ??
                    (userType == 'admin'
                        ? 'System Administrator'
                        : userType == 'staff'
                        ? 'Car Rental Staff'
                        : ''),
                email: cred.user?.email ?? email,
                phone: '',
                password: password,
                createdAt: DateTime.now(),
                isActive: true,
                userType: userType,
                registrationStatus: 'approved',
              );
            }
            print(
              'Login resolved appUser: id=${appUser.id}, email=${appUser.email}, userType=${appUser.userType}',
            );
            print(
              'Navigation check - isAdmin: ${appUser.isAdmin}, isStaff: ${appUser.isStaff}, isCustomer: ${appUser.isCustomer}',
            );

            // Save into UserService and navigate
            userService.setCurrentUser(appUser);
            if (appUser.isAdmin) {
              print('Navigating to AdminScreen');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AdminScreen()),
              );
            } else if (appUser.isStaff) {
              print('Navigating to StaffScreen');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const StaffScreen()),
              );
            } else {
              print('Navigating to MainNavigationScreen (customer)');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const MainNavigationScreen()),
              );
            }
          } else {
            throw Exception('Failed to sign in: missing uid');
          }
        } on fb_auth.FirebaseAuthException catch (e) {
          print('FirebaseAuthException: code=${e.code}, message=${e.message}');

          // Handle demo user creation if user not found or invalid credentials for demo users
          if ((e.code == 'user-not-found' || e.code == 'invalid-credential') &&
              _isDemoUser(email)) {
            print('Demo user not found, attempting to create: $email');
            try {
              final demoPassword = _getDemoPassword(email);
              final userCredential = await auth.createUserWithEmailAndPassword(
                email: email,
                password: demoPassword,
              );
              print('Demo user created successfully: $email');

              // Now try to sign in again
              final cred = await auth.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
              final uid = cred.user?.uid;

              // Load user document from Firestore
              User appUser;
              if (uid != null) {
                final doc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get();
                if (doc.exists && doc.data() != null) {
                  final data = doc.data()!;
                  print(
                    'Loaded user doc from Firestore for uid $uid: ${data.keys.toList()}',
                  );
                  appUser = User.fromMap(data);
                } else {
                  print(
                    'No Firestore user doc for uid $uid, creating fallback user',
                  );
                  // Fallback: create minimal user object from auth info
                  appUser = User(
                    id: uid,
                    name: email == 'caradmin1@gmail.com'
                        ? 'System Administrator'
                        : 'Car Rental Staff',
                    email: cred.user?.email ?? email,
                    phone: '',
                    password: password,
                    createdAt: DateTime.now(),
                    isActive: true,
                    userType: email == 'caradmin1@gmail.com'
                        ? 'admin'
                        : 'staff',
                    registrationStatus: 'approved',
                  );
                }
                print(
                  'Login resolved appUser: id=${appUser.id}, email=${appUser.email}, userType=${appUser.userType}',
                );
                // Save into UserService and navigate
                userService.setCurrentUser(appUser);
                if (appUser.isAdmin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const AdminScreen()),
                  );
                } else if (appUser.isStaff) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const StaffScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const MainNavigationScreen(),
                    ),
                  );
                }
              } else {
                throw Exception('Failed to sign in: missing uid');
              }
              return; // Exit the method since login was successful
            } catch (createError) {
              print('Failed to create demo user: $createError');
              throw Exception(
                'Failed to create demo account. Please try again.',
              );
            }
          }

          // Provide user-friendly error messages based on Firebase error codes
          String errorMessage;
          switch (e.code) {
            case 'user-not-found':
              errorMessage =
                  'No user found with this email address. Please check your email or register a new account.';
              break;
            case 'wrong-password':
              errorMessage = 'Incorrect password. Please try again.';
              break;
            case 'invalid-email':
              errorMessage = 'Invalid email address format.';
              break;
            case 'user-disabled':
              errorMessage =
                  'This account has been disabled. Please contact support.';
              break;
            case 'too-many-requests':
              errorMessage =
                  'Too many failed login attempts. Please try again later.';
              break;
            case 'operation-not-allowed':
              errorMessage =
                  'Email/password sign-in is not enabled. Please contact support.';
              break;
            case 'invalid-credential':
              errorMessage =
                  'Invalid login credentials. Please check your email and password.';
              break;
            default:
              errorMessage =
                  e.message ?? 'Authentication failed. Please try again.';
          }
          throw Exception(errorMessage);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 80),

                // App Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withAlpha(204), // 0.8 * 255
                    shape: BoxShape.circle,
                    boxShadow: [
                      AppTheme.neumorphicShadow,
                      AppTheme.neumorphicHighlight,
                    ],
                  ),
                  child: Icon(
                    Icons.directions_car,
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                Text(
                  'Car Rental',
                  style: AppTheme.displayMedium.copyWith(
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Drive Your Dreams',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 40),

                // Login Form
                AppCard(
                  glassmorphic: true,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your journey',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: AppTheme.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusM,
                              ),
                              borderSide: BorderSide(
                                color: AppTheme.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusM,
                              ),
                              borderSide: BorderSide(
                                color: AppTheme.borderColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusM,
                              ),
                              borderSide: BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            // Only allow Gmail addresses
                            if (!value.toLowerCase().endsWith('@gmail.com')) {
                              return 'Only Gmail addresses are allowed for login';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppTheme.textSecondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusM,
                              ),
                              borderSide: BorderSide(
                                color: AppTheme.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusM,
                              ),
                              borderSide: BorderSide(
                                color: AppTheme.borderColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusM,
                              ),
                              borderSide: BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        PrimaryButton(
                          text: 'Login',
                          onPressed: _isLoading ? () {} : _login,
                          isLoading: _isLoading,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),

                        // Registration Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const registration.RegistrationScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Register',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Demo Credentials
                AppCard(
                  glassmorphic: true,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Credentials:',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Admin: caradmin1@gmail.com',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        'Password: Admin1',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Staff: carstaff1@gmail.com',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        'Password: Staff1',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
