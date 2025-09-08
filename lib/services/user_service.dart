import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user.dart';
import '../utils/performance_monitor.dart';
import '../utils/logger.dart';

class UserService with ChangeNotifier {
  /// Register FCM device token for current user
  Future<void> registerDeviceToken(String deviceToken) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(deviceToken: deviceToken);
    await _firestore.collection('users').doc(_currentUser!.id).update({'deviceToken': deviceToken});
    AppLogger.info('Device token registered for user: ${_currentUser!.email}');
    notifyListeners();
  }
  final List<User> _users = [];
  User? _currentUser;
  static const String _currentUserKey = 'current_user';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserService() {
    AppLogger.info('UserService constructor called');
    // Defer heavy initialization to avoid blocking the main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeService();
    });
  }

  Future<void> _initializeService() async {
    try {
      await _loadUsers();
      AppLogger.info('Users loaded from database: ${_users.length} users found');
      await _loadCurrentUser();
      AppLogger.info('Current user loaded: ${_currentUser?.email ?? "None"}');
      // Always check for missing default users and add them
      AppLogger.info('Checking for missing default users...');
      loadMockUsers();
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing UserService: $e', e, stackTrace);
    }
  }

  List<User> get users => _users.where((user) => user.isActive && user.registrationStatus == 'approved').toList();
  List<User> get allUsers => _users;
  List<User> get customers => _users.where((user) => user.isCustomer).toList();
  List<User> get admins => _users.where((user) => user.isAdmin).toList();
  List<User> get staff => _users.where((user) => user.isStaff).toList();
  List<User> get inactiveUsers => _users.where((user) => !user.isActive).toList();
  List<User> get pendingUsers => _users.where((user) => user.registrationStatus == 'pending').toList();
  List<User> get approvedUsers => _users.where((user) => user.registrationStatus == 'approved').toList();
  List<User> get rejectedUsers => _users.where((user) => user.registrationStatus == 'rejected').toList();

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void addUser(User user) {
    _users.add(user);
    _saveUsers();
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    _saveCurrentUser();
    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUser = null;
    _saveCurrentUser();
    notifyListeners();
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
    String? idNumber,
    String? idType,
  }) async {
    // Basic client-side duplicate check
    if (_users.any((user) => user.email == email)) {
      throw Exception('This email is already registered. Please use a different email.');
    }

    try {
      // Create Firebase Auth user so they appear in Firebase Authentication console
      AppLogger.info('Attempting FirebaseAuth.createUserWithEmailAndPassword for $email');
      print('Attempting FirebaseAuth.createUserWithEmailAndPassword for $email');
      final userCredential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();
      AppLogger.info('FirebaseAuth user created: $email (uid: $uid)');

      final newUser = User(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        password: password,
        createdAt: DateTime.now(),
        isActive: true,
        userType: userType,
        registrationStatus: 'approved',
        idNumber: idNumber,
        idType: idType,
        isIdVerified: idNumber != null && idType != null,
      );

  _users.add(newUser);
  // Set app-level current user so app state matches FirebaseAuth
  setCurrentUser(newUser);
  notifyListeners();

      // Persist the new user document to Firestore immediately
      try {
            final currentAuthUid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
            AppLogger.info('Current FirebaseAuth signed-in UID before Firestore write: $currentAuthUid');
            print('Current FirebaseAuth signed-in UID before Firestore write: $currentAuthUid');

        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        AppLogger.info('Registered user saved to Firestore: $email (uid: $uid)');
            print('Registered user saved to Firestore: $email (uid: $uid)');
      } catch (e, st) {
        AppLogger.error('Failed to persist registered user to Firestore: $e', e, st);
        // Also print to stdout so flutter run shows it immediately
        print('Failed to persist registered user to Firestore: $e');
        print(st);
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      // Re-throw useful message for the UI
      AppLogger.error('FirebaseAuthException during registration: ${e.message}');
      print('FirebaseAuthException during registration: ${e.message}');
      throw Exception(e.message ?? 'Failed to create user: ${e.code}');
    } catch (e, st) {
      // Diagnostic: log runtimeType and content for the unexpected Pigeon/native response
      AppLogger.error('Non-Firebase exception during registration: $e', e, st);
      print('Non-Firebase exception during registration: $e');
      print('Exception runtimeType: ${e.runtimeType}');
      print(st);
      throw Exception('Failed to register user: $e');
    }
  }

  void updateUser(String userId, User updatedUser) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = updatedUser;
      _saveUsers();
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users.removeAt(index);
      _saveUsers();
      notifyListeners();
    }
  }

  void deactivateUser(String userId) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: false);
      _saveUsers();
      notifyListeners();
    }
  }

  void activateUser(String userId) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: true);
      _saveUsers();
      notifyListeners();
    }
  }

  void approveUserRegistration(String userId) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(registrationStatus: 'approved');
      _saveUsers();
      notifyListeners();
    }
  }

  void rejectUserRegistration(String userId) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(registrationStatus: 'rejected');
      _saveUsers();
      notifyListeners();
    }
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;
    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) =>
      user.name.toLowerCase().contains(lowercaseQuery) ||
      user.email.toLowerCase().contains(lowercaseQuery) ||
      user.phone.toLowerCase().contains(lowercaseQuery) ||
      user.userType.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  void loadMockUsers() {
    final now = DateTime.now();
    AppLogger.info('Checking if default admin exists...');
    bool adminExists = _users.any((user) => user.id == 'default-admin');
    AppLogger.info('Default admin exists: $adminExists');

    AppLogger.info('Checking if default staff exists...');
    bool staffExists = _users.any((user) => user.id == 'default-staff');
    AppLogger.info('Default staff exists: $staffExists');

    bool addedUsers = false;

    // Add default admin if it doesn't exist
    if (!adminExists) {
      AppLogger.info('Adding default admin user...');
      final adminUser = User(
        id: 'default-admin',
        name: 'System Administrator',
        email: 'caradmin1@gmail.com',
        phone: '+233543671806',
        password: 'Admin1',
        createdAt: now,
        lastLogin: now,
        isActive: true,
        userType: 'admin',
        registrationStatus: 'approved',
      );
      _users.add(adminUser);
      addedUsers = true;
      AppLogger.info('Added admin user: ${adminUser.email} with password: ${adminUser.password}');
    }

    // Add default staff if it doesn't exist
    if (!staffExists) {
      AppLogger.info('Adding default staff user...');
      final staffUser = User(
        id: 'default-staff',
        name: 'Car Rental Staff',
        email: 'carstaff1@gmail.com',
        phone: '+233543671807',
        password: 'Staff1',
        createdAt: now,
        lastLogin: now,
        isActive: true,
        userType: 'staff',
        registrationStatus: 'approved',
      );
      _users.add(staffUser);
      addedUsers = true;
      AppLogger.info('Added staff user: ${staffUser.email} with password: ${staffUser.password}');
    }

    if (addedUsers) {
      _saveUsers();
      notifyListeners();
      AppLogger.info('Users list after adding users: ${_users.map((u) => u.email).toList()}');
    } else {
      AppLogger.info('Default users already exist in users list');
    }
  }

  void clearAllUsers() {
    _users.clear();
    _saveUsers();
    notifyListeners();
  }

  int get totalUsers => _users.length;
  int get activeUsersCount => users.length;
  int get inactiveUsersCount => inactiveUsers.length;
  int get customersCount => customers.length;
  int get adminsCount => admins.length;
  int get staffCount => staff.length;

  Future<void> _loadUsers() async {
    startPerf('loadUsers');
    try {
      final querySnapshot = await _firestore.collection('users').get();
      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return User.fromMap(data);
      }).toList();
      _users.clear();
      _users.addAll(users);
      notifyListeners();
      endPerf('loadUsers', details: 'Loaded ${_users.length} users from Firestore');
    } catch (e) {
      endPerf('loadUsers', details: 'Error: $e');
      AppLogger.error('Error loading users from Firestore: $e');
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString(_currentUserKey);
      if (currentUserJson != null && currentUserJson.isNotEmpty) {
        final userMap = _parseUserData(currentUserJson);
        _currentUser = User.fromMap(userMap);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading current user: \$e');
    }
  }

  String _serializeUserData(Map<String, dynamic> userMap) {
    return json.encode(userMap);
  }

  Map<String, dynamic> _parseUserData(String userData) {
    try {
      final Map<String, dynamic> parsedData = json.decode(userData);
      final Map<String, dynamic> result = {};
      for (final entry in parsedData.entries) {
        final key = entry.key;
        dynamic value = entry.value;
        if (key == 'isActive' || key == 'isAdmin' || key == 'isStaff' || key == 'isCustomer' || key == 'isIdVerified') {
          result[key] = value is bool ? value : (value is String ? value.toLowerCase() == 'true' : false);
        } else if (key == 'createdAt' || key == 'lastLogin') {
          if (value is String) {
            try {
              result[key] = DateTime.parse(value);
            } catch (e) {
              result[key] = value;
            }
          } else {
            result[key] = value;
          }
        } else if (key == 'preferences') {
          if (value is Map<String, dynamic>) {
            result[key] = value;
          } else if (value is String) {
            try {
              result[key] = json.decode(value);
            } catch (e) {
              result[key] = {};
            }
          } else {
            result[key] = {};
          }
        } else if (key == 'favoriteCarIds') {
          if (value is List<String>) {
            result[key] = value;
          } else if (value is String) {
            try {
              result[key] = List<String>.from(json.decode(value));
            } catch (e) {
              result[key] = [];
            }
          } else {
            result[key] = [];
          }
        } else {
          result[key] = value;
        }
      }
      return result;
    } catch (e) {
      print('Error parsing user data: \$e');
      return {};
    }
  }

  Future<void> _saveUsers() async {
    startPerf('saveUsers');
    try {
      // Save all users to Firestore using batch write for better performance
      final batch = _firestore.batch();
      for (final user in _users) {
        final docRef = _firestore.collection('users').doc(user.id);
        batch.set(docRef, user.toMap());
      }
      await batch.commit();
      endPerf('saveUsers', details: 'Saved ${_users.length} users to Firestore');
    } catch (e) {
      endPerf('saveUsers', details: 'Error: $e');
      AppLogger.error('Error saving users to Firestore: $e');
    }
  }

  Future<void> _saveCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        final currentUserJson = _serializeUserData(_currentUser!.toMap());
        await prefs.setString(_currentUserKey, currentUserJson);
      } else {
        await prefs.remove(_currentUserKey);
      }
    } catch (e) {
      print('Error saving current user: \$e');
    }
  }
}
