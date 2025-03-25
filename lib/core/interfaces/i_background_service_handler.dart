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
