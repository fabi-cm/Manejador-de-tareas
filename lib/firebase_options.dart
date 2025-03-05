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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCb3uvI2Fn1Ibj611qm_QdlW6fTMDJhXMQ',
    appId: '1:674077705783:ios:f665576adc56b1c75661b2',
    messagingSenderId: '674077705783',
    projectId: 'db-manejo-de-tareas',
    storageBucket: 'db-manejo-de-tareas.firebasestorage.app',
    iosClientId: '674077705783-5ueqp1krbb4liqbt8bha4n7bqhhfl284.apps.googleusercontent.com',
    iosBundleId: 'com.example.taskManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQ5jkW3tuvLrYFwFrl9GABxQgikmEr-CA',
    appId: '1:572208784994:ios:f2dca3a9de4009bf08533b',
    messagingSenderId: '572208784994',
    projectId: 'prueba2-aa4f5',
    storageBucket: 'prueba2-aa4f5.firebasestorage.app',
    iosBundleId: 'com.example.taskManager',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0Gb4NBfxqUlET900mZTgoOVHBaEUJawY',
    appId: '1:674077705783:android:169b3a5d931469035661b2',
    messagingSenderId: '674077705783',
    projectId: 'db-manejo-de-tareas',
    storageBucket: 'db-manejo-de-tareas.firebasestorage.app',
  );

}