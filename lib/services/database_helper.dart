import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/car.dart';
import '../models/booking.dart';
import '../services/support_service.dart';

class DatabaseHelper {
  static const _databaseName = 'htu_rentals.db';
  static const _databaseVersion = 3;

  // Table names
  static const String usersTable = 'users';
  static const String carsTable = 'cars';
  static const String bookingsTable = 'bookings';
  static const String supportRequestsTable = 'support_requests';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 3 && newVersion >= 3) {
      // Add pickupTime column to bookings table
      await db.execute('ALTER TABLE $bookingsTable ADD COLUMN pickupTime TEXT');
    }
    if (oldVersion < newVersion) {
      // For other upgrades, you can add more migration logic here
    }
  }

  Future<void> _createTables(Database db) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $usersTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        profileImage TEXT,
        address TEXT,
        createdAt TEXT NOT NULL,
        lastLogin TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        userType TEXT NOT NULL DEFAULT 'customer',
        preferences TEXT NOT NULL,
        favoriteCarIds TEXT NOT NULL,
        registrationStatus TEXT NOT NULL DEFAULT 'pending',
        idNumber TEXT,
        isIdVerified INTEGER NOT NULL DEFAULT 0,
        idType TEXT
      )
    ''');

    // Create cars table
    await db.execute('''
      CREATE TABLE $carsTable (
        id TEXT PRIMARY KEY,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        imagePath TEXT NOT NULL,
        pricePerDay REAL NOT NULL,
        transmission TEXT NOT NULL,
        fuelType TEXT NOT NULL,
        seats INTEGER NOT NULL,
        category TEXT NOT NULL,
        available INTEGER NOT NULL DEFAULT 1,
        description TEXT NOT NULL
      )
    ''');

    // Create bookings table
    await db.execute('''
      CREATE TABLE $bookingsTable (
        id TEXT PRIMARY KEY,
        carId TEXT NOT NULL,
        carName TEXT NOT NULL,
        carImage TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        pickupTime TEXT,
        totalPrice REAL NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        paymentMethod TEXT NOT NULL DEFAULT 'credit_card',
        paymentDetails TEXT NOT NULL,
        isBeingTracked INTEGER NOT NULL DEFAULT 0,
        currentLatitude REAL,
        currentLongitude REAL,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        userEmail TEXT NOT NULL,
        userPhone TEXT NOT NULL,
        FOREIGN KEY (carId) REFERENCES $carsTable (id),
        FOREIGN KEY (userId) REFERENCES $usersTable (id)
      )
    ''');

    // Create support requests table
    await db.execute('''
      CREATE TABLE $supportRequestsTable (
        id TEXT PRIMARY KEY,
        customerName TEXT NOT NULL,
        customerEmail TEXT NOT NULL,
        customerPhone TEXT NOT NULL,
        subject TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'open',
        priority TEXT NOT NULL DEFAULT 'medium',
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }


  Future<void> _insertInitialData(Database db) async {
    // Insert default admin user
    await db.insert(usersTable, {
      'id': 'admin_001',
      'name': 'System Administrator',
      'email': 'admin@hturentals.com',
      'phone': '+233543671806',
      'password': 'admin123', // In production, this should be hashed
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': 1,
      'userType': 'admin',
      'preferences': '{}',
      'favoriteCarIds': '[]',
      'registrationStatus': 'approved',
      'isIdVerified': 1,
    });

    // Insert comprehensive car inventory with all available images
    final cars = [
      // Toyota Camry
      {
        'id': '1',
        'brand': 'Toyota',
        'model': 'Camry',
        'year': 2023,
        'imagePath': 'assets/camaro_0.png',
        'pricePerDay': 85.99,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Sedan',
        'available': 1,
        'description': 'Comfortable and reliable sedan perfect for city driving.',
      },
      // Honda Civic
      {
        'id': '2',
        'brand': 'Honda',
        'model': 'Civic',
        'year': 2023,
        'imagePath': 'assets/honda_0.png',
        'pricePerDay': 75.99,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Sedan',
        'available': 1,
        'description': 'Fuel-efficient compact sedan with excellent mileage.',
      },
      // BMW X3
      {
        'id': '3',
        'brand': 'BMW',
        'model': 'X3',
        'year': 2023,
        'imagePath': 'assets/bmw_1.png',
        'pricePerDay': 120.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Luxurious SUV with premium features and sporty performance.',
      },
      // BMW Additional
      {
        'id': '16',
        'brand': 'BMW',
        'model': 'X5',
        'year': 2023,
        'imagePath': 'assets/bmw_2.jpeg',
        'pricePerDay': 135.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Premium SUV with exceptional comfort and technology.',
      },
      {
        'id': '17',
        'brand': 'BMW',
        'model': 'M3',
        'year': 2023,
        'imagePath': 'assets/bmw_3.jpeg',
        'pricePerDay': 180.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'High-performance sports sedan with legendary M power.',
      },
      {
        'id': '18',
        'brand': 'BMW',
        'model': 'i8',
        'year': 2023,
        'imagePath': 'assets/bmw_4.jpeg',
        'pricePerDay': 220.00,
        'transmission': 'Automatic',
        'fuelType': 'Hybrid',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'Revolutionary hybrid sports car with futuristic design.',
      },
      // Audi A4
      {
        'id': '4',
        'brand': 'Audi',
        'model': 'A4',
        'year': 2023,
        'imagePath': 'assets/audi_1.png',
        'pricePerDay': 110.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Sedan',
        'available': 1,
        'description': 'Elegant sedan with advanced technology and comfort.',
      },
      // Audi Additional
      {
        'id': '19',
        'brand': 'Audi',
        'model': 'Q5',
        'year': 2023,
        'imagePath': 'assets/audi_3.jpeg',
        'pricePerDay': 125.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Luxurious SUV with quattro all-wheel drive system.',
      },
      {
        'id': '20',
        'brand': 'Audi',
        'model': 'R8',
        'year': 2023,
        'imagePath': 'assets/audi_4.jpeg',
        'pricePerDay': 250.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 2,
        'category': 'Supercar',
        'available': 1,
        'description': 'Mid-engine supercar with breathtaking performance.',
      },
      {
        'id': '21',
        'brand': 'Audi',
        'model': 'A3',
        'year': 2023,
        'imagePath': 'assets/audi.jpeg',
        'pricePerDay': 95.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Hatchback',
        'available': 1,
        'description': 'Compact premium hatchback with sporty dynamics.',
      },
      // Tesla Model 3
      {
        'id': '5',
        'brand': 'Tesla',
        'model': 'Model 3',
        'year': 2023,
        'imagePath': 'assets/tesla_1.png',
        'pricePerDay': 140.00,
        'transmission': 'Automatic',
        'fuelType': 'Electric',
        'seats': 5,
        'category': 'Sedan',
        'available': 1,
        'description': 'Electric sedan with cutting-edge technology and zero emissions.',
      },
      // Tesla Additional
      {
        'id': '22',
        'brand': 'Tesla',
        'model': 'Model Y',
        'year': 2023,
        'imagePath': 'assets/tesla_2.jpeg',
        'pricePerDay': 155.00,
        'transmission': 'Automatic',
        'fuelType': 'Electric',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Electric SUV with exceptional range and utility.',
      },
      {
        'id': '23',
        'brand': 'Tesla',
        'model': 'Model S',
        'year': 2023,
        'imagePath': 'assets/tesla_3.jpeg',
        'pricePerDay': 175.00,
        'transmission': 'Automatic',
        'fuelType': 'Electric',
        'seats': 5,
        'category': 'Sedan',
        'available': 1,
        'description': 'Luxury electric sedan with premium features.',
      },
      {
        'id': '24',
        'brand': 'Tesla',
        'model': 'Model X',
        'year': 2023,
        'imagePath': 'assets/tesla_4.jpeg',
        'pricePerDay': 195.00,
        'transmission': 'Automatic',
        'fuelType': 'Electric',
        'seats': 7,
        'category': 'SUV',
        'available': 1,
        'description': 'Electric SUV with falcon wing doors and premium interior.',
      },
      {
        'id': '25',
        'brand': 'Advantage',
        'model': 'Sedan',
        'year': 2023,
        'imagePath': 'assets/advantage.jpg',
        'pricePerDay': 165.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Sedan',
        'available': 1,
        'description': 'Comfortable and reliable sedan perfect for city driving.',
      },
      // Ferrari Spider 488
      {
        'id': '6',
        'brand': 'Ferrari',
        'model': 'Spider 488',
        'year': 2023,
        'imagePath': 'assets/ferrari_spider_488_0.png',
        'pricePerDay': 500.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 2,
        'category': 'Supercar',
        'available': 1,
        'description': 'Exotic sports car with unmatched performance and design.',
      },
      // Ferrari Additional
      {
        'id': '26',
        'brand': 'Ferrari',
        'model': '488 GTB',
        'year': 2023,
        'imagePath': 'assets/ferrari_spider_488_1.png',
        'pricePerDay': 480.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 2,
        'category': 'Supercar',
        'available': 1,
        'description': 'Coupe version of the legendary 488 with turbo V8.',
      },
      {
        'id': '27',
        'brand': 'Ferrari',
        'model': '488 Spider',
        'year': 2023,
        'imagePath': 'assets/ferrari_spider_488_2.png',
        'pricePerDay': 520.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 2,
        'category': 'Supercar',
        'available': 1,
        'description': 'Convertible supercar with retractable hardtop.',
      },
      {
        'id': '28',
        'brand': 'Ferrari',
        'model': '488 Challenge',
        'year': 2023,
        'imagePath': 'assets/ferrari_spider_488_3.png',
        'pricePerDay': 550.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 2,
        'category': 'Supercar',
        'available': 1,
        'description': 'Track-focused version with enhanced performance.',
      },
      {
        'id': '29',
        'brand': 'Ferrari',
        'model': '488 Pista',
        'year': 2023,
        'imagePath': 'assets/ferrari_spider_488_4.png',
        'pricePerDay': 580.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 2,
        'category': 'Supercar',
        'available': 1,
        'description': 'Ultimate track version of the 488 with 710hp.',
      },
      // Land Rover Range Rover
      {
        'id': '7',
        'brand': 'Land Rover',
        'model': 'Range Rover',
        'year': 2023,
        'imagePath': 'assets/land_rover_0.png',
        'pricePerDay': 180.00,
        'transmission': 'Automatic',
        'fuelType': 'Diesel',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Premium SUV with off-road capability and luxury interior.',
      },
      // Land Rover Additional
      {
        'id': '30',
        'brand': 'Land Rover',
        'model': 'Discovery',
        'year': 2023,
        'imagePath': 'assets/land_rover_1.png',
        'pricePerDay': 165.00,
        'transmission': 'Automatic',
        'fuelType': 'Diesel',
        'seats': 7,
        'category': 'SUV',
        'available': 1,
        'description': 'Versatile SUV with excellent off-road capability.',
      },
      {
        'id': '31',
        'brand': 'Land Rover',
        'model': 'Defender',
        'year': 2023,
        'imagePath': 'assets/land_rover_2.png',
        'pricePerDay': 190.00,
        'transmission': 'Manual',
        'fuelType': 'Diesel',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Iconic off-road vehicle with legendary capability.',
      },
      // Nissan GT-R
      {
        'id': '8',
        'brand': 'Nissan',
        'model': 'GT-R',
        'year': 2023,
        'imagePath': 'assets/nissan_gtr_0.png',
        'pricePerDay': 200.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'High-performance sports car with turbocharged engine.',
      },
      // Nissan GT-R Additional
      {
        'id': '32',
        'brand': 'Nissan',
        'model': 'GT-R NISMO',
        'year': 2023,
        'imagePath': 'assets/nissan_gtr_1.png',
        'pricePerDay': 230.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'Ultimate performance version of the GT-R.',
      },
      {
        'id': '33',
        'brand': 'Nissan',
        'model': 'GT-R Track',
        'year': 2023,
        'imagePath': 'assets/nissan_gtr_2.png',
        'pricePerDay': 250.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 2,
        'category': 'Sports',
        'available': 1,
        'description': 'Track-focused GT-R with enhanced aerodynamics.',
      },
      {
        'id': '34',
        'brand': 'Nissan',
        'model': 'GT-R Premium',
        'year': 2023,
        'imagePath': 'assets/nissan_gtr_3.png',
        'pricePerDay': 220.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'Premium version with luxury features and AWD.',
      },
      // Acura MDX
      {
        'id': '9',
        'brand': 'Acura',
        'model': 'MDX',
        'year': 2023,
        'imagePath': 'assets/acura_mdx_2023.png',
        'pricePerDay': 130.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 7,
        'category': 'SUV',
        'available': 1,
        'description': 'Spacious SUV with advanced safety features and comfort.',
      },
      // Acura Additional
      {
        'id': '35',
        'brand': 'Acura',
        'model': 'TLX',
        'year': 2023,
        'imagePath': 'assets/acura_tlx_2023.png',
        'pricePerDay': 115.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Sedan',
        'available': 1,
        'description': 'Luxury sedan with precision handling and technology.',
      },
      {
        'id': '36',
        'brand': 'Acura',
        'model': 'NSX',
        'year': 2023,
        'imagePath': 'assets/acura_2.png',
        'pricePerDay': 280.00,
        'transmission': 'Automatic',
        'fuelType': 'Hybrid',
        'seats': 2,
        'category': 'Supercar',
        'available': 1,
        'description': 'Hybrid supercar with revolutionary technology.',
      },
      // Chevrolet Camaro
      {
        'id': '10',
        'brand': 'Chevrolet',
        'model': 'Camaro',
        'year': 2023,
        'imagePath': 'assets/camaro_1.png',
        'pricePerDay': 150.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'Iconic American muscle car with powerful V8 engine.',
      },
      // Chevrolet Camaro Additional
      {
        'id': '37',
        'brand': 'Chevrolet',
        'model': 'Camaro SS',
        'year': 2023,
        'imagePath': 'assets/camaro_2.png',
        'pricePerDay': 170.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'High-performance SS version with 6.2L V8.',
      },
      // Citroen C4
      {
        'id': '11',
        'brand': 'Citroen',
        'model': 'C4',
        'year': 2023,
        'imagePath': 'assets/citroen_0.png',
        'pricePerDay': 70.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Hatchback',
        'available': 1,
        'description': 'Practical hatchback with unique design and comfort.',
      },
      // Citroen Additional
      {
        'id': '38',
        'brand': 'Citroen',
        'model': 'C3',
        'year': 2023,
        'imagePath': 'assets/citroen_1.png',
        'pricePerDay': 65.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Hatchback',
        'available': 1,
        'description': 'Compact city car with distinctive styling.',
      },
      {
        'id': '39',
        'brand': 'Citroen',
        'model': 'C5 Aircross',
        'year': 2023,
        'imagePath': 'assets/citroen_2.png',
        'pricePerDay': 85.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Comfortable SUV with advanced suspension system.',
      },
      // Fiat 500
      {
        'id': '12',
        'brand': 'Fiat',
        'model': '500',
        'year': 2023,
        'imagePath': 'assets/fiat_0.png',
        'pricePerDay': 60.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Hatchback',
        'available': 1,
        'description': 'Stylish and economical city car with Italian charm.',
      },
      // Fiat Additional
      {
        'id': '40',
        'brand': 'Fiat',
        'model': '500X',
        'year': 2023,
        'imagePath': 'assets/fiat_1.png',
        'pricePerDay': 75.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Crossover version of the iconic 500 with more space.',
      },
      // Ford Mustang
      {
        'id': '13',
        'brand': 'Ford',
        'model': 'Mustang',
        'year': 2023,
        'imagePath': 'assets/ford_0.png',
        'pricePerDay': 160.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'Legendary sports car with American heritage and power.',
      },
      // Ford Additional
      {
        'id': '41',
        'brand': 'Ford',
        'model': 'Mustang GT',
        'year': 2023,
        'imagePath': 'assets/ford_1.png',
        'pricePerDay': 180.00,
        'transmission': 'Manual',
        'fuelType': 'Gasoline',
        'seats': 4,
        'category': 'Sports',
        'available': 1,
        'description': 'High-performance GT version with 5.0L V8.',
      },
      // Alfa Romeo Giulia
      {
        'id': '14',
        'brand': 'Alfa Romeo',
        'model': 'Giulia',
        'year': 2023,
        'imagePath': 'assets/alfa_romeo_c4_0.png',
        'pricePerDay': 125.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'Sedan',
        'available': 1,
        'description': 'Italian sedan with sporty performance and luxury.',
      },
      // Lamborghini Huracan
      {
        'id': '15',
        'brand': 'Lamborghini',
        'model': 'Huracan',
        'year': 2023,
        'imagePath': 'assets/lambo.jpg',
        'pricePerDay': 600.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 2,
        'category': 'Supercar',
        'available': 1,
        'description': 'Exotic supercar with breathtaking speed and design.',
      },
      // SUV Collection
      {
        'id': '42',
        'brand': 'Jeep',
        'model': 'Grand Cherokee',
        'year': 2023,
        'imagePath': 'assets/suv_1.png',
        'pricePerDay': 140.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Legendary SUV with exceptional off-road capability.',
      },
      {
        'id': '43',
        'brand': 'Mercedes-Benz',
        'model': 'GLE',
        'year': 2023,
        'imagePath': 'assets/suv_2.jpeg',
        'pricePerDay': 155.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Luxury SUV with premium comfort and technology.',
      },
      {
        'id': '44',
        'brand': 'Volvo',
        'model': 'XC90',
        'year': 2023,
        'imagePath': 'assets/suv_3.jpeg',
        'pricePerDay': 145.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 7,
        'category': 'SUV',
        'available': 1,
        'description': 'Safe and comfortable SUV with Scandinavian design.',
      },
      {
        'id': '45',
        'brand': 'Porsche',
        'model': 'Cayenne',
        'year': 2023,
        'imagePath': 'assets/suv_4.jpeg',
        'pricePerDay': 185.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'High-performance SUV with sports car dynamics.',
      },
      // Additional Luxury Cars
      {
        'id': '46',
        'brand': 'Lexus',
        'model': 'RX',
        'year': 2023,
        'imagePath': 'assets/lex.jpg',
        'pricePerDay': 135.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Luxury SUV with exceptional comfort and refinement.',
      },
      {
        'id': '47',
        'brand': 'Lincoln',
        'model': 'Navigator',
        'year': 2023,
        'imagePath': 'assets/la.jpg',
        'pricePerDay': 175.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 8,
        'category': 'SUV',
        'available': 1,
        'description': 'Full-size luxury SUV with premium amenities.',
      },
      {
        'id': '48',
        'brand': 'Cadillac',
        'model': 'Escalade',
        'year': 2023,
        'imagePath': 'assets/lam.jpg',
        'pricePerDay': 195.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 8,
        'category': 'SUV',
        'available': 1,
        'description': 'Iconic American luxury SUV with powerful presence.',
      },
      {
        'id': '49',
        'brand': 'Bentley',
        'model': 'Bentayga',
        'year': 2023,
        'imagePath': 'assets/urs.jpg',
        'pricePerDay': 350.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'Ultra-luxury SUV with handcrafted British excellence.',
      },
      {
        'id': '50',
        'brand': 'Rolls-Royce',
        'model': 'Cullinan',
        'year': 2023,
        'imagePath': 'assets/cv.jpg',
        'pricePerDay': 450.00,
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'seats': 5,
        'category': 'SUV',
        'available': 1,
        'description': 'The pinnacle of luxury SUVs with unmatched refinement.',
      },
    ];

    for (final car in cars) {
      await db.insert(carsTable, car);
    }
  }

  // User CRUD operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(usersTable, _userToMap(user), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(usersTable);
    return List.generate(maps.length, (i) => _mapToUser(maps[i]));
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      usersTable,
      _userToMap(user),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Car CRUD operations
  Future<int> insertCar(Car car) async {
    final db = await database;
    return await db.insert(carsTable, _carToMap(car), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Car>> getAllCars() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(carsTable);
    return List.generate(maps.length, (i) => _mapToCar(maps[i]));
  }

  Future<Car?> getCarById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      carsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToCar(maps.first);
    }
    return null;
  }

  Future<List<Car>> getAvailableCars() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      carsTable,
      where: 'available = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => _mapToCar(maps[i]));
  }

  Future<int> updateCar(Car car) async {
    final db = await database;
    return await db.update(
      carsTable,
      _carToMap(car),
      where: 'id = ?',
      whereArgs: [car.id],
    );
  }

  Future<int> deleteCar(String id) async {
    final db = await database;
    return await db.delete(
      carsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Batch operations for better performance
  Future<void> insertCarsBatch(List<Car> cars) async {
    final db = await database;
    final batch = db.batch();

    for (final car in cars) {
      batch.insert(carsTable, _carToMap(car), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<void> updateCarsBatch(List<Car> cars) async {
    final db = await database;
    final batch = db.batch();

    for (final car in cars) {
      batch.update(
        carsTable,
        _carToMap(car),
        where: 'id = ?',
        whereArgs: [car.id],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> insertUsersBatch(List<User> users) async {
    final db = await database;
    final batch = db.batch();

    for (final user in users) {
      batch.insert(usersTable, _userToMap(user), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<void> insertBookingsBatch(List<Booking> bookings) async {
    final db = await database;
    final batch = db.batch();

    for (final booking in bookings) {
      batch.insert(bookingsTable, _bookingToMap(booking), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // Booking CRUD operations
  Future<int> insertBooking(Booking booking) async {
    final db = await database;
    return await db.insert(bookingsTable, _bookingToMap(booking), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(bookingsTable);
    return List.generate(maps.length, (i) => _mapToBooking(maps[i]));
  }

  Future<Booking?> getBookingById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      bookingsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToBooking(maps.first);
    }
    return null;
  }

  Future<List<Booking>> getBookingsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      bookingsTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => _mapToBooking(maps[i]));
  }

  Future<List<Booking>> getBookingsByCarId(String carId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      bookingsTable,
      where: 'carId = ?',
      whereArgs: [carId],
    );
    return List.generate(maps.length, (i) => _mapToBooking(maps[i]));
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await database;
    return await db.update(
      bookingsTable,
      _bookingToMap(booking),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> deleteBooking(String id) async {
    final db = await database;
    return await db.delete(
      bookingsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Support Request CRUD operations
  Future<int> insertSupportRequest(SupportRequest request) async {
    final db = await database;
    return await db.insert(supportRequestsTable, _supportRequestToMap(request), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SupportRequest>> getAllSupportRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(supportRequestsTable);
    return List.generate(maps.length, (i) => _mapToSupportRequest(maps[i]));
  }

  Future<SupportRequest?> getSupportRequestById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      supportRequestsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToSupportRequest(maps.first);
    }
    return null;
  }

  Future<List<SupportRequest>> getSupportRequestsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      supportRequestsTable,
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) => _mapToSupportRequest(maps[i]));
  }

  Future<int> updateSupportRequest(SupportRequest request) async {
    final db = await database;
    return await db.update(
      supportRequestsTable,
      _supportRequestToMap(request),
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  Future<int> deleteSupportRequest(String id) async {
    final db = await database;
    return await db.delete(
      supportRequestsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Helper methods for data conversion
  Map<String, dynamic> _userToMap(User user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'password': user.password,
      'profileImage': user.profileImage,
      'address': user.address,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLogin': user.lastLogin?.toIso8601String(),
      'isActive': user.isActive ? 1 : 0,
      'userType': user.userType,
      'preferences': user.preferences.toString(),
      'favoriteCarIds': user.favoriteCarIds.toString(),
      'registrationStatus': user.registrationStatus,
      'idNumber': user.idNumber,
      'isIdVerified': user.isIdVerified ? 1 : 0,
      'idType': user.idType,
    };
  }

  User _mapToUser(Map<String, dynamic> map) {
    Map<String, dynamic> preferences = {};
    if (map['preferences'] != null && map['preferences'] is String && map['preferences'].isNotEmpty) {
      try {
        preferences = Map<String, dynamic>.from(json.decode(map['preferences']));
      } catch (e) {
        print('Error parsing preferences: $e');
      }
    }

    List<String> favoriteCarIds = [];
    if (map['favoriteCarIds'] != null && map['favoriteCarIds'] is String && map['favoriteCarIds'].isNotEmpty) {
      try {
        favoriteCarIds = List<String>.from(json.decode(map['favoriteCarIds']));
      } catch (e) {
        print('Error parsing favoriteCarIds: $e');
      }
    }

    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
      profileImage: map['profileImage'],
      address: map['address'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
      isActive: map['isActive'] == 1,
      userType: map['userType'],
      preferences: preferences,
      favoriteCarIds: favoriteCarIds,
      registrationStatus: map['registrationStatus'],
      idNumber: map['idNumber'],
      isIdVerified: map['isIdVerified'] == 1,
      idType: map['idType'],
    );
  }

  Map<String, dynamic> _carToMap(Car car) {
    return {
      'id': car.id,
      'brand': car.brand,
      'model': car.model,
      'year': car.year,
      'imagePath': car.imagePath,
      'pricePerDay': car.pricePerDay,
      'transmission': car.transmission,
      'fuelType': car.fuelType,
      'seats': car.seats,
      'category': car.category,
      'available': car.available ? 1 : 0,
      'description': car.description,
    };
  }

  Car _mapToCar(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      imagePath: map['imagePath'],
      pricePerDay: map['pricePerDay'],
      transmission: map['transmission'],
      fuelType: map['fuelType'],
      seats: map['seats'],
      category: map['category'],
      available: map['available'] == 1,
      description: map['description'],
    );
  }

  Map<String, dynamic> _bookingToMap(Booking booking) {
    return {
      'id': booking.id,
      'carId': booking.carId,
      'carName': booking.carName,
      'carImage': booking.carImage,
      'startDate': booking.startDate.toIso8601String(),
      'endDate': booking.endDate.toIso8601String(),
      'pickupTime': booking.pickupTime,
      'totalPrice': booking.totalPrice,
      'status': booking.status,
      'createdAt': booking.createdAt.toIso8601String(),
      'paymentMethod': booking.paymentMethod,
      'paymentDetails': booking.paymentDetails.toString(),
      'isBeingTracked': booking.isBeingTracked ? 1 : 0,
      'currentLatitude': booking.currentLatitude,
      'currentLongitude': booking.currentLongitude,
      'userId': booking.userId,
      'userName': booking.userName,
      'userEmail': booking.userEmail,
      'userPhone': booking.userPhone,
    };
  }

  Booking _mapToBooking(Map<String, dynamic> map) {
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
      paymentMethod: map['paymentMethod'],
      paymentDetails: Map<String, dynamic>.from(map['paymentDetails'] != null ? {} : {}),
      isBeingTracked: map['isBeingTracked'] == 1,
      currentLatitude: map['currentLatitude'],
      currentLongitude: map['currentLongitude'],
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      userPhone: map['userPhone'],
    );
  }

  Map<String, dynamic> _supportRequestToMap(SupportRequest request) {
    return {
      'id': request.id,
      'customerName': request.customerName,
      'customerEmail': request.customerEmail,
      'customerPhone': request.customerPhone,
      'subject': request.subject,
      'message': request.message,
      'status': request.status,
      'priority': request.priority,
      'createdAt': request.createdAt.toIso8601String(),
      'updatedAt': request.updatedAt?.toIso8601String(),
    };
  }

  SupportRequest _mapToSupportRequest(Map<String, dynamic> map) {
    return SupportRequest(
      id: map['id'],
      customerName: map['customerName'],
      customerEmail: map['customerEmail'],
      customerPhone: map['customerPhone'],
      subject: map['subject'],
      message: map['message'],
      status: map['status'],
      priority: map['priority'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Utility methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(supportRequestsTable);
    await db.delete(bookingsTable);
    await db.delete(carsTable);
    await db.delete(usersTable);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
