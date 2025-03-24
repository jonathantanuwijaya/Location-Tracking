import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/app_services/service_background.dart';

/// Provider class for managing clock in/out functionality and geofence data
class ClockInOutProvider extends ChangeNotifier {
  final ServiceBackground serviceBackground;
  final LocationStorageService locationStorageService;

  bool _isClockedIn = false;
  List<GeofenceData> _geofenceData = [];
  String? _error;

  ClockInOutProvider(this.serviceBackground, this.locationStorageService);

  bool get isClockedIn => _isClockedIn;
  List<GeofenceData> get geofenceData => List.unmodifiable(_geofenceData);
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _isClockedIn = await serviceBackground.isRunning();
      _geofenceData = await locationStorageService.getAllGeofenceData();
      notifyListeners();
    } catch (e) {
      _handleError('Failed to initialize provider', e);
    }
  }

  Future<void> clockIn() async {
    try {
      await serviceBackground.start();
      _isClockedIn = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _handleError('Failed to clock in', e);
    }
  }

  Future<void> clockOut() async {
    try {
      await serviceBackground.stop();
      _isClockedIn = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _handleError('Failed to clock out', e);
    }
  }

  String? validateCoordinate(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    try {
      double.parse(value);
      return null;
    } catch (e) {
      return 'Invalid coordinate format';
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  Future<(bool, String?)> validateAndSaveGeofenceData(
    String latitude,
    String longitude,
    String name,
  ) async {
    final latitudeError = validateCoordinate(latitude);
    final longitudeError = validateCoordinate(longitude);
    final nameError = validateName(name);

    if (latitudeError != null || longitudeError != null || nameError != null) {
      return (false, latitudeError ?? longitudeError ?? nameError);
    }

    try {
      final geofenceData = GeofenceData(
        latitude: double.parse(latitude),
        longitude: double.parse(longitude),
        name: name,
      );
      await locationStorageService.storeGeofenceData(geofenceData);
      _geofenceData = await locationStorageService.getAllGeofenceData();
      _error = null;
      notifyListeners();
      return (true, null);
    } catch (e) {
      _handleError('Failed to save geofence data', e);
      return (false, 'Invalid latitude or longitude format');
    }
  }

  Future<void> refreshServiceStatus() async {
    try {
      _isClockedIn = await serviceBackground.isRunning();
      _error = null;
      notifyListeners();
    } catch (e) {
      _handleError('Failed to refresh service status', e);
    }
  }

  void _handleError(String message, Object error) {
    _error = '$message: ${error.toString()}';
    log('$message: $error');
    notifyListeners();
  }
}
