class LocationTimeSummary {
  const LocationTimeSummary({
    required this.date,
    required this.locationDurations,
  });

  factory LocationTimeSummary.fromJson(Map<String, dynamic> json) {
    return LocationTimeSummary(
      date: DateTime.parse(json['date'] as String),
      locationDurations: Map<String, int>.from(
        json['locationDurations'] as Map<String, dynamic>,
      ),
    );
  }

  final DateTime date;

  final Map<String, int> locationDurations;

  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final remainingMinutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${remainingMinutes}m';
  }

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
