import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/screens/main_page.dart';

import '../fixtures/screens/main_page_fixture.dart';
import '../fixtures/test_utils.dart';


class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  setUpAll(() {
    registerAllFallbackValues();
  });

  group('MainPage Widget Tests', () {
    testWidgets('renders correctly with Clock In/Out tab selected', (
      WidgetTester tester,
    ) async {
      final fixture = MainPageFixture.standard();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Clock In Out'), findsNWidgets(2));
      expect(find.text('Location Summary'), findsOneWidget);
    });

    testWidgets('changes tab when bottom navigation bar item is tapped', (
      WidgetTester tester,
    ) async {
      final fixture = MainPageFixture.standard();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();


      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);

      await tester.tap(find.text('Location Summary'));
      await tester.pumpAndSettle();

      verify(() => fixture.mainTabViewProvider.changeTab(1)).called(1);
    });

    testWidgets('updates title when selected tab changes', (
      WidgetTester tester,
    ) async {
      final fixture = MainPageFixture.standard(selectedTab: 1);

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Location Summary'), findsAtLeastNWidgets(1));
    });

    testWidgets('has map icon button in app bar', (WidgetTester tester) async {
      final fixture = MainPageFixture.standard();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      final iconButtons = find.descendant(
        of: appBarFinder,
        matching: find.byType(IconButton),
      );

      // There should be at least 2 icon buttons (map and history)
      expect(iconButtons, findsAtLeastNWidgets(2));
    });
  });
}
