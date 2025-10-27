/// Application-wide constants.
///
/// Centralizes app-wide configuration values such as app name,
/// version, cache timeouts, and other constants that don't
/// fit into specific features. This promotes consistency
/// and makes it easy to update values globally.
class AppConstants {
  static const String appName = 'Smart Task Manager';
  static const String appVersion = '1.0.0';

  // Cache-related constants
  static const Duration defaultCacheTimeout = Duration(minutes: 15);

  // Pagination constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Date/Time formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
}

