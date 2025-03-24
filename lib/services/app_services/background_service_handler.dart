import 'dart:async';
import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:tracking_practice/core/constants/location_constants.dart';
import 'package:tracking_practice/core/constants/service_port_key.dart';
import 'package:tracking_practice/core/init/app_init.dart';
import 'package:tracking_practice/core/util/hive_storage.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/app_services/location_service.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/logic/background_track_logic.dart';
import 'package:tracking_practice/services/logic/location_tracking_logic.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BackgroundServiceHandler {
  final GeolocatorLocationService _locationService;
  final LocationStorageService _storageService;
  final LocationTrackingLogic _trackingLogic;
  final BackgroundTrackLogic _backgroundTrackLogic;
  final ApplicationInitializer _appInit;

  Timer? _locationUpdateTimer;
  LocationTimeSummary? _currentSummary;
  bool _isRunning = true;
  Map<String, int> todayDurations = {};

  BackgroundServiceHandler({
    GeolocatorLocationService? locationService,
    LocationStorageService? storageService,
    LocationTrackingLogic? trackingLogic,
    BackgroundTrackLogic? backgroundTrackLogic,
    ApplicationInitializer? appInit,
  }) : _locationService = locationService ?? GeolocatorLocationService(),
       _storageService = storageService ?? LocationStorageService(),
       _trackingLogic = trackingLogic ?? LocationTrackingLogic(),
       _backgroundTrackLogic = backgroundTrackLogic ?? BackgroundTrackLogic(),
       _appInit = appInit ?? ApplicationInitializer();

  Future<void> initializeBackgroundLocationTracking(
    ServiceInstance service,
  ) async {
    _startPeriodicLocationUpdates(service);
    _registerServiceStopListener(service);
  }

  void _startPeriodicLocationUpdates(ServiceInstance service) {
    _locationUpdateTimer = Timer.periodic(
      Duration(seconds: LocationConstants.defaultLocationUpdateIntervalSeconds),
      (timer) => _processLocationUpdate(service, timer),
    );
  }

  Future<void> _processLocationUpdate(
    ServiceInstance service,
    Timer timer,
  ) async {
    if (!_isRunning) {
      timer.cancel();
      return;
    }

    /// Must to re-init and close Hive every iteration
    /// because Hive have an issue to read data on background
    try {
      await _appInit.initLocalStorage();
      await _fetchAndProcessLocationData(service);
    } catch (e) {
      log('Error during location update: $e');
    } finally {
      await _closeHiveConnections();
    }
  }

  Future<void> _fetchAndProcessLocationData(ServiceInstance service) async {
    final geofenceData = await _storageService.getAllGeofenceData();
    final locationData = await _trackingLogic.checkUserPosition(
      _locationService,
      geofenceData,
    );

    await _updateAndBroadcastLocationSummary(service, locationData);
  }

  /// This method will invoke the background service with that port key
  /// after the updateLocationSummary method is finished.
  Future<void> _updateAndBroadcastLocationSummary(
    ServiceInstance service,
    GeofenceData locationData,
  ) async {
    _currentSummary = _backgroundTrackLogic.calculateLocationDurationSummary(
      locationData,
      todayDurations,
    );
    todayDurations = _currentSummary!.locationDurations;
    log('Today time summary: ${_currentSummary!.toMap()}');
    service.invoke(
      ServicePortKey.updateLocationSummary,
      _currentSummary!.toMap(),
    );
  }

  void _registerServiceStopListener(ServiceInstance service) {
    service.on(ServicePortKey.stopService).listen((event) async {
      await _cleanupAndStopService(service);
    });
  }

  Future<void> _cleanupAndStopService(ServiceInstance service) async {
    if (_currentSummary != null) {
      await _storageService.storeLocationData(_currentSummary!);
      log('Saving data to Hive');
    }

    log('Stopping background service');
    _isRunning = false;
    _locationUpdateTimer?.cancel();
    service.stopSelf();
  }

  Future<void> _closeHiveConnections() async {
    await HiveStorage().close();
    await Hive.close();
  }
}
