import 'package:geolocator/geolocator.dart';
import 'package:tracking_practice/core/constants/location_constants.dart';
import 'package:tracking_practice/core/interfaces/i_location_service.dart';

class GeolocatorLocationService implements ILocationService {
  GeolocatorLocationService({GeolocatorPlatform? geolocatorPlatform})
    : _geolocator = geolocatorPlatform ?? GeolocatorPlatform.instance;

  final GeolocatorPlatform _geolocator;

  @override
  Future<Position> getCurrentPosition() async {
    return _geolocator.getCurrentPosition();
  }

  @override
  Future<bool> isLocationInRange({
    required double sourceLatitude,
    required double sourceLongitude,
    required double targetLatitude,
    required double targetLongitude,
    double? thresholdMeters,
  }) async {
    final distance = _geolocator.distanceBetween(
      sourceLatitude,
      sourceLongitude,
      targetLatitude,
      targetLongitude,
    );

    /// check if the distance is less than or equal to the threshold
    /// to know if the user is in range or not
    return distance <=
        (thresholdMeters ?? LocationConstants.defaultDistanceThresholdMeters);
  }
}
