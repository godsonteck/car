class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password; // Added password field
  final String? profileImage;
  final String? address;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String userType; // 'customer', 'admin', 'staff'
  final Map<String, dynamic> preferences;
  final List<String> favoriteCarIds;
  final String registrationStatus; // 'pending', 'approved', 'rejected'
  final String? idNumber; // Ghana ID number (Ghana Card, Driver's License, etc.)
  final bool isIdVerified; // Whether ID has been verified
  final String? idType; // Type of ID: 'ghana_card', 'driver_license', 'voter_id', 'passport'
  final String? deviceToken; // FCM device token

  User({
  required this.id,
  required this.name,
  required this.email,
  required this.phone,
  this.password = '', // Make password optional with default empty string
  this.profileImage,
  this.address,
  required this.createdAt,
  this.lastLogin,
  this.isActive = true,
  this.userType = 'customer',
  this.preferences = const {},
  this.favoriteCarIds = const [],
  this.registrationStatus = 'pending', // Default to pending for new users
  this.idNumber,
  this.isIdVerified = false, // Default to not verified
  this.idType,
  this.deviceToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password, // Include password field
      'profileImage': profileImage,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'userType': userType,
      'preferences': preferences,
      'favoriteCarIds': favoriteCarIds,
      'registrationStatus': registrationStatus,
      'idNumber': idNumber,
      'isIdVerified': isIdVerified,
      'idType': idType,
      'deviceToken': deviceToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'] ?? '', // Include password field with default
      profileImage: map['profileImage'],
      address: map['address'],
      createdAt: _parseDate(map['createdAt']),
      lastLogin: map['lastLogin'] != null ? _parseDate(map['lastLogin']) : null,
      isActive: map['isActive'] ?? true,
      userType: map['userType'] ?? 'customer',
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      favoriteCarIds: List<String>.from(map['favoriteCarIds'] ?? []),
      registrationStatus: map['registrationStatus'] ?? 'pending',
      idNumber: map['idNumber'],
      isIdVerified: map['isIdVerified'] ?? false,
      idType: map['idType'],
      deviceToken: map['deviceToken'],
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    // Firestore Timestamp support without importing it directly
    try {
      final seconds = value['seconds'];
      if (seconds is int) return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } catch (_) {}
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  User copyWith({
  String? id,
  String? name,
  String? email,
  String? phone,
  String? password,
  String? profileImage,
  String? address,
  DateTime? createdAt,
  DateTime? lastLogin,
  bool? isActive,
  String? userType,
  Map<String, dynamic>? preferences,
  List<String>? favoriteCarIds,
  String? registrationStatus,
  String? idNumber,
  bool? isIdVerified,
  String? idType,
  String? deviceToken,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      userType: userType ?? this.userType,
      preferences: preferences ?? this.preferences,
      favoriteCarIds: favoriteCarIds ?? this.favoriteCarIds,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      idNumber: idNumber ?? this.idNumber,
      isIdVerified: isIdVerified ?? this.isIdVerified,
      idType: idType ?? this.idType,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }

  bool get isAdmin => userType == 'admin';
  bool get isStaff => userType == 'staff';
  bool get isCustomer => userType == 'customer';
}
