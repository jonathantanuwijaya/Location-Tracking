import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';

/// Mock implementations for model classes
/// This centralized file prevents duplicate mock definitions across tests

/// Mock for LocationTimeSummary
class MockLocationTimeSummary extends Mock implements LocationTimeSummary {}

/// Custom test implementation of LocationTimeSummary
/// Used for controlled testing with predictable output
class TestLocationTimeSummary extends LocationTimeSummary {
  /// Creates a test summary with predefined formatted durations
  TestLocationTimeSummary({
    required DateTime date,
    required Map<String, int> locationDurations,
    required this.formattedDurations,
  }) : super(date: date, locationDurations: locationDurations);

  /// Pre-defined durations map for consistent test output
  final Map<String, String> formattedDurations;

  @override
  Map<String, String> getFormattedDurations() {
    return formattedDurations;
  }
}

/// Mock for GeofenceData
class MockGeofenceData extends Mock implements GeofenceData {}

/// Fake implementation for GeofenceData to use with registerFallbackValue
class FakeGeofenceData extends Fake implements GeofenceData {}

/// Register model-related fallback values
void registerModelFallbackValues() {
  registerFallbackValue(FakeGeofenceData());
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, int>{});
} 