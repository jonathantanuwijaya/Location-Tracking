import 'package:tracking_practice/models/location_time_summary.dart';

/// State class for managing location time summary data
class LocationTimeSummaryState {
  /// Creates a new [LocationTimeSummaryState] instance
  const LocationTimeSummaryState({
    this.isLoading = false,
    this.summary,
    this.error,
  });

  /// Whether the state is currently loading
  final bool isLoading;

  /// The current location time summary
  final LocationTimeSummary? summary;

  /// Any error that occurred while loading the data
  final String? error;

  /// Creates a copy of this state with the given fields replaced with new values
  LocationTimeSummaryState copyWith({
    bool? isLoading,
    LocationTimeSummary? summary,
    String? error,
  }) {
    return LocationTimeSummaryState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      error: error ?? this.error,
    );
  }

  factory LocationTimeSummaryState.initial() {
    return const LocationTimeSummaryState();
  }


  /// Creates an error state
  factory LocationTimeSummaryState.error(String message) {
    return LocationTimeSummaryState(error: message);
  }
}