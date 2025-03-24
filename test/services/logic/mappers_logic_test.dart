import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/logic/mappers_logic.dart';

void main() {
  late MappersLogic mappersLogic;
  late DateFormat dateFormat;

  setUp(() {
    mappersLogic = MappersLogic();
    dateFormat = DateFormat('dd-MM-yyyy');
  });

  group('MappersLogic', () {
    test('convertToLocationTimeSummaries should parse valid location data correctly', () {
      // Arrange
      final locationData = [
        {
          '01-01-2023': {
            'locationDurations': {
              'Home': 3600,
              'Office': 7200,
            }
          },
          '02-01-2023': {
            'locationDurations': {
              'Home': 5400,
              'Gym': 1800,
            }
          }
        }
      ];

      // Act
      final result = mappersLogic.convertToLocationTimeSummaries(locationData, dateFormat);

      // Assert
      expect(result.length, 2);
      expect(result[0].date, dateFormat.parse('01-01-2023'));
      expect(result[0].locationDurations['Home'], 3600);
      expect(result[0].locationDurations['Office'], 7200);
      expect(result[1].date, dateFormat.parse('02-01-2023'));
      expect(result[1].locationDurations['Home'], 5400);
      expect(result[1].locationDurations['Gym'], 1800);
    });

    test('convertToLocationTimeSummaries should handle empty location data', () {
      // Arrange
      final locationData = <Map<String, dynamic>>[];

      // Act
      final result = mappersLogic.convertToLocationTimeSummaries(locationData, dateFormat);

      // Assert
      expect(result, isEmpty);
    });

    test('convertToLocationTimeSummaries should filter out invalid entries', () {
      // Arrange
      final locationData = [
        {
          'invalid-date': {
            'locationDurations': {
              'Home': 3600,
            }
          },
          '01-01-2023': {
            'locationDurations': {
              'Office': 7200,
            }
          }
        }
      ];

      // Act
      final result = mappersLogic.convertToLocationTimeSummaries(locationData, dateFormat);

      // Assert
      expect(result.length, 1);
      expect(result[0].date, dateFormat.parse('01-01-2023'));
      expect(result[0].locationDurations['Office'], 7200);
    });

    test('LocationTimeSummary.formatDuration should format seconds correctly', () {
      // Act & Assert
      expect(LocationTimeSummary.formatDuration(3600), '1h 0m');
      expect(LocationTimeSummary.formatDuration(5400), '1h 30m');
      expect(LocationTimeSummary.formatDuration(7200), '2h 0m');
      expect(LocationTimeSummary.formatDuration(7230), '2h 0m');
      expect(LocationTimeSummary.formatDuration(0), '0h 0m');
    });
  });
}