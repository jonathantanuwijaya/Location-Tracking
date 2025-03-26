import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/screens/location_time_summary_page.dart';

import '../mocks/model_mocks.dart';
import '../mocks/provider_mocks.dart';
import '../test_utils.dart';

class LocationTimeSummaryPageFixture {
  final MockLocationTimeSummaryProvider locationTimeSummaryProvider;

  const LocationTimeSummaryPageFixture({
    required this.locationTimeSummaryProvider,
  });

  static LocationTimeSummaryPageFixture loading() {
    final provider = MockLocationTimeSummaryProvider();
    when(() => provider.summary).thenReturn(null);
    when(() => provider.error).thenReturn(null);
    when(() => provider.isLoading).thenReturn(false);
    return LocationTimeSummaryPageFixture(
      locationTimeSummaryProvider: provider,
    );
  }

  static LocationTimeSummaryPageFixture withData() {
    final provider = MockLocationTimeSummaryProvider();

    final summary = createTestLocationSummary();

    when(() => provider.summary).thenReturn(summary);
    when(() => provider.error).thenReturn(null);
    when(() => provider.isLoading).thenReturn(false);

    return LocationTimeSummaryPageFixture(
      locationTimeSummaryProvider: provider,
    );
  }

  static LocationTimeSummaryPageFixture withError({
    String errorMessage = 'Failed to load location data',
  }) {
    final provider = MockLocationTimeSummaryProvider();
    when(() => provider.summary).thenReturn(null);
    when(() => provider.error).thenReturn(errorMessage);
    when(() => provider.isLoading).thenReturn(false);
    return LocationTimeSummaryPageFixture(
      locationTimeSummaryProvider: provider,
    );
  }

  /// Build a testable widget with the configured fixture
  Widget buildTestableWidget() {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          onPrimary: Colors.white,
          primaryContainer: Colors.blue.shade100,
          onPrimaryContainer: Colors.blue.shade900,
        ),
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ChangeNotifierProvider<LocationTimeSummaryProvider>.value(
            value: locationTimeSummaryProvider,
            child: const LocationTimeSummaryPage(),
          ),
        ),
      ),
    );
  }
}
