import 'package:tracking_practice/core/constants/location_constants.dart';
import 'package:tracking_practice/core/util/datetime_extension.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

class BackgroundTrackLogic {
  LocationTimeSummary calculateLocationDurationSummary(
    GeofenceData locationData,
    Map<String, int> todayDurations,
  ) {
    final locationName = locationData.name;
    todayDurations[locationName] =
        (todayDurations[locationName] ?? 0) +
        LocationConstants.defaultLocationUpdateIntervalSeconds;

    final summary = LocationTimeSummary(
      date: DateTime.now().toDMYFormatted,
      locationDurations: Map.from(todayDurations),
    );
    return summary;
  }
}
