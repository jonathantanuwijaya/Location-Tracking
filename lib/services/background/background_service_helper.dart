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
class BackgroundServiceHelper {
  BackgroundServiceHelper({
    required GeolocatorLocationService locationService,
    required LocationStorageService storageService,
    required LocationTrackingLogic trackingLogic,
    required BackgroundTrackLogic backgroundTrackLogic,
    required ApplicationInitializer appInit,
  }) : _locationServiceApi = locationService,
       _dataStorageService = storageService,
       _locationTrackingLogic = trackingLogic,
       _durationCalculationLogic = backgroundTrackLogic,
       _appInitializer = appInit;

  final GeolocatorLocationService _locationServiceApi;
  final LocationStorageService _dataStorageService;
  final LocationTrackingLogic _locationTrackingLogic;
  final BackgroundTrackLogic _durationCalculationLogic;
  final ApplicationInitializer _appInitializer;

  /// Fetches user location data and processes it relative to geofences
  Future<void> fetchAndProcessLocationData(
    ServiceInstance service,
    Map<String, int> currentDurations,
    void Function(
      LocationTimeSummary summary,
      Map<String, int> updatedDurations,
    )
    onSummaryUpdated,
  ) async {
    // Get all geofence definitions
    final definedGeofences = await _dataStorageService.getAllGeofenceData();

    // Check if user is within any geofence
    final currentLocationData = await _locationTrackingLogic.checkUserPosition(
      _locationServiceApi,
      definedGeofences,
    );

    await calculateAndBroadcastLocationSummary(
      service,
      currentLocationData,
      currentDurations,
      onSummaryUpdated,
    );
  }

  /// Calculates and broadcasts the location time summary
  Future<void> calculateAndBroadcastLocationSummary(
    ServiceInstance service,
    GeofenceData locationData,
    Map<String, int> currentDurations,
    void Function(
      LocationTimeSummary summary,
      Map<String, int> updatedDurations,
    )
    onSummaryUpdated,
  ) async {
    final updatedSummary = _durationCalculationLogic
        .calculateLocationDurationSummary(locationData, currentDurations);

    final newDurations = updatedSummary.locationDurations;

    log('Location time summary updated: ${updatedSummary.toMap()}');

    service.invoke(
      ServicePortKey.updateLocationSummary,
      updatedSummary.toMap(),
    );

    onSummaryUpdated(updatedSummary, newDurations);
  }

  /// Saves data and prepares for service shutdown
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
  Future<void> initializeStorage() async {
    await _appInitializer.initLocalStorage();
  }

  /// Closes all storage connections
  Future<void> closeStorageConnections() async {
    await HiveStorage().close();
    await Hive.close();
  }
}
