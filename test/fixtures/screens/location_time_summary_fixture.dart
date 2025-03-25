import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/screens/location_time_summary_page.dart';

import '../mocks/model_mocks.dart';
import '../mocks/provider_mocks.dart';
import '../test_utils.dart';

/// Test fixture for the LocationTimeSummaryPage
class LocationTimeSummaryPageFixture {
  /// Provider mock that will be used in tests
  final MockLocationTimeSummaryProvider locationTimeSummaryProvider;

  /// Construct the fixture with required provider
  const LocationTimeSummaryPageFixture({
    required this.locationTimeSummaryProvider,
  });

  /// Factory for loading state
  static LocationTimeSummaryPageFixture loading() {
    final provider = MockLocationTimeSummaryProvider();
    when(() => provider.summary).thenReturn(null);
    when(() => provider.error).thenReturn(null);
    when(() => provider.isLoading).thenReturn(true);
    return LocationTimeSummaryPageFixture(
      locationTimeSummaryProvider: provider,
    );
  }

  /// Factory for state with data
  static LocationTimeSummaryPageFixture withData() {
    final provider = MockLocationTimeSummaryProvider();
    
    // Create a test summary with predefined formatted durations
    final summary = createTestLocationSummary();
    
    when(() => provider.summary).thenReturn(summary);
    when(() => provider.error).thenReturn(null);
    when(() => provider.isLoading).thenReturn(false);
    
    return LocationTimeSummaryPageFixture(
      locationTimeSummaryProvider: provider,
    );
  }

  /// Factory for error state
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
      home: ChangeNotifierProvider<LocationTimeSummaryProvider>.value(
        value: locationTimeSummaryProvider,
        child: const Scaffold(
          body: LocationTimeSummaryPage(),
        ),
      ),
    );
  }
} 