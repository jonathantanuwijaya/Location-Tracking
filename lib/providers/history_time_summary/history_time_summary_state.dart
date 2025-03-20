import 'package:tracking_practice/models/location_time_summary.dart';

/// State class for managing history of location time summaries
class HistoryTimeSummaryState {
  /// Creates a new [HistoryTimeSummaryState] instance
  const HistoryTimeSummaryState({
    this.isLoading = false,
    this.summaries = const [],
    this.error,
  });

  /// Whether the state is currently loading
  final bool isLoading;

  /// The list of location time summaries
  final List<LocationTimeSummary> summaries;

  /// Any error that occurred while loading the data
  final String? error;

  /// Creates a copy of this state with the given fields replaced with new values
  HistoryTimeSummaryState copyWith({
    bool? isLoading,
    List<LocationTimeSummary>? summaries,
    String? error,
  }) {
    return HistoryTimeSummaryState(
      isLoading: isLoading ?? this.isLoading,
      summaries: summaries ?? this.summaries,
      error: error ?? this.error,
    );
  }

  /// Creates an initial state
  factory HistoryTimeSummaryState.initial() {
    return const HistoryTimeSummaryState();
  }

  /// Creates a loading state
  factory HistoryTimeSummaryState.loading() {
    return const HistoryTimeSummaryState(isLoading: true);
  }

  /// Creates an error state
  factory HistoryTimeSummaryState.error(String message) {
    return HistoryTimeSummaryState(error: message);
  }
}