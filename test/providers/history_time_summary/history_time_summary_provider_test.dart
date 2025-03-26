import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';

class MockLocationStorageService extends Mock implements LocationStorageService {}

void main() {
  late HistoryTimeSummaryProvider provider;
  late MockLocationStorageService mockStorageService;
  late List<LocationTimeSummary> testSummaries;

  setUp(() {
    mockStorageService = MockLocationStorageService();
    testSummaries = [
      LocationTimeSummary(
        date: DateTime(2023, 1, 2),
        locationDurations: {'Office': 3600, 'Home': 7200},
      ),
      LocationTimeSummary(
        date: DateTime(2023, 1, 1),
        locationDurations: {'Home': 5400, 'Gym': 1800},
      ),
    ];

    when(() => mockStorageService.getAllLocationTimeSummaries())
        .thenAnswer((_) async => testSummaries);

    provider = HistoryTimeSummaryProvider(mockStorageService);
  });

  group('HistoryTimeSummaryProvider', () {
    test('initial state should be loading without error', () {
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('loadSummaries should update state with sorted summaries', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.summaries.length, equals(2));
      expect(provider.summaries.first.date, equals(DateTime(2023, 1, 2)));
      expect(provider.summaries.last.date, equals(DateTime(2023, 1, 1)));
    });

    test('loadSummaries should handle empty data', () async {
      when(() => mockStorageService.getAllLocationTimeSummaries())
          .thenAnswer((_) async => []);

      await provider.loadSummaries();

      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.summaries, isEmpty);
    });

    test('loadSummaries should handle errors', () async {
      when(() => mockStorageService.getAllLocationTimeSummaries())
          .thenThrow(Exception('Test error'));

      await provider.loadSummaries();

      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
    });

    test('refreshSummaries should reload data', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final updatedSummaries = [
        LocationTimeSummary(
          date: DateTime(2023, 1, 3),
          locationDurations: {'Office': 1800},
        ),
      ];
      when(() => mockStorageService.getAllLocationTimeSummaries())
          .thenAnswer((_) async => updatedSummaries);

      await provider.refreshSummaries();

      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.summaries.length, equals(1));
      expect(provider.summaries.first.date, equals(DateTime(2023, 1, 3)));
    });
  });
}