import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/car.dart';
import '../services/booking_service.dart';
import 'database_helper.dart';
import '../utils/performance_monitor.dart';

class CarServiceOptimized with ChangeNotifier {
  final BookingService _bookingService;
  Timer? _availabilityTimer;
  DateTime _lastUpdateTime = DateTime.now();
  bool _isDisposed = false;

  // Efficient data structures
  final List<Car> _cars = [];
  final Map<String, Car> _carMap = {}; // O(1) lookups
  final Map<String, bool> _availabilityCache = {}; // Cache availability status
  final Map<String, DateTime> _cacheTimestamps = {}; // Cache timestamps

  // Configuration
  static const Duration _cacheValidityDuration = Duration(minutes: 5);
  static const Duration _availabilityCheckInterval = Duration(
    seconds: 30,
  ); // Less frequent updates

  // Performance metrics
  int _totalLookups = 0;
  int _cacheHits = 0;
  int _databaseQueries = 0;

  CarServiceOptimized(this._bookingService) {
    // Load static cars initially to ensure immediate availability
    _cars.addAll(_staticCars);
    _carMap.addAll({for (var car in _staticCars) car.id: car});
    _initializeService();
  }

  void _initializeService() async {
    try {
      await _loadCarsFromDatabase();
      _initializeAvailabilityCache();

      // Start periodic availability check with optimized interval
      _availabilityTimer = Timer.periodic(_availabilityCheckInterval, (timer) {
        if (!_isDisposed) {
          _updateCarAvailabilityOptimized();
        }
      });

      // Listen to booking service changes for immediate updates
      _bookingService.addListener(_onBookingServiceChanged);

      print('CarServiceOptimized initialized with ${_cars.length} cars');
    } catch (e) {
      print('Error initializing CarServiceOptimized: $e');
    }
  }

  void _onBookingServiceChanged() {
    // Clear availability cache when bookings change
    _availabilityCache.clear();
    _cacheTimestamps.clear();

    if (!_isDisposed) {
      _updateCarAvailabilityOptimized();
    }
  }

  // Static car data (kept for initial seeding) - Now using all available car images
  static final List<Car> _staticCars = [
    // Toyota Camry
    Car(
      id: '1',
      brand: 'Toyota',
      model: 'Camry',
      year: 2023,
      imagePath: 'assets/camaro_0.png',
      pricePerDay: 85.99,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Sedan',
      available: true,
      description: 'Comfortable and reliable sedan perfect for city driving.',
    ),
    // Honda Civic
    Car(
      id: '2',
      brand: 'Honda',
      model: 'Civic',
      year: 2023,
      imagePath: 'assets/honda_0.png',
      pricePerDay: 75.99,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Sedan',
      available: true,
      description: 'Fuel-efficient compact sedan with excellent mileage.',
    ),
    // BMW X3
    Car(
      id: '3',
      brand: 'BMW',
      model: 'X3',
      year: 2023,
      imagePath: 'assets/bmw_1.png',
      pricePerDay: 120.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description:
          'Luxurious SUV with premium features and sporty performance.',
    ),
    // BMW Additional
    Car(
      id: '16',
      brand: 'BMW',
      model: 'X5',
      year: 2023,
      imagePath: 'assets/bmw_2.jpeg',
      pricePerDay: 135.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Premium SUV with exceptional comfort and technology.',
    ),
    Car(
      id: '17',
      brand: 'BMW',
      model: 'M3',
      year: 2023,
      imagePath: 'assets/bmw_3.jpeg',
      pricePerDay: 180.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'High-performance sports sedan with legendary M power.',
    ),
    Car(
      id: '18',
      brand: 'BMW',
      model: 'i8',
      year: 2023,
      imagePath: 'assets/bmw_4.jpeg',
      pricePerDay: 220.00,
      transmission: 'Automatic',
      fuelType: 'Hybrid',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'Revolutionary hybrid sports car with futuristic design.',
    ),
    // Audi A4
    Car(
      id: '4',
      brand: 'Audi',
      model: 'A4',
      year: 2023,
      imagePath: 'assets/audi_1.png',
      pricePerDay: 110.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Sedan',
      available: true,
      description: 'Elegant sedan with advanced technology and comfort.',
    ),
    // Audi Additional
    Car(
      id: '19',
      brand: 'Audi',
      model: 'Q5',
      year: 2023,
      imagePath: 'assets/audi_3.jpeg',
      pricePerDay: 125.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Luxurious SUV with quattro all-wheel drive system.',
    ),
    Car(
      id: '20',
      brand: 'Audi',
      model: 'R8',
      year: 2023,
      imagePath: 'assets/audi_4.jpeg',
      pricePerDay: 250.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 2,
      category: 'Supercar',
      available: true,
      description: 'Mid-engine supercar with breathtaking performance.',
    ),
    Car(
      id: '21',
      brand: 'Audi',
      model: 'A3',
      year: 2023,
      imagePath: 'assets/audi.jpeg',
      pricePerDay: 95.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Hatchback',
      available: true,
      description: 'Compact premium hatchback with sporty dynamics.',
    ),
    // Tesla Model 3
    Car(
      id: '5',
      brand: 'Tesla',
      model: 'Model 3',
      year: 2023,
      imagePath: 'assets/tesla_1.png',
      pricePerDay: 140.00,
      transmission: 'Automatic',
      fuelType: 'Electric',
      seats: 5,
      category: 'Sedan',
      available: true,
      description:
          'Electric sedan with cutting-edge technology and zero emissions.',
    ),
    // Tesla Additional
    Car(
      id: '22',
      brand: 'Tesla',
      model: 'Model Y',
      year: 2023,
      imagePath: 'assets/tesla_2.jpeg',
      pricePerDay: 155.00,
      transmission: 'Automatic',
      fuelType: 'Electric',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Electric SUV with exceptional range and utility.',
    ),
    Car(
      id: '23',
      brand: 'Tesla',
      model: 'Model S',
      year: 2023,
      imagePath: 'assets/tesla_3.jpeg',
      pricePerDay: 175.00,
      transmission: 'Automatic',
      fuelType: 'Electric',
      seats: 5,
      category: 'Sedan',
      available: true,
      description: 'Luxury electric sedan with premium features.',
    ),
    Car(
      id: '24',
      brand: 'Tesla',
      model: 'Model X',
      year: 2023,
      imagePath: 'assets/tesla_4.jpeg',
      pricePerDay: 195.00,
      transmission: 'Automatic',
      fuelType: 'Electric',
      seats: 7,
      category: 'SUV',
      available: true,
      description: 'Electric SUV with falcon wing doors and premium interior.',
    ),
    Car(
      id: '25',
      brand: 'Advantage',
      model: 'Sedan',
      year: 2023,
      imagePath: 'assets/advantage.jpg',
      pricePerDay: 165.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Sedan',
      available: true,
      description: 'Comfortable and reliable sedan perfect for city driving.',
    ),
    // Ferrari Spider 488
    Car(
      id: '6',
      brand: 'Ferrari',
      model: 'Spider 488',
      year: 2023,
      imagePath: 'assets/ferrari_spider_488_0.png',
      pricePerDay: 500.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 2,
      category: 'Supercar',
      available: true,
      description: 'Exotic sports car with unmatched performance and design.',
    ),
    // Ferrari Additional
    Car(
      id: '26',
      brand: 'Ferrari',
      model: '488 GTB',
      year: 2023,
      imagePath: 'assets/ferrari_spider_488_1.png',
      pricePerDay: 480.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 2,
      category: 'Supercar',
      available: true,
      description: 'Coupe version of the legendary 488 with turbo V8.',
    ),
    Car(
      id: '27',
      brand: 'Ferrari',
      model: '488 Spider',
      year: 2023,
      imagePath: 'assets/ferrari_spider_488_2.png',
      pricePerDay: 520.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 2,
      category: 'Supercar',
      available: true,
      description: 'Convertible supercar with retractable hardtop.',
    ),
    Car(
      id: '28',
      brand: 'Ferrari',
      model: '488 Challenge',
      year: 2023,
      imagePath: 'assets/ferrari_spider_488_3.png',
      pricePerDay: 550.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 2,
      category: 'Supercar',
      available: true,
      description: 'Track-focused version with enhanced performance.',
    ),
    Car(
      id: '29',
      brand: 'Ferrari',
      model: '488 Pista',
      year: 2023,
      imagePath: 'assets/ferrari_spider_488_4.png',
      pricePerDay: 580.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 2,
      category: 'Supercar',
      available: true,
      description: 'Ultimate track version of the 488 with 710hp.',
    ),
    // Land Rover Range Rover
    Car(
      id: '7',
      brand: 'Land Rover',
      model: 'Range Rover',
      year: 2023,
      imagePath: 'assets/land_rover_0.png',
      pricePerDay: 180.00,
      transmission: 'Automatic',
      fuelType: 'Diesel',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Premium SUV with off-road capability and luxury interior.',
    ),
    // Land Rover Additional
    Car(
      id: '30',
      brand: 'Land Rover',
      model: 'Discovery',
      year: 2023,
      imagePath: 'assets/land_rover_1.png',
      pricePerDay: 165.00,
      transmission: 'Automatic',
      fuelType: 'Diesel',
      seats: 7,
      category: 'SUV',
      available: true,
      description: 'Versatile SUV with excellent off-road capability.',
    ),
    Car(
      id: '31',
      brand: 'Land Rover',
      model: 'Defender',
      year: 2023,
      imagePath: 'assets/land_rover_2.png',
      pricePerDay: 190.00,
      transmission: 'Manual',
      fuelType: 'Diesel',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Iconic off-road vehicle with legendary capability.',
    ),
    // Nissan GT-R
    Car(
      id: '8',
      brand: 'Nissan',
      model: 'GT-R',
      year: 2023,
      imagePath: 'assets/nissan_gtr_0.png',
      pricePerDay: 200.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'High-performance sports car with turbocharged engine.',
    ),
    // Nissan GT-R Additional
    Car(
      id: '32',
      brand: 'Nissan',
      model: 'GT-R NISMO',
      year: 2023,
      imagePath: 'assets/nissan_gtr_1.png',
      pricePerDay: 230.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'Ultimate performance version of the GT-R.',
    ),
    Car(
      id: '33',
      brand: 'Nissan',
      model: 'GT-R Track',
      year: 2023,
      imagePath: 'assets/nissan_gtr_2.png',
      pricePerDay: 250.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 2,
      category: 'Sports',
      available: true,
      description: 'Track-focused GT-R with enhanced aerodynamics.',
    ),
    Car(
      id: '34',
      brand: 'Nissan',
      model: 'GT-R Premium',
      year: 2023,
      imagePath: 'assets/nissan_gtr_3.png',
      pricePerDay: 220.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'Premium version with luxury features and AWD.',
    ),
    // Acura MDX
    Car(
      id: '9',
      brand: 'Acura',
      model: 'MDX',
      year: 2023,
      imagePath: 'assets/acura_mdx_2023.png',
      pricePerDay: 130.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 7,
      category: 'SUV',
      available: true,
      description: 'Spacious SUV with advanced safety features and comfort.',
    ),
    // Acura Additional
    Car(
      id: '35',
      brand: 'Acura',
      model: 'TLX',
      year: 2023,
      imagePath: 'assets/acura_tlx_2023.png',
      pricePerDay: 115.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Sedan',
      available: true,
      description: 'Luxury sedan with precision handling and technology.',
    ),
    Car(
      id: '36',
      brand: 'Acura',
      model: 'NSX',
      year: 2023,
      imagePath: 'assets/acura_2.png',
      pricePerDay: 280.00,
      transmission: 'Automatic',
      fuelType: 'Hybrid',
      seats: 2,
      category: 'Supercar',
      available: true,
      description: 'Hybrid supercar with revolutionary technology.',
    ),
    // Chevrolet Camaro
    Car(
      id: '10',
      brand: 'Chevrolet',
      model: 'Camaro',
      year: 2023,
      imagePath: 'assets/camaro_1.png',
      pricePerDay: 150.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'Iconic American muscle car with powerful V8 engine.',
    ),
    // Chevrolet Camaro Additional
    Car(
      id: '37',
      brand: 'Chevrolet',
      model: 'Camaro SS',
      year: 2023,
      imagePath: 'assets/camaro_2.png',
      pricePerDay: 170.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'High-performance SS version with 6.2L V8.',
    ),
    // Citroen C4
    Car(
      id: '11',
      brand: 'Citroen',
      model: 'C4',
      year: 2023,
      imagePath: 'assets/citroen_0.png',
      pricePerDay: 70.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Hatchback',
      available: true,
      description: 'Practical hatchback with unique design and comfort.',
    ),
    // Citroen Additional
    Car(
      id: '38',
      brand: 'Citroen',
      model: 'C3',
      year: 2023,
      imagePath: 'assets/citroen_1.png',
      pricePerDay: 65.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Hatchback',
      available: true,
      description: 'Compact city car with distinctive styling.',
    ),
    Car(
      id: '39',
      brand: 'Citroen',
      model: 'C5 Aircross',
      year: 2023,
      imagePath: 'assets/citroen_2.png',
      pricePerDay: 85.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Comfortable SUV with advanced suspension system.',
    ),
    // Fiat 500
    Car(
      id: '12',
      brand: 'Fiat',
      model: '500',
      year: 2023,
      imagePath: 'assets/fiat_0.png',
      pricePerDay: 60.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Hatchback',
      available: true,
      description: 'Stylish and economical city car with Italian charm.',
    ),
    // Fiat Additional
    Car(
      id: '40',
      brand: 'Fiat',
      model: '500X',
      year: 2023,
      imagePath: 'assets/fiat_1.png',
      pricePerDay: 75.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Crossover version of the iconic 500 with more space.',
    ),
    // Ford Mustang
    Car(
      id: '13',
      brand: 'Ford',
      model: 'Mustang',
      year: 2023,
      imagePath: 'assets/ford_0.png',
      pricePerDay: 160.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'Legendary sports car with American heritage and power.',
    ),
    // Ford Additional
    Car(
      id: '41',
      brand: 'Ford',
      model: 'Mustang GT',
      year: 2023,
      imagePath: 'assets/ford_1.png',
      pricePerDay: 180.00,
      transmission: 'Manual',
      fuelType: 'Gasoline',
      seats: 4,
      category: 'Sports',
      available: true,
      description: 'High-performance GT version with 5.0L V8.',
    ),
    // Alfa Romeo Giulia
    Car(
      id: '14',
      brand: 'Alfa Romeo',
      model: 'Giulia',
      year: 2023,
      imagePath: 'assets/alfa_romeo_c4_0.png',
      pricePerDay: 125.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'Sedan',
      available: true,
      description: 'Italian sedan with sporty performance and luxury.',
    ),
    // Lamborghini Huracan
    Car(
      id: '15',
      brand: 'Lamborghini',
      model: 'Huracan',
      year: 2023,
      imagePath: 'assets/lambo.jpg',
      pricePerDay: 600.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 2,
      category: 'Supercar',
      available: true,
      description: 'Exotic supercar with breathtaking speed and design.',
    ),
    // SUV Collection
    Car(
      id: '42',
      brand: 'Jeep',
      model: 'Grand Cherokee',
      year: 2023,
      imagePath: 'assets/suv_1.png',
      pricePerDay: 140.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Legendary SUV with exceptional off-road capability.',
    ),
    Car(
      id: '43',
      brand: 'Mercedes-Benz',
      model: 'GLE',
      year: 2023,
      imagePath: 'assets/suv_2.jpeg',
      pricePerDay: 155.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Luxury SUV with premium comfort and technology.',
    ),
    Car(
      id: '44',
      brand: 'Volvo',
      model: 'XC90',
      year: 2023,
      imagePath: 'assets/suv_3.jpeg',
      pricePerDay: 145.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 7,
      category: 'SUV',
      available: true,
      description: 'Safe and comfortable SUV with Scandinavian design.',
    ),
    Car(
      id: '45',
      brand: 'Porsche',
      model: 'Cayenne',
      year: 2023,
      imagePath: 'assets/suv_4.jpeg',
      pricePerDay: 185.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'High-performance SUV with sports car dynamics.',
    ),
    // Additional Luxury Cars
    Car(
      id: '46',
      brand: 'Lexus',
      model: 'RX',
      year: 2023,
      imagePath: 'assets/lex.jpg',
      pricePerDay: 135.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Luxury SUV with exceptional comfort and refinement.',
    ),
    Car(
      id: '47',
      brand: 'Lincoln',
      model: 'Navigator',
      year: 2023,
      imagePath: 'assets/la.jpg',
      pricePerDay: 175.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 8,
      category: 'SUV',
      available: true,
      description: 'Full-size luxury SUV with premium amenities.',
    ),
    Car(
      id: '48',
      brand: 'Cadillac',
      model: 'Escalade',
      year: 2023,
      imagePath: 'assets/lam.jpg',
      pricePerDay: 195.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 8,
      category: 'SUV',
      available: true,
      description: 'Iconic American luxury SUV with powerful presence.',
    ),
    Car(
      id: '49',
      brand: 'Bentley',
      model: 'Bentayga',
      year: 2023,
      imagePath: 'assets/urs.jpg',
      pricePerDay: 350.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'Ultra-luxury SUV with handcrafted British excellence.',
    ),
    Car(
      id: '50',
      brand: 'Rolls-Royce',
      model: 'Cullinan',
      year: 2023,
      imagePath: 'assets/cv.jpg',
      pricePerDay: 450.00,
      transmission: 'Automatic',
      fuelType: 'Gasoline',
      seats: 5,
      category: 'SUV',
      available: true,
      description: 'The pinnacle of luxury SUVs with unmatched refinement.',
    ),
  ];

  // Optimized car loading with batch operations
  Future<void> _loadCarsFromDatabase() async {
    PerformanceMonitor().startOperation('loadCarsFromDatabase');
    try {
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      final cars = await dbHelper.getAllCars();

      if (cars.isEmpty) {
        // Seed database with static data using batch insert
        await _seedDatabaseWithCars();
        // Reload after seeding
        final seededCars = await dbHelper.getAllCars();
        _updateCarCollections(seededCars);
      } else {
        _updateCarCollections(cars);
      }

      _databaseQueries++;
      notifyListeners();
      PerformanceMonitor().endOperation(
        'loadCarsFromDatabase',
        details: 'Loaded ${cars.length} cars',
      );
    } catch (e) {
      print('Error loading cars from database: $e');
      // Fallback to static data
      _updateCarCollections(_staticCars);
      PerformanceMonitor().endOperation(
        'loadCarsFromDatabase',
        details: 'Error: $e',
      );
    }
  }

  Future<void> _seedDatabaseWithCars() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    // Use batch insert for better performance
    await dbHelper.insertCarsBatch(_staticCars);
  }

  void _updateCarCollections(List<Car> cars) {
    _cars.clear();
    _carMap.clear();
    _cars.addAll(cars);

    // Build efficient lookup map
    for (final car in cars) {
      _carMap[car.id] = car;
    }
  }

  void _initializeAvailabilityCache() {
    final now = DateTime.now();
    for (final car in _cars) {
      _availabilityCache[car.id] = car.available;
      _cacheTimestamps[car.id] = now;
    }
  }

  // Optimized availability updates with batch processing
  void _updateCarAvailabilityOptimized() {
    PerformanceMonitor().startOperation('updateCarAvailability');
    final now = DateTime.now();
    final List<String> carsToUpdate = [];
    bool availabilityChanged = false;

    // Check which cars need availability updates
    for (final car in _cars) {
      final cacheTimestamp = _cacheTimestamps[car.id];
      if (cacheTimestamp == null ||
          now.difference(cacheTimestamp) > _cacheValidityDuration) {
        carsToUpdate.add(car.id);
      }
    }

    // Batch update availability for cars that need it
    if (carsToUpdate.isNotEmpty) {
      for (final carId in carsToUpdate) {
        final car = _carMap[carId];
        bool isAvailable = true;

        // First check if car exists and is marked as available
        if (car != null) {
          isAvailable = car.available;
        }

        // Then check for active bookings - if there is an active booking, car is not available
        if (isAvailable) {
          isAvailable = !_bookingService.hasActiveBooking(carId);
        }

        final wasAvailable = _availabilityCache[carId] ?? true;

        if (isAvailable != wasAvailable) {
          _availabilityCache[carId] = isAvailable;
          availabilityChanged = true;

          // Update car object
          final carIndex = _cars.indexWhere((car) => car.id == carId);
          if (carIndex != -1) {
            _cars[carIndex] = _cars[carIndex].copyWith(available: isAvailable);
          }
        }

        _cacheTimestamps[carId] = now;
      }
    }

    if (availabilityChanged && !_isDisposed) {
      _lastUpdateTime = now;
      notifyListeners();
    }
    PerformanceMonitor().endOperation(
      'updateCarAvailability',
      details: 'Updated ${carsToUpdate.length} cars',
    );
  }

  // Public API methods with optimizations

  List<Car> getAllCars() {
    _totalLookups++;
    return List.unmodifiable(_cars); // Prevent external modifications
  }

  List<Car> getFeaturedCars() {
    _totalLookups++;
    // Use actual car IDs from the static data for featured cars
    const featuredIds = [
      '1',
      '3',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '25',
    ]; // Toyota Camry, BMW X3, Tesla Model 3, Ferrari Spider, Land Rover, Nissan GT-R, Acura MDX, Chevrolet Camaro, Advantage
    return featuredIds
        .where((id) => _carMap.containsKey(id))
        .map((id) => _carMap[id]!)
        .toList();
  }

  List<Car> searchCars(String query) {
    _totalLookups++;
    if (query.isEmpty) return getAllCars();

    final lowerQuery = query.toLowerCase();
    return _cars
        .where(
          (car) =>
              car.brand.toLowerCase().contains(lowerQuery) ||
              car.model.toLowerCase().contains(lowerQuery) ||
              car.category.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  List<Car> filterCars({
    String? category,
    double? maxPrice,
    bool? availableOnly,
  }) {
    _totalLookups++;
    return _cars.where((car) {
      bool matchesCategory = category == null || car.category == category;
      bool matchesPrice = maxPrice == null || car.pricePerDay <= maxPrice;
      bool matchesAvailability =
          availableOnly == null || car.available == availableOnly;
      return matchesCategory && matchesPrice && matchesAvailability;
    }).toList();
  }

  Car? getCarById(String id) {
    _totalLookups++;
    final car = _carMap[id];
    if (car != null) {
      _cacheHits++;
    }
    return car;
  }

  // Cached availability check
  bool getCarAvailability(String carId) {
    final cached = _availabilityCache[carId];
    final cacheTimestamp = _cacheTimestamps[carId];

    if (cached != null && cacheTimestamp != null) {
      final now = DateTime.now();
      if (now.difference(cacheTimestamp) < _cacheValidityDuration) {
        _cacheHits++;
        return cached;
      }
    }

    // Fallback to real-time check
    final now = DateTime.now();
    final car = _carMap[carId];
    bool isAvailable = true;

    // First check if car exists and is marked as available
    if (car != null) {
      isAvailable = car.available;
    }

    // Then check for active bookings - if there is an active booking, car is not available
    if (isAvailable) {
      isAvailable = !_bookingService.hasActiveBooking(carId);
    }

    _availabilityCache[carId] = isAvailable;
    _cacheTimestamps[carId] = now;
    return isAvailable;
  }

  // Batch availability check for multiple cars
  Map<String, bool> getCarsAvailability(List<String> carIds) {
    final result = <String, bool>{};
    final now = DateTime.now();

    for (final carId in carIds) {
      final cached = _availabilityCache[carId];
      final cacheTimestamp = _cacheTimestamps[carId];

      if (cached != null &&
          cacheTimestamp != null &&
          now.difference(cacheTimestamp) < _cacheValidityDuration) {
        result[carId] = cached;
        _cacheHits++;
      } else {
        // Real-time check
        final car = _carMap[carId];
        bool isAvailable = true;

        // First check if car exists and is marked as available
        if (car != null) {
          isAvailable = car.available;
        }

        // Then check for active bookings - if there is an active booking, car is not available
        if (isAvailable) {
          isAvailable = !_bookingService.hasActiveBooking(carId);
        }

        result[carId] = isAvailable;
        _availabilityCache[carId] = isAvailable;
        _cacheTimestamps[carId] = now;
      }
    }

    return result;
  }

  // Performance monitoring methods
  Map<String, dynamic> getPerformanceMetrics() {
    final cacheHitRate = _totalLookups > 0
        ? (_cacheHits / _totalLookups) * 100
        : 0.0;
    return {
      'totalLookups': _totalLookups,
      'cacheHits': _cacheHits,
      'cacheHitRate': '${cacheHitRate.toStringAsFixed(1)}%',
      'databaseQueries': _databaseQueries,
      'cachedCars': _availabilityCache.length,
      'lastUpdate': _lastUpdateTime.toIso8601String(),
    };
  }

  void resetPerformanceMetrics() {
    _totalLookups = 0;
    _cacheHits = 0;
    _databaseQueries = 0;
  }

  // Enhanced availability summary with caching
  String getAvailabilitySummary() {
    final availableCount = _cars
        .where((car) => getCarAvailability(car.id))
        .length;
    final totalCount = _cars.length;
    final percentage = (availableCount / totalCount * 100).toStringAsFixed(1);

    return '$availableCount/$totalCount cars available ($percentage%) - Updated ${_lastUpdateTime.hour}:${_lastUpdateTime.minute.toString().padLeft(2, '0')}';
  }

  // Optimized update method with batch saving
  Future<void> updateCarAvailability(String carId, bool isAvailable) async {
    final index = _cars.indexWhere((car) => car.id == carId);
    if (index != -1 && !_isDisposed) {
      _cars[index] = _cars[index].copyWith(available: isAvailable);
      _availabilityCache[carId] = isAvailable;
      _cacheTimestamps[carId] = DateTime.now();

      // Batch save to database
      await _saveCarsToDatabase();
      notifyListeners();
    }
  }

  Future<void> _saveCarsToDatabase() async {
    try {
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      await dbHelper.updateCarsBatch(_cars);
      _databaseQueries++;
    } catch (e) {
      print('Error saving cars to database: $e');
    }
  }

  // Public method to trigger availability update
  void updateCarAvailabilityNow() {
    if (!_isDisposed) {
      _updateCarAvailabilityOptimized();
    }
  }

  // Update car availability when booking status changes
  void updateCarAvailabilityForBooking(String carId) {
    if (_isDisposed) return;

    final now = DateTime.now();
    final car = _carMap[carId];

    if (car != null) {
      // Check if car has active bookings
      final hasActiveBooking = _bookingService.hasActiveBooking(carId);
      final newAvailability = !hasActiveBooking;

      // Update cache and car object
      _availabilityCache[carId] = newAvailability;
      _cacheTimestamps[carId] = now;

      final carIndex = _cars.indexWhere((car) => car.id == carId);
      if (carIndex != -1) {
        _cars[carIndex] = _cars[carIndex].copyWith(available: newAvailability);
        notifyListeners();
      }

      print('Updated availability for car $carId: $newAvailability');
    }
  }

  // Get last update time
  DateTime getLastUpdateTime() {
    return _lastUpdateTime;
  }

  // Get available cars count by category
  int getAvailableCarsCountByCategory(String category) {
    return _cars
        .where((car) => car.category == category && getCarAvailability(car.id))
        .length;
  }

  // Add new car to the fleet
  Future<bool> addCar({
    required String brand,
    required String model,
    required int year,
    required String imagePath,
    required double pricePerDay,
    required String transmission,
    required String fuelType,
    required int seats,
    required String category,
    required String description,
    bool available = true,
  }) async {
    try {
      // Generate unique ID
      final id =
          '${brand.toLowerCase()}_${model.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';

      // Create new car object
      final newCar = Car(
        id: id,
        brand: brand,
        model: model,
        year: year,
        imagePath: imagePath,
        pricePerDay: pricePerDay,
        transmission: transmission,
        fuelType: fuelType,
        seats: seats,
        category: category,
        available: available,
        description: description,
      );

      // Insert into database
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.insertCar(newCar);

      if (result > 0) {
        // Add to in-memory collections
        _cars.add(newCar);
        _carMap[id] = newCar;
        _availabilityCache[id] = available;
        _cacheTimestamps[id] = DateTime.now();

        // Notify listeners
        if (!_isDisposed) {
          notifyListeners();
        }

        _databaseQueries++;
        return true;
      }

      return false;
    } catch (e) {
      print('Error adding car: $e');
      return false;
    }
  }

  // Cleanup and disposal
  @override
  void dispose() {
    _bookingService.removeListener(_onBookingServiceChanged);
    _availabilityTimer?.cancel();
    _availabilityCache.clear();
    _cacheTimestamps.clear();
    _isDisposed = true;
    super.dispose();
  }
}
