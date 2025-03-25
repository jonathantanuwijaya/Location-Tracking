import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/screens/location_time_summary_page.dart';

// Mocks
class MockLocationTimeSummaryProvider extends Mock implements LocationTimeSummaryProvider {}
class MockLocationTimeSummary extends Mock implements LocationTimeSummary {}

// Custom class to use for testing rather than mocking LocationTimeSummary
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

class LocationTimeSummaryPageTestFixture {
  final MockLocationTimeSummaryProvider locationTimeSummaryProvider;

  LocationTimeSummaryPageTestFixture({required this.locationTimeSummaryProvider});

  // Different test scenarios
  static LocationTimeSummaryPageTestFixture loading() {
    final provider = MockLocationTimeSummaryProvider();
    when(() => provider.summary).thenReturn(null);
    when(() => provider.error).thenReturn(null);
    return LocationTimeSummaryPageTestFixture(locationTimeSummaryProvider: provider);
  }

  static LocationTimeSummaryPageTestFixture withData() {
    final provider = MockLocationTimeSummaryProvider();
    
    // Create a test summary with predefined formatted durations
    final summary = TestLocationTimeSummary(
      date: DateTime(2023, 5, 10),
      locationDurations: {
        'Office': 330 * 60, // 5h 30m in seconds
        'Home': 135 * 60,   // 2h 15m in seconds
        'Café': 45 * 60,    // 45m in seconds
      },
      formattedDurations: {
        'Office': '5h 30m',
        'Home': '2h 15m',
        'Café': '0h 45m',
      },
    );
    
    when(() => provider.summary).thenReturn(summary);
    when(() => provider.error).thenReturn(null);
    
    return LocationTimeSummaryPageTestFixture(locationTimeSummaryProvider: provider);
  }

  static LocationTimeSummaryPageTestFixture withError() {
    final provider = MockLocationTimeSummaryProvider();
    when(() => provider.summary).thenReturn(null);
    when(() => provider.error).thenReturn('Failed to load location data');
    return LocationTimeSummaryPageTestFixture(locationTimeSummaryProvider: provider);
  }

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

void main() {
  group('LocationTimeSummaryPage Widget Tests', () {
    testWidgets('shows empty state when no data is available', (WidgetTester tester) async {
      // Arrange
      final fixture = LocationTimeSummaryPageTestFixture.loading();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('shows error message when there is an error', (WidgetTester tester) async {
      // Arrange
      final fixture = LocationTimeSummaryPageTestFixture.withError();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Error: Failed to load location data'), findsOneWidget);
    });

    testWidgets('displays location summary data correctly', (WidgetTester tester) async {
      // Arrange
      final fixture = LocationTimeSummaryPageTestFixture.withData();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Summary Page'), findsOneWidget);
      
      // Check for the presence of location names
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Café'), findsOneWidget);
      
      // Check durations are displayed (formatted)
      expect(find.text('5h 30m'), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);
      expect(find.text('0h 45m'), findsOneWidget);
    });
  });
} 