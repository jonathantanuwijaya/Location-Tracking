import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/app_services/service_background.dart';

/// Provider class for managing clock in/out functionality and geofence data
class ClockInOutProvider extends ChangeNotifier {
  /// Creates a new [ClockInOutProvider] instance
  ClockInOutProvider(this._serviceBackground, this._locationStorageService) {
    _initializeProvider();
  }

  final ServiceBackground _serviceBackground;
  final LocationStorageService _locationStorageService;
  bool _isClockedIn = false;
  List<GeofenceData> _geofenceData = [];
  String? _error;

  /// Whether the user is currently clocked in
  bool get isClockedIn => _isClockedIn;

  /// List of all geofence data
  List<GeofenceData> get geofenceData => List.unmodifiable(_geofenceData);

  /// Any error that occurred during operations
  String? get error => _error;

  Future<void> _initializeProvider() async {
    try {
      final status = await _serviceBackground.isRunning();
      _isClockedIn = status;
      _geofenceData = await _locationStorageService.getAllGeofenceData();
      notifyListeners();
    } catch (e) {
      _handleError('Failed to initialize provider', e);
    }
  }

  /// Clock in the user and start background service
  Future<void> clockIn() async {
    try {
      await _serviceBackground.start();
      _isClockedIn = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _handleError('Failed to clock in', e);
    }
  }

  /// Clock out the user and stop background service
  Future<void> clockOut() async {
    try {
      await _serviceBackground.stop();
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

  /// Validates and saves new geofence data
  Future<(bool, String?)> validateAndSaveGeofenceData(String latitude, String longitude, String name) async {
    // Validate inputs
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

      await _locationStorageService.storeGeofenceData(geofenceData);
      _geofenceData = await _locationStorageService.getAllGeofenceData();
      _error = null;
      notifyListeners();
      return (true, null);
    } catch (e) {
      _handleError('Failed to save geofence data', e);
      return (false, 'Invalid latitude or longitude format');
    }
  }

  /// Refresh the current service status
  Future<void> refreshServiceStatus() async {
    try {
      final status = await _serviceBackground.isRunning();
      _isClockedIn = status;
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
