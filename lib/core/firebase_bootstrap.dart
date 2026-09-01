import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// Lazy Firebase bootstrap. Never init until opted in and configured.
abstract final class FirebaseBootstrap {
  static bool _initialized = false;
  static bool _initFailed = false;

  static bool get isConfigured => kFirebaseConfigured && !_initFailed;

  static bool get isInitialized => _initialized;

  /// Returns true when Firebase is ready to use.
  static Future<bool> ensureInitialized() async {
    if (!kFirebaseConfigured) return false;
    if (_initFailed) return false;
    if (_initialized) return true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
      return true;
    } catch (_) {
      _initFailed = true;
      return false;
    }
  }
}
