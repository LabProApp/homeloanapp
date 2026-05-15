class AppConfig {
  const AppConfig._();

  /// Pass at build time: flutter run --dart-define=API_BASE_URL=https://api.keybricks.com/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://13.51.109.150:8080/api',
  );
}
