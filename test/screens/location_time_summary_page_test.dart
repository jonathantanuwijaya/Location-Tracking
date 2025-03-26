import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_practice/screens/location_time_summary_page.dart';

import '../fixtures/screens/location_time_summary_fixture.dart';
import '../fixtures/test_utils.dart';

void main() {
  setUpAll(() {
    registerAllFallbackValues();
  });

  group('LocationTimeSummaryPage Widget Tests', () {
    testWidgets('shows empty state when no data is available', (WidgetTester tester) async {
      final fixture = LocationTimeSummaryPageFixture.loading();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('shows error message when there is an error', (WidgetTester tester) async {
      final fixture = LocationTimeSummaryPageFixture.withError();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Error: Failed to load location data'), findsOneWidget);
    });

    testWidgets('displays location summary data correctly', (WidgetTester tester) async {
      final fixture = LocationTimeSummaryPageFixture.withData();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Summary Page'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Café'), findsOneWidget);
      expect(find.text('5h 30m'), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);
      expect(find.text('0h 45m'), findsOneWidget);
    });
  });
} 