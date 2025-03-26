import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_practice/core/constants/location_constants.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/services/logic/background_track_logic.dart';

void main() {
  late BackgroundTrackLogic backgroundTrackLogic;

  setUp(() {
    backgroundTrackLogic = BackgroundTrackLogic();
  });

  group('BackgroundTrackLogic', () {
    test(
      'calculateLocationDurationSummary should create summary with correct location name',
      () {
        final locationData = GeofenceData(
          latitude: 37.7749,
          longitude: -122.4194,
          name: 'Office',
        );
        final result = backgroundTrackLogic.calculateLocationDurationSummary(
          locationData,
          {},
        );

        expect(result.locationDurations.containsKey('Office'), true);
        expect(
          result.locationDurations['Office'],
          LocationConstants.defaultLocationUpdateIntervalSeconds,
        );
      },
    );

    test('calculateLocationDurationSummary should use current date', () {
      final locationData = GeofenceData(
        latitude: 37.7749,
        longitude: -122.4194,
        name: 'Home',
      );
      final today = DateTime.now().toLocal();

      final result = backgroundTrackLogic.calculateLocationDurationSummary(
        locationData,
        {},
      );

      expect(result.date.year, today.year);
      expect(result.date.month, today.month);
      expect(result.date.day, today.day);
    });

    test(
      'calculateLocationDurationSummary should handle different location names',
      () {
        final locationData1 = GeofenceData(
          latitude: 37.7749,
          longitude: -122.4194,
          name: 'Office',
        );
        final locationData2 = GeofenceData(
          latitude: 40.7128,
          longitude: -74.0060,
          name: 'Traveling',
        );

        final result1 = backgroundTrackLogic.calculateLocationDurationSummary(
          locationData1,
          {},
        );
        final result2 = backgroundTrackLogic.calculateLocationDurationSummary(
          locationData2,
          {},
        );

        expect(result1.locationDurations.containsKey('Office'), true);
        expect(result2.locationDurations.containsKey('Traveling'), true);
      },
    );
  });
}
