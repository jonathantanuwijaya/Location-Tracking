import 'package:tracking_practice/models/location_time_summary.dart';

/// Interface for location time summary repository
abstract class ILocationTimeSummaryRepository {
  /// Stream of location time summary updates
  Stream<LocationTimeSummary> getLocationUpdates();

  /// Start listening to location updates
  void startListeningToLocationUpdates();

  /// Process incoming location update event
  void processLocationUpdate(Map<String, dynamic>? event);

  /// Handle and log errors
  void logAndPropagateError(Object error, [StackTrace? stackTrace]);

  /// Clean up resources
  void dispose();
}