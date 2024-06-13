// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCaV4sHkbRs-LQ8Pz329JVWVL-hhAwhQ9E',
    appId: '1:308603792857:web:735e03accdb57cbf74bdc8',
    messagingSenderId: '308603792857',
    projectId: 'victorgonzbaj-nestapp',
    authDomain: 'victorgonzbaj-nestapp.firebaseapp.com',
    databaseURL: 'https://victorgonzbaj-nestapp-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'victorgonzbaj-nestapp.appspot.com',
    measurementId: 'G-BGLHF05YMT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAalXf6NYpcG_1M0XZEXFTqdC4zKvpsQ0w',
    appId: '1:308603792857:android:2f32acc5287caf8474bdc8',
    messagingSenderId: '308603792857',
    projectId: 'victorgonzbaj-nestapp',
    databaseURL: 'https://victorgonzbaj-nestapp-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'victorgonzbaj-nestapp.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCaV4sHkbRs-LQ8Pz329JVWVL-hhAwhQ9E',
    appId: '1:308603792857:web:e3d24698642d938074bdc8',
    messagingSenderId: '308603792857',
    projectId: 'victorgonzbaj-nestapp',
    authDomain: 'victorgonzbaj-nestapp.firebaseapp.com',
    databaseURL: 'https://victorgonzbaj-nestapp-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'victorgonzbaj-nestapp.appspot.com',
    measurementId: 'G-Q76J9VFDCJ',
  );

}