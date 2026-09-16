class AppConstants {
  AppConstants._();

  static const String appName = 'Varavu Selavu';
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';

  // Storage keys
  static const String keyAppLockEnabled = 'app_lock_enabled';
  static const String keyBiometricsEnabled = 'biometrics_enabled';
  static const String keyPinHash = 'pin_hash';
  static const String keyPinSalt = 'pin_salt';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // Backup schema version
  static const int backupSchemaVersion = 1;

  // DB Config
  static const String databaseName = 'varavu_selavu.db';
  static const int databaseVersion = 3;
}
