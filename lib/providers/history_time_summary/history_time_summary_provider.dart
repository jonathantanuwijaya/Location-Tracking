import 'package:flutter/foundation.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';

/// Provider class for managing history of location time summaries
class HistoryTimeSummaryProvider extends ChangeNotifier {
  /// Creates a new [HistoryTimeSummaryProvider] instance
  HistoryTimeSummaryProvider(this._locationStorageService) {
    loadSummaries();
  }

  final LocationStorageService _locationStorageService;
  List<LocationTimeSummary> _summaries = [];
  bool _isLoading = false;
  String? _error;

  /// Get the list of summaries
  List<LocationTimeSummary> get summaries => List.unmodifiable(_summaries);

  /// Whether the provider is currently loading
  bool get isLoading => _isLoading;

  /// Any error that occurred while loading the data
  String? get error => _error;

  /// Load summaries from storage
  Future<void> loadSummaries() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final loadedSummaries = await _locationStorageService.getAllLocationTimeSummaries();
      
      // Sort summaries by date (newest first)
      loadedSummaries.sort((a, b) => b.date.compareTo(a.date));
      
      _summaries = loadedSummaries;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the summaries data
  Future<void> refreshSummaries() => loadSummaries();

  /// Get a specific summary by date
  LocationTimeSummary? getSummaryByDate(DateTime date) {
    try {
      return _summaries.firstWhere(
        (summary) =>
            summary.date.year == date.year &&
            summary.date.month == date.month &&
            summary.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }
}
