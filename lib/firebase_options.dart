// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCILeO3Adsm2OJ4ZsJhVQujb3IL3WEnaXw',
    appId: '1:155002680380:web:9189d2566eaecb6986ff39',
    messagingSenderId: '155002680380',
    projectId: 'fir-panel-6af08',
    authDomain: 'fir-panel-6af08.firebaseapp.com',
    storageBucket: 'fir-panel-6af08.appspot.com',
    measurementId: 'G-17RMXLTZ6V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8-pMnD5XXrFU-IkWqMe5onPLi_cPQa2I',
    appId: '1:155002680380:android:70780a459ee04df486ff39',
    messagingSenderId: '155002680380',
    projectId: 'fir-panel-6af08',
    storageBucket: 'fir-panel-6af08.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAnaDi3cAfnUQfctYmvPQwv-qavjUTfGaw',
    appId: '1:155002680380:ios:bb1ce432c548013386ff39',
    messagingSenderId: '155002680380',
    projectId: 'fir-panel-6af08',
    storageBucket: 'fir-panel-6af08.appspot.com',
    iosClientId: '155002680380-4i5ae02gsc9pu201s3rms482jubuhke5.apps.googleusercontent.com',
    iosBundleId: 'com.souvikbiswas.flutterAuthentication',
  );
}
