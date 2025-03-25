import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracking_practice/core/constants/service_port_key.dart';
import 'package:tracking_practice/core/init/app_init.dart';
import 'package:tracking_practice/core/util/hive_storage.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/app_services/location_service.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/logic/background_track_logic.dart';
import 'package:tracking_practice/services/logic/location_tracking_logic.dart';

/// Helper class for background service data processing operations
/// Responsible for interacting with services and processing location data
class BackgroundServiceHelper {
  /// Creates a new instance of BackgroundServiceHelper with required dependencies
  BackgroundServiceHelper({
    required GeolocatorLocationService locationService,
    required LocationStorageService storageService,
    required LocationTrackingLogic trackingLogic,
    required BackgroundTrackLogic backgroundTrackLogic,
    required ApplicationInitializer appInit,
  })  : _locationServiceApi = locationService,
        _dataStorageService = storageService,
        _locationTrackingLogic = trackingLogic,
        _durationCalculationLogic = backgroundTrackLogic,
        _appInitializer = appInit;

  /// Service for obtaining device location
  final GeolocatorLocationService _locationServiceApi;
  
  /// Service for persisting location data
  final LocationStorageService _dataStorageService;
  
  /// Logic for tracking user position relative to geofences
  final LocationTrackingLogic _locationTrackingLogic;
  
  /// Logic for calculating time duration spent at locations
  final BackgroundTrackLogic _durationCalculationLogic;
  
  /// Application initializer for managing app resources
  final ApplicationInitializer _appInitializer;

  /// Fetches user location data and processes it relative to geofences
  /// 
  /// Checks the user's current position against defined geofences,
  /// then calculates time spent at each location and broadcasts the update
  Future<void> fetchAndProcessLocationData(
    ServiceInstance service,
    Map<String, int> currentDurations,
    void Function(
      LocationTimeSummary summary,
      Map<String, int> updatedDurations,
    ) onSummaryUpdated,
  ) async {
    // Get all geofence definitions
    final definedGeofences = await _dataStorageService.getAllGeofenceData();
    
    // Check if user is within any geofence
    final currentLocationData = await _locationTrackingLogic.checkUserPosition(
      _locationServiceApi,
      definedGeofences,
    );

    // Process and broadcast the results
    await calculateAndBroadcastLocationSummary(
      service,
      currentLocationData,
      currentDurations,
      onSummaryUpdated,
    );
  }

  /// Calculates and broadcasts the location time summary
  /// 
  /// Takes the current location data and duration records, calculates
  /// the updated summary, and broadcasts it to listeners
  Future<void> calculateAndBroadcastLocationSummary(
    ServiceInstance service,
    GeofenceData locationData,
    Map<String, int> currentDurations,
    void Function(
      LocationTimeSummary summary,
      Map<String, int> updatedDurations,
    ) onSummaryUpdated,
  ) async {
    // Calculate the updated summary with time durations
    final updatedSummary = _durationCalculationLogic
        .calculateLocationDurationSummary(locationData, currentDurations);

    // Extract the updated duration records
    final newDurations = updatedSummary.locationDurations;
    
    // Log for debugging
    log('Location time summary updated: ${updatedSummary.toMap()}');

    // Broadcast to the service
    service.invoke(
      ServicePortKey.updateLocationSummary,
      updatedSummary.toMap(),
    );

    // Notify the handler of the update
    onSummaryUpdated(updatedSummary, newDurations);
  }

  /// Saves data and prepares for service shutdown
  /// 
  /// Persists the current location summary data and
  /// sends the stop command to the service
  Future<void> cleanupAndStopService(
    ServiceInstance service,
    LocationTimeSummary? currentSummary,
  ) async {
    if (currentSummary != null) {
      await _dataStorageService.storeLocationData(currentSummary);
      log('Location summary data saved to persistent storage');
    }

    log('Background location service stopping');
    await service.stopSelf();
  }

  /// Initializes the storage subsystem
  /// 
  /// Must be called before any storage operations
  Future<void> initializeStorage() async {
    await _appInitializer.initLocalStorage();
  }

  /// Closes all storage connections
  /// 
  /// Should be called after storage operations are complete
  /// to prevent resource leaks
  Future<void> closeStorageConnections() async {
    await HiveStorage().close();
    await Hive.close();
  }
}
