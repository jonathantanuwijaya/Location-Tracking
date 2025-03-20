import 'package:flutter/material.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_state.dart';
import 'package:tracking_practice/services/logic/location_storage_service.dart';
import 'package:tracking_practice/services/logic/service_background.dart';

class ClockInOutProvider extends ChangeNotifier {
  final ServiceBackground _serviceBackground;
  final LocationStorageService _locationStorageService;
  ClockInOutState _state = ClockInOutState.initial();

  ClockInOutProvider(this._serviceBackground, this._locationStorageService);
  ClockInOutState get state => _state;

  void clockIn() {
    _state = _state.copyWith(isClockedIn: true);
    _serviceBackground.start(); // Start the background servic
    notifyListeners();
  }

  void clockOut() {
    _state = _state.copyWith(isClockedIn: false);
    _serviceBackground.stop(); // Stop the background service
    notifyListeners();
  }

  Future<void> checkServiceStatus() async {
    final status = await _serviceBackground.isRunning();
    _state = _state.copyWith(isClockedIn: status);
    notifyListeners();
  }

  Future<void> saveGeofenceData(GeofenceData geofenceData) async {
    await _locationStorageService.storeGeofenceData(geofenceData);
    final listOfGeofenceData =
        await _locationStorageService.getAllGeofenceData();
    _state = _state.copyWith(geofenceData: listOfGeofenceData);
    notifyListeners();
  }
}
