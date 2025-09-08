import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/car_list_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/availability_screen.dart';
import 'screens/contact_support_screen.dart';
import 'services/booking_service.dart';
import 'services/user_service.dart';
import 'services/car_service_optimized.dart';
import 'services/support_service.dart';
import 'providers/theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final Logger logger = Logger('HTURentalsApp');

void main() async {
  print('main() started');
  // Ensure proper initialization for web to prevent lifecycle channel issues
  WidgetsFlutterBinding.ensureInitialized();
  print('WidgetsFlutterBinding.ensureInitialized done');

  // Setup logging early to capture logs produced during initialization
  Logger.root.level = Level.ALL; // Log all levels
  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });

  print('Requesting permissions...');
  // Request runtime permissions for location and camera
  await _requestPermissions();
  print('Permissions requested');

  print('Initializing Firebase...');
  // Initialize Firebase only if not already initialized
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized');
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        print('Firebase already initialized (caught duplicate error)');
      } else {
        rethrow;
      }
    }
  } else {
    print('Firebase already initialized');
  }

  print('Requesting Firebase Messaging permission...');
  // Request notification permissions
  await FirebaseMessaging.instance.requestPermission();
  print('Firebase Messaging permission requested');

  print('Getting device token...');
  // Get device token and register it
  String? deviceToken = await FirebaseMessaging.instance.getToken();
  print('Device token: $deviceToken');
  if (deviceToken != null) {
    // Register device token for current user after app starts
    // Delay registration until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final userService = Provider.of<UserService>(context, listen: false);
        await userService.registerDeviceToken(deviceToken);
      }
    });
  }

  print('Setting up FirebaseMessaging onMessage listener...');
  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle notification (show dialog, update UI, etc.)
    print(
      'Received FCM message: ${message.notification?.title} - ${message.notification?.body}',
    );
    // Optionally show a dialog or snackbar here
  });

  print('Running app...');
  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  final statuses = await [Permission.location, Permission.camera].request();

  if (statuses[Permission.location] != PermissionStatus.granted) {
    print('Location permission not granted');
  }
  if (statuses[Permission.camera] != PermissionStatus.granted) {
    print('Camera permission not granted');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeProvider = ThemeProvider();
    // Set initial theme based on system brightness
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    _themeProvider.updateThemeFromSystem(brightness);

    logger.info('App initialized with system brightness: $brightness');

    // Log when the first Flutter frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.info('First Flutter frame rendered');
      print('First Flutter frame rendered');
    });
  }

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    _themeProvider.updateThemeFromSystem(brightness);
    logger.info('Platform brightness changed: $brightness');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    logger.info('App disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.fine('Building MyApp widget');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
        ChangeNotifierProvider(create: (context) => BookingService()),
        ChangeNotifierProvider(create: (context) => UserService()),
        ChangeNotifierProvider(create: (context) => SupportService()),
        ChangeNotifierProxyProvider<BookingService, CarServiceOptimized>(
          create: (context) => CarServiceOptimized(
            Provider.of<BookingService>(context, listen: false),
          ),
          update: (context, bookingService, carService) {
            if (carService == null) {
              return CarServiceOptimized(bookingService);
            }
            // Inject the carService into bookingService
            bookingService.carService = carService;
            return carService;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          logger.finer('Building MaterialApp with current theme');
          return MaterialApp(
            title: 'HTU Rentals',
            theme: themeProvider.currentTheme,
            home: const LoginScreen(),
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const MainNavigationScreen(),
              '/car_list': (context) => const CarListScreen(),
              '/bookings': (context) => const BookingsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/availability': (context) => const AvailabilityScreen(),
              '/contact_support': (context) => const ContactSupportScreen(),
            },
            initialRoute: '/login',
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      logger.fine('Bottom navigation item tapped: index $_selectedIndex');
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        logger.fine('Displaying HomeScreen');
        return HomeScreen();
      case 1:
        logger.fine('Displaying CarListScreen');
        return const CarListScreen();
      case 2:
        logger.fine('Displaying BookingsScreen');
        return const BookingsScreen();
      case 3:
        logger.fine('Displaying ProfileScreen');
        return const ProfileScreen();
      default:
        logger.warning(
          'Unknown navigation index $_selectedIndex, defaulting to HomeScreen',
        );
        return HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.finer('Building MainNavigationScreen widget');
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car_outlined),
                activeIcon: Icon(Icons.directions_car),
                label: 'Browse',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.6),
            backgroundColor: Theme.of(context).colorScheme.surface,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
