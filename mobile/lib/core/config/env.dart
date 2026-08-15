/// Compile-time environment. Values come from `--dart-define`.
/// Never hardcode production secrets here.
class AppEnv {
  static const String name = String.fromEnvironment(
    'ENV',
    defaultValue: 'production',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://raw.githubusercontent.com/shimmercode/jahanefootball-app/v1.0.0/backend/public/v1',
  );

  static const String footballApiBaseUrl = String.fromEnvironment(
    'FOOTBALL_API_BASE_URL',
    defaultValue: 'https://www.thesportsdb.com/api/v1/json/3',
  );

  static const String wordpressBaseUrl = String.fromEnvironment(
    'WORDPRESS_BASE_URL',
    defaultValue: '',
  );

  static const String appName = 'جهان فوتبال';
  static const String packageName = 'ir.jahanfootball.app';
  static const String versionName = '1.0.0';
  static const int versionCode = 1;
  static const int minSdk = 23;

  static bool get isProduction => name == 'production';
  static bool get isStaging => name == 'staging';
  static bool get isDevelopment => name == 'development';

  static bool get hasWordPress => wordpressBaseUrl.trim().isNotEmpty;
}
