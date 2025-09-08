import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDASHR2FiPLLllcy7ofZJ-UJ3rfNuvocCM',
    appId:
        '1:1083544497063:web:your_web_app_id', // Replace with actual web app ID from Firebase console
    messagingSenderId: '1083544497063',
    projectId: 'car-rental-62719',
    authDomain: 'car-rental-62719.firebaseapp.com',
    storageBucket: 'car-rental-62719.firebasestorage.app',
    measurementId:
        'G-XXXXXXXXXX', // Replace with actual measurement ID if using Analytics
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDASHR2FiPLLllcy7ofZJ-UJ3rfNuvocCM',
    appId: '1:1083544497063:android:4bf9c729f25a6551122482',
    messagingSenderId: '1083544497063',
    projectId: 'car-rental-62719',
    storageBucket: 'car-rental-62719.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDASHR2FiPLLllcy7ofZJ-UJ3rfNuvocCM',
    appId: '1:1083544497063:ios:23103b230c858024122482',
    messagingSenderId: '1083544497063',
    projectId: 'car-rental-62719',
    storageBucket: 'car-rental-62719.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDASHR2FiPLLllcy7ofZJ-UJ3rfNuvocCM',
    appId:
        '1:1083544497063:macos:your_macos_app_id', // Replace with actual macOS app ID if needed
    messagingSenderId: '1083544497063',
    projectId: 'car-rental-62719',
    storageBucket: 'car-rental-62719.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDASHR2FiPLLllcy7ofZJ-UJ3rfNuvocCM',
    appId:
        '1:1083544497063:windows:your_windows_app_id', // Replace with actual Windows app ID if needed
    messagingSenderId: '1083544497063',
    projectId: 'car-rental-62719',
    storageBucket: 'car-rental-62719.firebasestorage.app',
  );
}
