import 'package:flutter/material.dart';
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
      
      expect(find.text('No Time Data Available'), findsOneWidget);
      expect(find.text('Clock in to start tracking your location time'), findsOneWidget);
      expect(find.byIcon(Icons.timer_off_rounded), findsOneWidget);
    });

    testWidgets('shows error message when there is an error', (WidgetTester tester) async {
      final fixture = LocationTimeSummaryPageFixture.withError();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Failed to load location data'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('displays location summary data correctly', (WidgetTester tester) async {
      final fixture = LocationTimeSummaryPageFixture.withData();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Time Summary'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Café'), findsOneWidget);
      expect(find.text('Time spent'), findsAtLeastNWidgets(1));
      expect(find.text('5h 30m'), findsOneWidget);
      expect(find.text('2h 15m'), findsOneWidget);
      expect(find.text('0h 45m'), findsOneWidget);
    });
  });
} 