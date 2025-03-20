import 'package:geolocator/geolocator.dart';
import 'package:tracking_practice/services/logic/background_service_manager.dart';

class ServiceBackground {
  static final ServiceBackground instance = ServiceBackground._internal();

  factory ServiceBackground() {
    return instance;
  }

  ServiceBackground._internal();

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return false;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Call this method to set up location tracking in the background
  Future<void> init() async {
    await BackgroundServiceManager.instance.initialize();
  }

  /// Call this method to begin location tracking
  Future<void> start() async {
    await BackgroundServiceManager.instance.startService();
  }

  /// Returns true if the background service is active
  Future<bool> isRunning() async {
    return BackgroundServiceManager.instance.isServiceRunning();
  }

  /// Call this method to stop location tracking
  Future<void> stop() async {
    await BackgroundServiceManager.instance.stopService();
  }
}
