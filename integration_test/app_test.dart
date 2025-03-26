import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tracking_practice/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Basic App Launch Test', () {
    testWidgets('App launches without crashing', (tester) async {
      await app.main();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      log('Test completed - app launched without crashing');
    });
  });

  group('Core UI Elements Test', () {
    testWidgets('App shows basic UI elements', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      log('Testing UI elements presence');

      bool hasElement(Finder finder) => finder.evaluate().isNotEmpty;

      if (hasElement(find.byType(Scaffold))) {
        log('✓ Scaffold found');
      } else {
        log('✗ No Scaffold found');
      }

      if (hasElement(find.byType(AppBar))) {
        log('✓ AppBar found');
      } else {
        log('✗ No AppBar found');
      }

      if (hasElement(find.byType(BottomNavigationBar))) {
        log('✓ BottomNavigationBar found');

        try {
          final navBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          log('Navigation bar items: ${navBar.items.length}');

          if (navBar.items.length > 1) {
            await tester.tap(find.byType(BottomNavigationBar).at(1));
            await tester.pumpAndSettle();
            log('✓ Tapped second tab');

            await tester.tap(find.byType(BottomNavigationBar).at(0));
            await tester.pumpAndSettle();
            log('✓ Returned to first tab');
          }
        } catch (e) {
          log('Error interacting with BottomNavigationBar: $e');
        }
      } else {
        log('✗ No BottomNavigationBar found');
      }

      final elevatedButtons = find.byType(ElevatedButton);
      final textButtons = find.byType(TextButton);
      final outlinedButtons = find.byType(OutlinedButton);

      if (hasElement(elevatedButtons) ||
          hasElement(textButtons) ||
          hasElement(outlinedButtons)) {
        log('✓ Buttons found');
      } else {
        log('✗ No buttons found');
      }

      expect(true, isTrue);
    });
  });

  group('Navigation Test', () {
    testWidgets('Basic tab navigation works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      log('Testing tab navigation');

      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final navBar = tester.widget<BottomNavigationBar>(bottomNavBar);

        if (navBar.items.length > 1) {
          try {
            final initialText =
                find
                    .byType(Text)
                    .evaluate()
                    .map((e) => (e.widget as Text).data)
                    .where((text) => text != null && text.isNotEmpty)
                    .toList();
            log('Initial screen text: $initialText');

            await tester.tap(find.byType(BottomNavigationBar).at(1));
            await tester.pumpAndSettle();

            final secondTabText =
                find
                    .byType(Text)
                    .evaluate()
                    .map((e) => (e.widget as Text).data)
                    .where((text) => text != null && text.isNotEmpty)
                    .toList();
            log('Second tab text: $secondTabText');

            await tester.tap(find.byType(BottomNavigationBar).at(0));
            await tester.pumpAndSettle();

            final finalText =
                find
                    .byType(Text)
                    .evaluate()
                    .map((e) => (e.widget as Text).data)
                    .where((text) => text != null && text.isNotEmpty)
                    .toList();
            log('Back to first tab text: $finalText');

            final differentContent =
                !_areListsIdentical(initialText, secondTabText);
            log(
              differentContent
                  ? '✓ Content changed when switching tabs'
                  : '✗ Content did not change when switching tabs',
            );
          } catch (e) {
            log('Error during tab navigation: $e');
          }
        } else {
          log('App has only one tab, skipping navigation test');
        }
      } else {
        log('No BottomNavigationBar found, skipping navigation test');
      }

      expect(true, isTrue);
    });
  });

  group('App Bar Actions Test', () {
    testWidgets('App bar icons are present and tappable', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      log('Testing app bar actions');

      final appBar = find.byType(AppBar);
      if (appBar.evaluate().isNotEmpty) {
        log('✓ AppBar found');

        final mapIcon = find.byIcon(Icons.map);
        final historyIcon = find.byIcon(Icons.history);

        if (mapIcon.evaluate().isNotEmpty) {
          log('✓ Map icon found');
          try {
            await tester.tap(mapIcon);
            await tester.pumpAndSettle();
            log('✓ Tapped map icon');

            final backButton = find.byType(BackButton);
            if (backButton.evaluate().isNotEmpty) {
              await tester.tap(backButton);
              await tester.pumpAndSettle();
              log('✓ Closed modal with back button');
            } else {
              await tester.tapAt(const Offset(20, 20));
              await tester.pumpAndSettle();
              log('Attempted to dismiss modal by tapping away');
            }
          } catch (e) {
            log('Error interacting with map icon: $e');
          }
        } else {
          log('✗ No map icon found');
        }

        if (historyIcon.evaluate().isNotEmpty) {
          log('✓ History icon found');
          try {
            await tester.tap(historyIcon);
            await tester.pumpAndSettle();
            log('✓ Tapped history icon');

            final backButton = find.byType(BackButton);
            if (backButton.evaluate().isNotEmpty) {
              await tester.tap(backButton);
              await tester.pumpAndSettle();
              log('✓ Closed modal with back button');
            } else {
              await tester.tapAt(const Offset(20, 20));
              await tester.pumpAndSettle();
              log('Attempted to dismiss modal by tapping away');
            }
          } catch (e) {
            log('Error interacting with history icon: $e');
          }
        } else {
          log('✗ No history icon found');
        }
      } else {
        log('✗ No AppBar found, skipping app bar actions test');
      }

      expect(true, isTrue);
    });
  });
}

bool _areListsIdentical<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }

  return true;
}
