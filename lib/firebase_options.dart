import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCfoJqmlcwTmEG3FvlDb4OBCJm6yBDqpHg',
    appId: '1:602195181881:web:9cb86831c55ec5422d68e8',
    messagingSenderId: '602195181881',
    projectId: 'padel_management_system-b6b67',
    authDomain: 'padel_management_system-b6b67.firebaseapp.com',
    storageBucket: 'padel_management_system-b6b67.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCfoJqmlcwTmEG3FvlDb4OBCJm6yBDqpHg',
    appId: '1:602195181881:android:9cb86831c55ec5422d68e8',
    messagingSenderId: '602195181881',
    projectId: 'padel_management_system-b6b67',
    storageBucket: 'padel_management_system-b6b67.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCfoJqmlcwTmEG3FvlDb4OBCJm6yBDqpHg',
    appId: '1:602195181881:ios:9cb86831c55ec5422d68e8',
    messagingSenderId: '602195181881',
    projectId: 'padel_management_system-b6b67',
    storageBucket: 'padel_management_system-b6b67.firebasestorage.app',
    iosBundleId: 'com.example.padel_management_system',
  );
}
