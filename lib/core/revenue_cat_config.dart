/// RevenueCat API keys.
///
/// Pass real keys at build time (preferred — keeps secrets out of source):
/// ```
/// flutter run --dart-define=RC_ANDROID_API_KEY=goog_xxx --dart-define=RC_IOS_API_KEY=appl_xxx
/// ```
///
/// Or paste test keys below for local device work. Leave empty to use the
/// offline stub (debug unlock still available in kDebugMode).
abstract final class RevenueCatConfig {
  static const androidApiKey = String.fromEnvironment(
    'RC_ANDROID_API_KEY',
    defaultValue: '',
  );

  static const iosApiKey = String.fromEnvironment(
    'RC_IOS_API_KEY',
    defaultValue: '',
  );

  static bool get hasAndroidKey => androidApiKey.isNotEmpty;
  static bool get hasIosKey => iosApiKey.isNotEmpty;
}
