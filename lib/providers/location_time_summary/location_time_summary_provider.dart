import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/repository/location_time_summary_repository.dart';

class LocationTimeSummaryProvider extends ChangeNotifier {
  LocationTimeSummaryProvider(this._repository) {
    _initializeStream();
  }

  final LocationTimeSummaryRepository _repository;
  StreamSubscription? _subscription;

  LocationTimeSummary? _summary;
  bool _isLoading = false;
  String? _error;

  LocationTimeSummary? get summary => _summary;
  bool get isLoading => _isLoading;
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
