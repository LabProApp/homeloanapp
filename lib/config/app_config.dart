class AppConfig {
  const AppConfig._();

  /// Pass at build time: flutter run --dart-define=API_BASE_URL=https://api.keybricks.com/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://13.51.109.150:8080/api',
  );

  /// Sales / support WhatsApp number used by the "Contact Support" CTA on the
  /// Subscription screen. Include the country code, digits only (wa.me format).
  /// Override at build time: --dart-define=SUPPORT_WHATSAPP=911234567890
  static const String supportWhatsApp = String.fromEnvironment(
    'SUPPORT_WHATSAPP',
    defaultValue: '911234567890',
  );

  /// Sales / support email — used as a fallback when WhatsApp isn't available.
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'support@keybricks.com',
  );

  /// Play Store listing URL — fallback when the server doesn't return a storeUrl.
  /// Override at build time: --dart-define=PLAY_STORE_URL=https://play.google.com/...
  static const String playStoreUrl = String.fromEnvironment(
    'PLAY_STORE_URL',
    defaultValue: 'https://play.google.com/store/apps/details?id=com.keybricks',
  );

  /// App Store listing URL — fallback when the server doesn't return a storeUrl.
  /// Override at build time: --dart-define=APP_STORE_URL=https://apps.apple.com/...
  static const String appStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue: 'https://apps.apple.com/app/keybricks/id0000000000',
  );
}
