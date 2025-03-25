import 'package:geolocator/geolocator.dart';

abstract class ILocationService {
  Future<Position> getCurrentPosition();

  Future<bool> isLocationInRange({
    required double sourceLatitude,
    required double sourceLongitude,
    required double targetLatitude,
    required double targetLongitude,
    double? thresholdMeters,
  });
}
