/// Model class representing time spent in different locations for a day
class LocationTimeSummary {
  /// Creates a new [LocationTimeSummary] instance
  const LocationTimeSummary({
    required this.date,
    required this.locationDurations,
  });

  /// Creates a [LocationTimeSummary] from Json
  factory LocationTimeSummary.fromJson(Map<String, dynamic> json) {
    return LocationTimeSummary(
      date: DateTime.parse(json['date'] as String),
      locationDurations: Map<String, int>.from(
        json['locationDurations'] as Map<String, dynamic>,
      ),
    );
  }

  /// The date for this summary
  final DateTime date;

  /// Map of location names to duration in minutes
  final Map<String, int> locationDurations;

  /// Format duration in minutes to hours and minutes string
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final remainingMinutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${remainingMinutes}m';
  }

  /// Converts this summary to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'locationDurations': locationDurations,
    };
  }

  /// Get formatted durations map
  Map<String, String> getFormattedDurations() {
    return locationDurations.map(
      (key, value) => MapEntry(key, formatDuration(value)),
    );
  }
}