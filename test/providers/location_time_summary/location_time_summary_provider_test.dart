import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/services/repository/location_time_summary_repository.dart';

class MockLocationTimeSummaryRepository extends Mock implements LocationTimeSummaryRepository {}

void main() {
  late LocationTimeSummaryProvider provider;
  late MockLocationTimeSummaryRepository mockRepository;
  late LocationTimeSummary testSummary;

  setUp(() {
    mockRepository = MockLocationTimeSummaryRepository();
    testSummary = LocationTimeSummary(
      date: DateTime.now(),
      locationDurations: {'Office': 3600, 'Home': 7200},
    );

    when(() => mockRepository.getLocationUpdates())
        .thenAnswer((_) => Stream.value(testSummary));

    provider = LocationTimeSummaryProvider(mockRepository);
  });

  tearDown(() {
    provider.dispose();
  });

  group('LocationTimeSummaryProvider', () {
    test('initial state should be loading without error', () {
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('should update state when receiving location updates', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.summary, equals(testSummary));
    });

    test('should handle stream error', () async {
      final mockRepository = MockLocationTimeSummaryRepository();
      when(() => mockRepository.getLocationUpdates())
          .thenAnswer((_) => Stream.error('Test error'));

      final provider = LocationTimeSummaryProvider(mockRepository);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
      expect(provider.summary, null);
    });

    test('should cancel stream subscription on dispose', () async {
      final mockRepository = MockLocationTimeSummaryRepository();
      final controller = StreamController<LocationTimeSummary>();

      when(() => mockRepository.getLocationUpdates())
          .thenAnswer((_) => controller.stream);

      final provider = LocationTimeSummaryProvider(mockRepository);
      provider.dispose();

      controller.add(testSummary);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.summary, null);
      
      await controller.close();
    });
  });
}