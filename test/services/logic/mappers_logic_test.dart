import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/logic/mappers_logic.dart';

void main() {
  late MappersLogic mappersLogic;
  final dateFormat = DateFormat('dd-MM-yyyy');

  setUp(() {
    mappersLogic = MappersLogic();
  });

  group('MappersLogic', () {
    group('convertToLocationTimeSummaries', () {
      test('converts valid location data to summaries', () {
        final locationData = [
          {
            '10-05-2023': {
              'date': '2023-05-10T00:00:00.000',
              'locationDurations': {'Office': 300, 'Home': 120},
            },
          },
          {
            '11-05-2023': {
              'date': '2023-05-11T00:00:00.000',
              'locationDurations': {'Café': 180, 'Library': 90},
            },
          },
        ];

        final result = mappersLogic.convertToLocationTimeSummaries(
          locationData,
          dateFormat,
        );

        expect(result.length, 2);
        
        expect(result[0].date, DateTime(2023, 5, 10));
        expect(result[0].locationDurations.length, 2);
        expect(result[0].locationDurations['Office'], 300);
        expect(result[0].locationDurations['Home'], 120);
        
        expect(result[1].date, DateTime(2023, 5, 11));
        expect(result[1].locationDurations.length, 2);
        expect(result[1].locationDurations['Café'], 180);
        expect(result[1].locationDurations['Library'], 90);
      });

      test('handles empty data list', () {
        final locationData = <Map<String, dynamic>>[];

        final result = mappersLogic.convertToLocationTimeSummaries(
          locationData,
          dateFormat,
        );

        expect(result, isEmpty);
      });

      test('filters out invalid entries', () {
        final locationData = [
          {
            '10-05-2023': {
              'date': '2023-05-10T00:00:00.000',
              'locationDurations': {'Office': 300, 'Home': 120},
            },
          },
          {
            'invalid-date': {
              'date': 'not-a-date',
              'locationDurations': {'Café': 180},
            },
          },
        ];

        final result = mappersLogic.convertToLocationTimeSummaries(
          locationData,
          dateFormat,
        );

        expect(result.length, 1);
        expect(result[0].date, DateTime(2023, 5, 10));
      });
    });

    group('mergeLocationSummaryIntoStorage', () {
      test('adds new date entry when it does not exist', () {
        final storedData = <Map<String, dynamic>>[
          {
            '10-05-2023': {
              'date': '2023-05-10T00:00:00.000',
              'locationDurations': {'Office': 300, 'Home': 120},
            },
          },
        ];

        final newSummary = LocationTimeSummary(
          date: DateTime(2023, 5, 11),
          locationDurations: {'Café': 180, 'Library': 90},
        );

        final result = mappersLogic.mergeLocationSummaryIntoStorage(
          storedData,
          newSummary,
          '11-05-2023',
        );

        expect(result.length, 2);
        final newEntry = result.firstWhere(
          (entry) => entry.containsKey('11-05-2023'),
        );
        expect(newEntry['11-05-2023']['locationDurations']['Café'], 180);
        expect(newEntry['11-05-2023']['locationDurations']['Library'], 90);
      });

      test('merges durations for existing date entry', () {
        final storedData = <Map<String, dynamic>>[
          {
            '10-05-2023': {
              'date': '2023-05-10T00:00:00.000',
              'locationDurations': {'Office': 300, 'Home': 120},
            },
          },
        ];

        final newSummary = LocationTimeSummary(
          date: DateTime(2023, 5, 10),
          locationDurations: {'Office': 200, 'Café': 180},
        );

        final result = mappersLogic.mergeLocationSummaryIntoStorage(
          storedData,
          newSummary,
          '10-05-2023',
        );

        expect(result.length, 1);
        final updatedEntry = result.first;
        expect(
          updatedEntry['10-05-2023']['locationDurations']['Office'],
          500,
        );
        expect(updatedEntry['10-05-2023']['locationDurations']['Home'], 120);
        expect(updatedEntry['10-05-2023']['locationDurations']['Café'], 180);
      });

      test('handles empty stored data', () {
        final storedData = <Map<String, dynamic>>[];

        final newSummary = LocationTimeSummary(
          date: DateTime(2023, 5, 10),
          locationDurations: {'Office': 300, 'Home': 120},
        );

        final result = mappersLogic.mergeLocationSummaryIntoStorage(
          storedData,
          newSummary,
          '10-05-2023',
        );

        expect(result.length, 1);
        expect(result.first['10-05-2023']['locationDurations']['Office'], 300);
        expect(result.first['10-05-2023']['locationDurations']['Home'], 120);
      });
    });
  });
}