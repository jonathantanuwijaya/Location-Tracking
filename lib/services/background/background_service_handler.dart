import 'dart:async';
import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:tracking_practice/core/constants/location_constants.dart';
import 'package:tracking_practice/core/constants/service_port_key.dart';
import 'package:tracking_practice/core/init/app_init.dart';
import 'package:tracking_practice/core/interfaces/i_background_service_handler.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/app_services/location_service.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/background/background_service_helper.dart';
import 'package:tracking_practice/services/logic/background_track_logic.dart';
import 'package:tracking_practice/services/logic/location_tracking_logic.dart';

/// Handles background service operations for location tracking
class BackgroundServiceHandler implements IBackgroundServiceHandler {
  BackgroundServiceHandler({
    GeolocatorLocationService? locationService,
    LocationStorageService? storageService,
    LocationTrackingLogic? trackingLogic,
    BackgroundTrackLogic? backgroundTrackLogic,
    ApplicationInitializer? appInit,
  }) {
    final locationServiceImpl = locationService ?? GeolocatorLocationService();
    final storageServiceImpl = storageService ?? LocationStorageService();
    final trackingLogicImpl = trackingLogic ?? LocationTrackingLogic();
    final backgroundTrackLogicImpl =
        backgroundTrackLogic ?? BackgroundTrackLogic();
    final appInitializer = appInit ?? ApplicationInitializer();

    _serviceHelper = BackgroundServiceHelper(
      locationService: locationServiceImpl,
      storageService: storageServiceImpl,
      trackingLogic: trackingLogicImpl,
      backgroundTrackLogic: backgroundTrackLogicImpl,
      appInit: appInitializer,
    );
  }

  late final BackgroundServiceHelper _serviceHelper;
  Timer? _periodicUpdateTimer;
  LocationTimeSummary? _currentLocationSummary;
  bool _isServiceRunning = true;
  Map<String, int> _locationDurations = {};

  @override
  LocationTimeSummary? get currentSummary => _currentLocationSummary;

  @override
  Future<void> initializeBackgroundLocationTracking(
    ServiceInstance service,
  ) async {
    startPeriodicLocationUpdates(service);
    registerServiceStopListener(service);
  }

  @override
  void startPeriodicLocationUpdates(ServiceInstance service) {
    _periodicUpdateTimer = Timer.periodic(
      const Duration(
        seconds: LocationConstants.defaultLocationUpdateIntervalSeconds,
      ),
      (timer) => handlePeriodicUpdateTimer(service, timer),
    );
  }

  Future<void> handlePeriodicUpdateTimer(
    ServiceInstance service,
    Timer timer,
  ) async {
    if (!_isServiceRunning) {
      timer.cancel();
      return;
    }

    try {
      await processLocationUpdate(service);
    } catch (e, stackTrace) {
      log(
        'Error during periodic location update',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> processLocationUpdate(ServiceInstance service) async {
    try {
      await _serviceHelper.initializeStorage();
      await _serviceHelper.fetchAndProcessLocationData(
        service,
        _locationDurations,
        updateLocationSummary,
      );
    } catch (e) {
      log('Failed to process location update: $e');
    } finally {
      await _serviceHelper.closeStorageConnections();
    }
  }

  void updateLocationSummary(
    LocationTimeSummary summary,
    Map<String, int> updatedDurations,
  ) {
    _currentLocationSummary = summary;
    _locationDurations = updatedDurations;
  }

  void registerServiceStopListener(ServiceInstance service) {
    service.on(ServicePortKey.stopService).listen((event) async {
      await cleanupAndStopService(service);
    });
  }

  @override
  Future<void> cleanupAndStopService(ServiceInstance service) async {
    await _serviceHelper.cleanupAndStopService(
      service,
      _currentLocationSummary,
    );

    _isServiceRunning = false;
    _periodicUpdateTimer?.cancel();
  }
}
