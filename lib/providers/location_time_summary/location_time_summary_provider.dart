import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/repository/location_time_summary_repository.dart';

/// Provider class for managing location time summary data
class LocationTimeSummaryProvider extends ChangeNotifier {
  /// Creates a new [LocationTimeSummaryProvider] instance
  LocationTimeSummaryProvider(this._repository) {
    _initializeStream();
  }

  final LocationTimeSummaryRepository _repository;
  StreamSubscription? _subscription;

  /// The current location time summary
  LocationTimeSummary? _summary;

  /// Whether the provider is currently loading
  bool _isLoading = false;

  /// Any error that occurred while loading the data
  String? _error;

  /// Getter for the current summary
  LocationTimeSummary? get summary => _summary;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Getter for error state
  String? get error => _error;

  void _initializeStream() {
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.getLocationUpdates().listen(
      (summary) {
        _summary = summary;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
