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
/// Responsible for managing the service lifecycle and coordinating periodic location updates
class BackgroundServiceHandler implements IBackgroundServiceHandler {
  /// Creates a new [BackgroundServiceHandler] instance with optional dependencies
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
    final backgroundTrackLogicImpl = backgroundTrackLogic ?? BackgroundTrackLogic();
    final appInitializer = appInit ?? ApplicationInitializer();

    _serviceHelper = BackgroundServiceHelper(
      locationService: locationServiceImpl,
      storageService: storageServiceImpl,
      trackingLogic: trackingLogicImpl,
      backgroundTrackLogic: backgroundTrackLogicImpl,
      appInit: appInitializer,
    );
  }

  /// Helper for delegating complex operations
  late final BackgroundServiceHelper _serviceHelper;
  
  /// Timer for scheduling periodic location updates
  Timer? _periodicUpdateTimer;
  
  /// Current location summary data
  LocationTimeSummary? _currentLocationSummary;
  
  /// Flag indicating if the service is running
  bool _isServiceRunning = true;
  
  /// Duration records for each location
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

  /// Handles the timer callback for periodic location updates
  /// Checks if service is running and processes the update
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
      // Initialize storage for this update
      await _serviceHelper.initializeStorage();
      
      // Process location data and update summary
      await _serviceHelper.fetchAndProcessLocationData(
        service,
        _locationDurations,
        updateLocationSummary,
      );
    } catch (e) {
      log('Failed to process location update: $e');
    } finally {
      // Always close storage connections
      await _serviceHelper.closeStorageConnections();
    }
  }

  /// Updates the current location summary and durations when new data is available
  void updateLocationSummary(
    LocationTimeSummary summary,
    Map<String, int> updatedDurations,
  ) {
    _currentLocationSummary = summary;
    _locationDurations = updatedDurations;
  }

  /// Registers a listener for service stop events
  void registerServiceStopListener(ServiceInstance service) {
    service.on(ServicePortKey.stopService).listen((event) async {
      await cleanupAndStopService(service);
    });
  }

  @override
  Future<void> cleanupAndStopService(ServiceInstance service) async {
    // Save data and stop service
    await _serviceHelper.cleanupAndStopService(service, _currentLocationSummary);
    
    // Clean up resources
    _isServiceRunning = false;
    _periodicUpdateTimer?.cancel();
  }
}
