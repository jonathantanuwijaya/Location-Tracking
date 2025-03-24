import 'dart:convert';

import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:tracking_practice/core/constants/storage_key.dart';
import 'package:tracking_practice/core/util/hive_storage.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/logic/mappers_logic.dart';

abstract class ILocationStorageService {
  Future<void> storeLocationData(LocationTimeSummary locationSummary);
  Future<List<Map<String, dynamic>>> getAllLocationData();
  Future<List<LocationTimeSummary>> getAllLocationTimeSummaries();
  Future<void> storeGeofenceData(GeofenceData geofenceData);
  Future<List<GeofenceData>> getAllGeofenceData();
}

class LocationStorageService implements ILocationStorageService {
  final HiveStorage _storage;
  static final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  LocationStorageService({HiveStorage? storage})
    : _storage = storage ?? HiveStorage();

  @override
  Future<void> storeLocationData(LocationTimeSummary locationSummary) async {
    try {
      List<Map<String, dynamic>> existingEvents = await getAllLocationData();

      final dateKey = _dateFormat.format(locationSummary.date);
      existingEvents = MappersLogic().mergeLocationSummaryIntoStorage(
        existingEvents,
        locationSummary,
        dateKey,
      );

      await _storage.insert(
        StorageKeyConstant.clockInOutData,
        jsonEncode(existingEvents),
      );
    } catch (e, st) {
      log('Error storing location data: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllLocationData() async {
    try {
      final data = await _storage.get(StorageKeyConstant.clockInOutData);
      if (data != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(data) as List);
      }
      return [];
    } catch (e, st) {
      log('Error getting all location data: $e\n$st');
      return [];
    }
  }

  @override
  Future<List<LocationTimeSummary>> getAllLocationTimeSummaries() async {
    try {
      final rawData = await getAllLocationData();
      final summaries = MappersLogic().convertToLocationTimeSummaries(
        rawData,
        _dateFormat,
      );
      return summaries;
    } catch (e, st) {
      log('Error getting all location time summaries: $e\n$st');
      return [];
    }
  }

  @override
  Future<void> storeGeofenceData(GeofenceData geofenceData) async {
    try {
      List<GeofenceData> existingGeofences = await getAllGeofenceData();

      final existingIndex = existingGeofences.indexWhere(
        (geofence) => geofence.name == geofenceData.name,
      );

      if (existingIndex >= 0) {
        existingGeofences[existingIndex] = geofenceData;
      } else {
        existingGeofences.add(geofenceData);
      }

      final geofenceMaps =
          existingGeofences.map((geofence) => geofence.toMap()).toList();

      await _storage.insert(
        StorageKeyConstant.geofenceData,
        jsonEncode(geofenceMaps),
      );
    } catch (e, st) {
      log('Error storing geofence data: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<GeofenceData>> getAllGeofenceData() async {
    try {
      final data = await _storage.get(StorageKeyConstant.geofenceData);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data) as List;
        return jsonList
            .map((json) => GeofenceData.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e, st) {
      log('Error getting all geofence data: $e\n$st');
      return [];
    }
  }
}
