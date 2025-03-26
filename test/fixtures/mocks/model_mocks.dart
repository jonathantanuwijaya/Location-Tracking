import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

class MockLocationTimeSummary extends Mock implements LocationTimeSummary {}

class TestLocationTimeSummary extends LocationTimeSummary {
  TestLocationTimeSummary({
    required DateTime date,
    required Map<String, int> locationDurations,
    required this.formattedDurations,
  }) : super(date: date, locationDurations: locationDurations);

  final Map<String, String> formattedDurations;

  @override
  Map<String, String> getFormattedDurations() {
    return formattedDurations;
  }
}

class MockGeofenceData extends Mock implements GeofenceData {}

class FakeGeofenceData extends Fake implements GeofenceData {}

/// Register model-related fallback values
void registerModelFallbackValues() {
  registerFallbackValue(FakeGeofenceData());
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, int>{});
}
