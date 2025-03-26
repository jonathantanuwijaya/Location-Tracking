import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/screens/main_page.dart';

import '../fixtures/screens/main_page_fixture.dart';
import '../fixtures/test_utils.dart';

void main() {
  setUpAll(() {
    registerAllFallbackValues();
  });

  group('MainPage Widget Tests', () {
    testWidgets('renders correctly with Clock In/Out tab selected', (WidgetTester tester) async {
      final fixture = MainPageFixture.standard();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Clock In/Out'), findsNWidgets(2));
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('changes tab when bottom navigation bar item is tapped', (WidgetTester tester) async {
      final fixture = MainPageFixture.standard();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.location_on));
      
      verify(() => fixture.mainTabViewProvider.changeTab(1)).called(1);
    });

    testWidgets('updates title when selected tab changes', (WidgetTester tester) async {
      final fixture = MainPageFixture.standard(selectedTab: 1);
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Location Summary'), findsAtLeastNWidgets(1));
    });
  });
} 