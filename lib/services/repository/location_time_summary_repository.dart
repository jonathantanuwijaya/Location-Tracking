import 'dart:async';
import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:tracking_practice/core/constants/service_port_key.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

/// Repository to handle location time summary updates from background service
class LocationTimeSummaryRepository {
  /// The background service instance
  final FlutterBackgroundService _backgroundService;
  
  /// Stream controller for location time summary updates
  final _summaryController = StreamController<LocationTimeSummary>.broadcast();

  /// Creates a new [LocationTimeSummaryRepository] instance
  LocationTimeSummaryRepository(this._backgroundService) {
    // Listen to the background service for location time summary updates
    _backgroundService.on(ServicePortKey.updateLocationSummary).listen((event) {
      if (event != null) {
        try {
          final summary = LocationTimeSummary.fromJson(
            Map<String, dynamic>.from(event as Map),
          );
          _summaryController.add(summary);
        } catch (e) {
          log('Error parsing location time summary: $e');
        }
      }
    });
  }

  /// Get stream of location time summary updates
  Stream<LocationTimeSummary> getLocationTimeSummaryUpdates() {
    return _summaryController.stream;
  }

  /// Dispose of resources
  void dispose() {
    _summaryController.close();
  }
}