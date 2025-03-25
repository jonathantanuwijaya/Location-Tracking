import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_practice/screens/location_time_summary_page.dart';

import '../fixtures/screens/location_time_summary_fixture.dart';
import '../fixtures/test_utils.dart';

void main() {
  // Register all needed fallback values at the start
  setUpAll(() {
    registerAllFallbackValues();
  });

  group('LocationTimeSummaryPage Widget Tests', () {
    testWidgets('shows empty state when no data is available', (WidgetTester tester) async {
      // Arrange
      final fixture = LocationTimeSummaryPageFixture.loading();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('shows error message when there is an error', (WidgetTester tester) async {
      // Arrange
      final fixture = LocationTimeSummaryPageFixture.withError();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Error: Failed to load location data'), findsOneWidget);
    });

    testWidgets('displays location summary data correctly', (WidgetTester tester) async {
      // Arrange
      final fixture = LocationTimeSummaryPageFixture.withData();
      
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