import 'package:flutter/foundation.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_state.dart';
import 'package:tracking_practice/services/logic/location_storage_service.dart';

class HistoryTimeSummaryProvider extends ChangeNotifier {
  HistoryTimeSummaryProvider(this._locationStorageService) {
    // Load summaries when provider is created
    loadSummaries();
  }

  final LocationStorageService _locationStorageService;

  HistoryTimeSummaryState _state = HistoryTimeSummaryState.initial();

  HistoryTimeSummaryState get state => _state;

  Future<void> loadSummaries() async {
    try {
      _state = HistoryTimeSummaryState.loading();
      notifyListeners();

      final summaries =
          await _locationStorageService.getAllLocationTimeSummaries();

      // Sort summaries by date (newest first)
      summaries.sort((a, b) => b.date.compareTo(a.date));

      _state = _state.copyWith(isLoading: false, summaries: summaries);
      notifyListeners();
    } catch (e) {
      _state = HistoryTimeSummaryState.error(e.toString());
      notifyListeners();
    }
  }

  /// Refresh the summaries data
  Future<void> refreshSummaries() async {
    await loadSummaries();
  }

  /// Get a specific summary by date
  LocationTimeSummary? getSummaryByDate(DateTime date) {
    return _state.summaries.firstWhere(
      (summary) =>
          summary.date.year == date.year &&
          summary.date.month == date.month &&
          summary.date.day == date.day,
      orElse:
          () =>
              throw Exception('No summary found for date: ${date.toString()}'),
    );
  }
}
