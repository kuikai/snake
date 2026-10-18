/// Firebase options for project snake-4cb1c.
library;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Android is wired (google-services.json). iOS needs a real iOS app +
/// `ios/Runner/GoogleService-Info.plist` before this flips to true.
const bool kFirebaseAndroidConfigured = true;
const bool kFirebaseIosConfigured = false;

/// True when the *current* platform has Firebase config files.
bool get kFirebaseConfigured {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return kFirebaseAndroidConfigured;
    case TargetPlatform.iOS:
      return kFirebaseIosConfigured;
    default:
      return false;
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web in Snake.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase iOS is not configured. Add an iOS app in Firebase Console, '
          'place GoogleService-Info.plist under ios/Runner/, set '
          'kFirebaseIosConfigured = true, and fill DefaultFirebaseOptions.ios.',
        );
      default:
        throw UnsupportedError(
          'Firebase is not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOUP0K-0uj5Dw001VHbP_PbI4Zx0nPzNg',
    appId: '1:456615864676:android:be0dbaecb77afbb516f271',
    messagingSenderId: '456615864676',
    projectId: 'snake-4cb1c',
    storageBucket: 'snake-4cb1c.firebasestorage.app',
  );
}
