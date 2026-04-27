import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBQO-_kGPCbv_GLDgUOl3SixYB-KSnqa8g',
    appId: '1:1092998218342:web:f156473195312766e9e3a7',
    messagingSenderId: '1092998218342',
    projectId: 'zafafi-wedding-app',
    authDomain: 'zafafi-wedding-app.firebaseapp.com',
    storageBucket: 'zafafi-wedding-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQO-_kGPCbv_GLDgUOl3SixYB-KSnqa8g',
    appId: '1:1092998218342:web:f156473195312766e9e3a7',
    messagingSenderId: '1092998218342',
    projectId: 'zafafi-wedding-app',
    storageBucket: 'zafafi-wedding-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQO-_kGPCbv_GLDgUOl3SixYB-KSnqa8g',
    appId: '1:1092998218342:web:f156473195312766e9e3a7',
    messagingSenderId: '1092998218342',
    projectId: 'zafafi-wedding-app',
    storageBucket: 'zafafi-wedding-app.firebasestorage.app',
    iosBundleId: 'com.example.test101',
  );
}
