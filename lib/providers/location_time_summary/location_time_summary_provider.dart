import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_state.dart';
import 'package:tracking_practice/services/repository/location_time_summary_repository.dart';

/// Provider class for managing location time summary data
class LocationTimeSummaryProvider extends ChangeNotifier {
  /// Creates a new [LocationTimeSummaryProvider] instance
  LocationTimeSummaryProvider(this._repository) {
    _initializeStream();
  }

  final LocationTimeSummaryRepository _repository;
  StreamSubscription? _subscription;

  /// Current state of the location time summary
  LocationTimeSummaryState _state = LocationTimeSummaryState.initial();

  /// Getter for the current state
  LocationTimeSummaryState get state => _state;

  void _initializeStream() {
    notifyListeners();

    _subscription = _repository.getLocationTimeSummaryUpdates().listen(
      (summary) {
        _state = _state.copyWith(isLoading: false, summary: summary);
        notifyListeners();
      },
      onError: (error) {
        _state = LocationTimeSummaryState.error(error.toString());
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