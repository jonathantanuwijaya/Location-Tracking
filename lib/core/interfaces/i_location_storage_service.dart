import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

/// Interface for location storage service operations
abstract class ILocationStorageService {
  /// Store location data summary
  Future<void> storeLocationData(LocationTimeSummary locationSummary);

  /// Get all stored location data
  Future<List<Map<String, dynamic>>> getAllLocationData();

  /// Get all location time summaries
  Future<List<LocationTimeSummary>> getAllLocationTimeSummaries();

  /// Store geofence data
  Future<void> storeGeofenceData(GeofenceData geofenceData);

  /// Get all stored geofence data
  Future<List<GeofenceData>> getAllGeofenceData();
}
