// Archivo generado por FlutterFire CLI.
// ignora-para-archivo: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones predeterminadas de [FirebaseOptions] para usar con tus apps de Firebase.
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
          'DefaultFirebaseOptions no ha sido configurado para linux - '
          'puedes reconfigurarlo ejecutando nuevamente FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no es compatible con esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWoPVCH9gN9PgD6mxiYRyEZw7zIZXCNaU',
    appId: '1:706249849844:web:c571150bbe2308428397a1',
    messagingSenderId: '706249849844',
    projectId: 'horariostutorias7mo',
    authDomain: 'horariostutorias7mo.firebaseapp.com',
    storageBucket: 'horariostutorias7mo.firebasestorage.app',
    measurementId: 'G-48ZZ8PCE2W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgtbPHkoYos6GRZyOEls0ocyHBzTFOmXw',
    appId: '1:706249849844:android:efcd169c34d659498397a1',
    messagingSenderId: '706249849844',
    projectId: 'horariostutorias7mo',
    storageBucket: 'horariostutorias7mo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkM_qkcZourI8pilZ6EdasdximW4zFk8U',
    appId: '1:706249849844:ios:9811175b57e6e2228397a1',
    messagingSenderId: '706249849844',
    projectId: 'horariostutorias7mo',
    storageBucket: 'horariostutorias7mo.firebasestorage.app',
    iosClientId:
        '706249849844-a83hom9hqi9nmgjuj6h3v5a78l5p0kj3.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDkM_qkcZourI8pilZ6EdasdximW4zFk8U',
    appId: '1:706249849844:ios:9811175b57e6e2228397a1',
    messagingSenderId: '706249849844',
    projectId: 'horariostutorias7mo',
    storageBucket: 'horariostutorias7mo.firebasestorage.app',
    iosClientId:
        '706249849844-a83hom9hqi9nmgjuj6h3v5a78l5p0kj3.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBWoPVCH9gN9PgD6mxiYRyEZw7zIZXCNaU',
    appId: '1:706249849844:web:29c791217cdcfefa8397a1',
    messagingSenderId: '706249849844',
    projectId: 'horariostutorias7mo',
    authDomain: 'horariostutorias7mo.firebaseapp.com',
    storageBucket: 'horariostutorias7mo.firebasestorage.app',
    measurementId: 'G-Q70RDYSBL6',
  );
}
