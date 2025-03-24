import 'dart:async';
import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:tracking_practice/core/constants/service_port_key.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/repository/i_location_time_summary_repository.dart';

/// Implementation of [ILocationTimeSummaryRepository] that manages location time summary data stream from background service
class LocationTimeSummaryRepository implements ILocationTimeSummaryRepository {
  /// Creates a new [LocationTimeSummaryRepository] instance
  LocationTimeSummaryRepository(this._backgroundService) {
    startListeningToLocationUpdates();
  }

  final FlutterBackgroundService _backgroundService;
  final _summaryController = StreamController<LocationTimeSummary>.broadcast();
  bool _isDisposed = false;

  @override
  void startListeningToLocationUpdates() {
    _backgroundService.on(ServicePortKey.updateLocationSummary).listen(
      processLocationUpdate,
      onError: logAndPropagateError,
      cancelOnError: false,
    );
  }

  @override
  void processLocationUpdate(Map<String, dynamic>? event) {
    if (_isDisposed) return;
    
    if (event == null) {
      log('Received null location update event');
      return;
    }

    try {
      final summary = LocationTimeSummary.fromJson(
        Map<String, dynamic>.from(event),
      );
      _summaryController.add(summary);
    } catch (e, stackTrace) {
      logAndPropagateError(e, stackTrace);
    }
  }

  @override
  void logAndPropagateError(Object error, [StackTrace? stackTrace]) {
    if (_isDisposed) return;
    
    log(
      'Error processing location time summary',
      error: error,
      stackTrace: stackTrace,
    );
    
    _summaryController.addError(error);
  }

  @override
  Stream<LocationTimeSummary> getLocationUpdates() {
    return _summaryController.stream;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _summaryController.close();
  }
}