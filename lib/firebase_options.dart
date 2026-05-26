import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase client config for `musallam-delivery-kw`.
/// Source: ../dpd adminpannel/dpdadmin/docs/firebase/
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeDbxBUMG6tOv6cwYVwvtWJ6dQPWsodH4',
    appId: '1:942102607123:android:2b709642cb7ab7a48096e6',
    messagingSenderId: '942102607123',
    projectId: 'musallam-delivery-kw',
    storageBucket: 'musallam-delivery-kw.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFBXrApqwtqTBrfHvDT-LuEGPP7JmGOVY',
    appId: '1:942102607123:ios:442ef4381a6480f48096e6',
    messagingSenderId: '942102607123',
    projectId: 'musallam-delivery-kw',
    storageBucket: 'musallam-delivery-kw.firebasestorage.app',
    iosBundleId: 'kw.musallam.delivery',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBQuT2-y1lQGImK_Bi8W-fCGmOkiqIX-wA',
    appId: '1:942102607123:web:6522f617aca8ff2f8096e6',
    messagingSenderId: '942102607123',
    projectId: 'musallam-delivery-kw',
    authDomain: 'musallam-delivery-kw.firebaseapp.com',
    storageBucket: 'musallam-delivery-kw.firebasestorage.app',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is not configured for $defaultTargetPlatform.',
        );
    }
  }
}
