import 'package:flutter/foundation.dart';

/// RevenueCat API keys.
///
/// Pass real keys at build time (preferred — keeps secrets out of source):
/// ```
/// flutter run --dart-define=RC_ANDROID_API_KEY=goog_xxx --dart-define=RC_IOS_API_KEY=appl_xxx
/// ```
///
/// Leave keys empty to use the offline stub. Local Pro unlock is available in
/// debug builds, and in release builds started with
/// `--dart-define=PRO_TEST_UNLOCK=true` (the TestFlight workflow).
/// App Store builds must not set that flag.
abstract final class RevenueCatConfig {
  static const androidApiKey = String.fromEnvironment(
    'RC_ANDROID_API_KEY',
    defaultValue: '',
  );

  static const iosApiKey = String.fromEnvironment(
    'RC_IOS_API_KEY',
    defaultValue: '',
  );

  /// Tester unlock for TestFlight. Off unless the build passes the define.
  static const allowTestUnlock = bool.fromEnvironment('PRO_TEST_UNLOCK');

  static bool get hasAndroidKey => androidApiKey.isNotEmpty;
  static bool get hasIosKey => iosApiKey.isNotEmpty;

  /// Debug sessions, or a TestFlight build with [allowTestUnlock].
  static bool get allowsLocalProUnlock => kDebugMode || allowTestUnlock;
}
