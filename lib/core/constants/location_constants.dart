/// Constants related to location tracking functionality
class LocationConstants {
  /// Private constructor to prevent instantiation
  const LocationConstants._();

  /// Default distance threshold in meters
  /// Locations within this distance are considered "in range"
  static const double defaultDistanceThresholdMeters = 50.0;

  /// Default location update interval in seconds
  static const int defaultLocationUpdateIntervalSeconds = 1;

  /// Notification ID for the foreground service
  static const int foregroundServiceNotificationId = 888;

  /// Default notification title for the location tracking service
  static const String defaultNotificationTitle = 'Location Tracking';

  /// Default notification content for the location tracking service
  static const String defaultNotificationContent =
      'Location tracking is active';
}
