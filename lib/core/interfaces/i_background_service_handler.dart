import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

/// Interface for location data processor
abstract class ILocationDataProcessor {
  /// Process location data and return updated summary
  Future<LocationTimeSummary> processLocationData(
    GeofenceData locationData,
    Map<String, int> currentDurations,
  );

  /// Save location data to storage
  Future<void> saveLocationData(LocationTimeSummary summary);
}

/// Interface for background service handler
abstract class IBackgroundServiceHandler {
  /// Initialize background location tracking
  Future<void> initializeBackgroundLocationTracking(ServiceInstance service);
  
  /// Get the current location summary
  LocationTimeSummary? get currentSummary;
  
  /// Start periodic location updates
  void startPeriodicLocationUpdates(ServiceInstance service);
  
  /// Process a location update
  Future<void> processLocationUpdate(ServiceInstance service);
  
  /// Cleanup and stop service
  Future<void> cleanupAndStopService(ServiceInstance service);
}
