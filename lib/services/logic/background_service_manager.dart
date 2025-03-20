import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path_helper;
import 'package:path_provider/path_provider.dart';
import 'package:tracking_practice/core/constants/location_constants.dart';
import 'package:tracking_practice/core/constants/service_port_key.dart';
import 'package:tracking_practice/core/util/datetime_extension.dart';
import 'package:tracking_practice/core/util/hive_storage.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/logic/location_service.dart';
import 'package:tracking_practice/services/logic/location_storage_service.dart';

/// Manager for background service operations
class BackgroundServiceManager {
  const BackgroundServiceManager._();

  /// Singleton instance
  static const BackgroundServiceManager instance = BackgroundServiceManager._();

  /// Initialize the background service
  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: false,
        initialNotificationContent:
            LocationConstants.defaultNotificationContent,
        initialNotificationTitle: LocationConstants.defaultNotificationTitle,
        foregroundServiceNotificationId:
            LocationConstants.foregroundServiceNotificationId,
      ),
      iosConfiguration: IosConfiguration(
        onBackground: _onIosBackground,
        autoStart: false,
        onForeground: _onStart,
      ),
    );
  }

  Future<void> startService() async {
    await FlutterBackgroundService().startService();
  }

  Future<bool> isServiceRunning() async {
    return FlutterBackgroundService().isRunning();
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke(ServicePortKey.stopService);
  }
}

/// Common background processing logic for both Android and iOS
Future<bool> _handleBackgroundProcessing(ServiceInstance service) async {
  final locationService = GeolocatorLocationService();

  bool isRunning = true;

  LocationData? lastLocation;
  Map<String, int> todayDurations = {};
  LocationTimeSummary? summary;

  Timer.periodic(
    Duration(seconds: LocationConstants.defaultLocationUpdateIntervalSeconds),
    (timer) async {
      if (!isRunning) {
        timer.cancel();
        return;
      }

      /// must to init and close Hive every iteration
      /// because Hive have an issue to read data on background
      try {
        final appDir = await getApplicationDocumentsDirectory();
        Hive.init(path_helper.join(appDir.path, '.hidden'));

        final listOfGeofenceData =
            await LocationStorageService().getAllGeofenceData();
        LocationData locationData = await checkUserPosition(
          locationService,
          listOfGeofenceData,
        );

        // Update last known location
        lastLocation = locationData;

        final locationName = lastLocation!.name;
        todayDurations[locationName] =
            (todayDurations[locationName] ?? 0) +
            LocationConstants.defaultLocationUpdateIntervalSeconds;

        summary = LocationTimeSummary(
          date: DateTime.now().toDMYFormatted,
          locationDurations: Map.from(todayDurations),
        );

        /// the value logged here is counted from the last time user clocked in
        /// and the value is not fetched from the local database
        log('today time summary : ${summary!.toMap()}');
        service.invoke(ServicePortKey.updateLocationSummary, summary!.toMap());
      } catch (e) {
        log('Error getting position: $e');
      } finally {
        await HiveStorage().close();
        Hive.close();
      }
    },
  );

  // Handle stop service event
  service.on(ServicePortKey.stopService).listen((event) async {
    if (summary != null) {
      await LocationStorageService().storeLocationData(summary!);
      log('Saving data to Hive');
    }

    log('Stopping background service');
    isRunning = false;
    service.stopSelf();
  });
  
  return true;
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  if (kReleaseMode) {
    DartPluginRegistrant.ensureInitialized();
  }
  
  await _handleBackgroundProcessing(service);
}

Future<LocationData> checkUserPosition(
  GeolocatorLocationService locationService,
  List<GeofenceData> geofenceData,
) async {
  final position = await locationService.getCurrentPosition();
  log('Current position: $position');
  String? locationName;
  for (var geofence in geofenceData) {
    final isInRange = await locationService.isLocationInRange(
      sourceLatitude: position.latitude,
      sourceLongitude: position.longitude,
      targetLatitude: geofence.latitude,
      targetLongitude: geofence.longitude,
    );
    if (isInRange) {
      locationName = geofence.name;
      log('User is in range of ${geofence.name}');
    }
  }
  final locationData =
      locationName == null
          ? LocationData.fromPosition(position, 'Traveling')
          : LocationData.fromPosition(position, locationName);
  return locationData;
}

/// iOS background handler
@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  return _handleBackgroundProcessing(service);
}
