import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:tracking_practice/core/constants/storage_key.dart';
import 'package:tracking_practice/core/util/hive_storage.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

class LocationStorageService {
  final HiveStorage _storage = HiveStorage();

  /// Format for date keys (dd-MM-yyyy)
  static final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  /// Get all stored data before inserting
  /// to make sure the data is correct
  Future<void> storeLocationData(LocationTimeSummary locationSummary) async {
    List<Map<String, dynamic>> existingEvents = await getAllLocationData();

    // Format the date as string for key
    final dateKey = _dateFormat.format(locationSummary.date);

    // Check if there's already an entry for this date
    final existingIndex = existingEvents.indexWhere(
      (event) => event.containsKey(dateKey),
    );

    if (existingIndex >= 0) {
      // Get existing data for this date
      final existingData = Map<String, dynamic>.from(
        existingEvents[existingIndex][dateKey] as Map<String, dynamic>,
      );

      // Get existing location durations
      final existingDurations = Map<String, int>.from(
        existingData['locationDurations'] as Map<String, dynamic>,
      );

      // Get new location durations
      final newDurations = locationSummary.locationDurations;

      // Merge durations, summing values for the same location
      newDurations.forEach((location, duration) {
        existingDurations[location] =
            (existingDurations[location] ?? 0) + duration;
      });

      // Update the existing entry
      existingData['locationDurations'] = existingDurations;
      existingEvents[existingIndex] = {dateKey: existingData};
    } else {
      // Add new entry
      existingEvents.add({dateKey: locationSummary.toMap()});
    }

    await _storage.insert(
      StorageKeyConstant.clockInOutData,
      jsonEncode(existingEvents),
    );
  }

  /// Get all stored location data
  ///
  /// Returns a list of maps like this:
  /// [{date: 2025-03-20, locationDurations: {Home: 7, Office: 6, Traveling: 16}}]
  Future<List<Map<String, dynamic>>> getAllLocationData() async {
    final data = await _storage.get(StorageKeyConstant.clockInOutData);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data) as List);
    }
    return [];
  }

  /// Get all stored location data as LocationTimeSummary objects
  ///
  /// Returns a list of LocationTimeSummary objects
  Future<List<LocationTimeSummary>> getAllLocationTimeSummaries() async {
    final rawData = await getAllLocationData();
    final List<LocationTimeSummary> summaries = [];

    for (final entry in rawData) {
      entry.forEach((dateKey, data) {
        // Parse the date from the key format (dd-MM-yyyy)
        final date = _dateFormat.parse(dateKey);

        // Create LocationTimeSummary from the data
        final summary = LocationTimeSummary(
          date: date,
          locationDurations: Map<String, int>.from(
            (data as Map<String, dynamic>)['locationDurations']
                as Map<String, dynamic>,
          ),
        );

        summaries.add(summary);
      });
    }

    return summaries;
  }

  Future<List<LocationTimeSummary>> parseLocationTimeSummaries() async {
    final List<dynamic> jsonList = await getAllLocationData();
    return jsonList
        .map((jsonItem) => LocationTimeSummary.fromJson(jsonItem))
        .toList();
  }

  /// Store a geofence data object in the list
  /// 
  /// If the geofence with the same name already exists, it will be updated
  Future<void> storeGeofenceData(GeofenceData geofenceData) async {
    List<GeofenceData> existingGeofences = await getAllGeofenceData();
    
    // Check if a geofence with the same name already exists
    final existingIndex = existingGeofences.indexWhere(
      (geofence) => geofence.name == geofenceData.name,
    );
    
    if (existingIndex >= 0) {
      // Replace the existing geofence
      existingGeofences[existingIndex] = geofenceData;
    } else {
      // Add new geofence
      existingGeofences.add(geofenceData);
    }
    
    // Convert to list of maps for storage
    final geofenceMaps = existingGeofences.map((geofence) => geofence.toMap()).toList();
    
    await _storage.insert(
      StorageKeyConstant.geofenceData,
      jsonEncode(geofenceMaps),
    );
  }
  
  /// Get all stored geofence data objects
  ///
  /// Returns a list of GeofenceData objects
  Future<List<GeofenceData>> getAllGeofenceData() async {
    final data = await _storage.get(StorageKeyConstant.geofenceData);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data) as List;
      return jsonList
          .map((json) => GeofenceData.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
