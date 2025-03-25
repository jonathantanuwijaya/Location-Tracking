import 'dart:developer';

import 'package:tracking_practice/core/interfaces/i_location_service.dart';
import 'package:tracking_practice/models/geofence_data.dart';

class LocationTrackingLogic {
  Future<GeofenceData> checkUserPosition(
    ILocationService locationService,
    List<GeofenceData> geofenceData,
  ) async {
    final position = await locationService.getCurrentPosition();
    log('Current position: $position');
    String? locationName;
    for (final geofence in geofenceData) {
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
            ? GeofenceData.fromPosition(position, 'Traveling')
            : GeofenceData.fromPosition(position, locationName);
    return locationData;
  }
}
