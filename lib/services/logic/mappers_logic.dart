import 'package:intl/intl.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

class MappersLogic {
  /// Converts a list of location data entries into a list of [LocationTimeSummary] objects
  ///
  /// Takes raw location data and a date format, processes each entry to create
  /// summaries of time spent at different locations for specific dates
  List<LocationTimeSummary> convertToLocationTimeSummaries(
    List<Map<String, dynamic>> locationData,
    DateFormat dateFormat,
  ) {
    return locationData
        .expand((entry) => _parseLocationEntry(entry, dateFormat))
        .where((summary) => summary != null)
        .cast<LocationTimeSummary>()
        .toList();
  }

  /// Processes a single location data entry to create location time summaries
  ///
  /// Attempts to parse each date-keyed entry into a [LocationTimeSummary],
  /// returns null for entries that fail to parse
  List<LocationTimeSummary?> _parseLocationEntry(
    Map<String, dynamic> entry,
    DateFormat dateFormat,
  ) {
    return entry.entries.map((e) {
      try {
        return LocationTimeSummary(
          date: dateFormat.parse(e.key),
          locationDurations: _parseLocationDurationsFromRawData(e.value),
        );
      } catch (e) {
        return null;
      }
    }).toList();
  }

  /// Extracts the location duration map from the raw data
  Map<String, int> _parseLocationDurationsFromRawData(dynamic data) {
    return Map<String, int>.from(
      (data as Map<String, dynamic>)['locationDurations']
          as Map<String, dynamic>,
    );
  }

  /// Merges two location duration maps by combining durations for matching locations
  ///
  /// If a location exists in both maps, their durations are added together
  Map<String, int> _combineLocationDurations(
    Map<String, int> existingDurations,
    Map<String, int> newDurations,
  ) {
    final mergedDurations = Map<String, int>.from(existingDurations);
    newDurations.forEach((location, duration) {
      mergedDurations[location] = (mergedDurations[location] ?? 0) + duration;
    });
    return mergedDurations;
  }

  /// Updates stored location data with new location summary information
  List<Map<String, dynamic>> mergeLocationSummaryIntoStorage(
    List<Map<String, dynamic>> storedData,
    LocationTimeSummary locationSummary,
    String dateKey,
  ) {
    final existingIndex = storedData.indexWhere(
      (event) => event.containsKey(dateKey),
    );
    const String durationKey = 'locationDurations';
    if (existingIndex >= 0) {
      final existingData = Map<String, dynamic>.from(
        storedData[existingIndex][dateKey] as Map<String, dynamic>,
      );

      final existingDurations = Map<String, int>.from(
        existingData[durationKey] as Map<String, dynamic>,
      );

      existingData[durationKey] = _combineLocationDurations(
        existingDurations,
        locationSummary.locationDurations,
      );

      storedData[existingIndex] = {dateKey: existingData};
    } else {
      storedData.add({dateKey: locationSummary.toMap()});
    }

    return List<Map<String, dynamic>>.from(storedData);
  }
}
