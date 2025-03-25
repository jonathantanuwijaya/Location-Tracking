import 'package:geolocator/geolocator.dart';
import 'package:tracking_practice/services/background/background_service_manager.dart';

class ServiceBackground {
  factory ServiceBackground() {
    return instance;
  }

  ServiceBackground._internal();
  static final ServiceBackground instance = ServiceBackground._internal();

  Future<bool> requestLocationPermission() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return false;
      }
    }

    var permission = await Geolocator.checkPermission();
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

  Future<void> init() async {
    await BackgroundServiceManager.instance.initialize();
  }

  Future<void> start() async {
    await BackgroundServiceManager.instance.startService();
  }

  Future<bool> isRunning() async {
    return BackgroundServiceManager.instance.isServiceRunning();
  }

  Future<void> stop() async {
    await BackgroundServiceManager.instance.stopService();
  }
}
