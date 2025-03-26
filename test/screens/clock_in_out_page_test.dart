import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/screens/clock_in_out_page.dart';
import 'package:tracking_practice/screens/widgets/add_geofence_bottom_sheet.dart';

class MockClockInOutProvider extends Mock implements ClockInOutProvider {}

class ClockInOutPageTestFixture {
  final MockClockInOutProvider clockInOutProvider;

  ClockInOutPageTestFixture({required this.clockInOutProvider});

  static ClockInOutPageTestFixture clockedIn() {
    final provider = MockClockInOutProvider();
    when(() => provider.isClockedIn).thenReturn(true);
    when(() => provider.error).thenReturn(null);
    when(() => provider.refreshServiceStatus()).thenAnswer((_) async {});
    when(() => provider.clockIn()).thenAnswer((_) async {});
    when(() => provider.clockOut()).thenAnswer((_) async {});
    return ClockInOutPageTestFixture(clockInOutProvider: provider);
  }

  static ClockInOutPageTestFixture clockedOut() {
    final provider = MockClockInOutProvider();
    when(() => provider.isClockedIn).thenReturn(false);
    when(() => provider.error).thenReturn(null);
    when(() => provider.refreshServiceStatus()).thenAnswer((_) async {});
    when(() => provider.clockIn()).thenAnswer((_) async {});
    when(() => provider.clockOut()).thenAnswer((_) async {});
    return ClockInOutPageTestFixture(clockInOutProvider: provider);
  }

  static ClockInOutPageTestFixture withError() {
    final provider = MockClockInOutProvider();
    when(() => provider.isClockedIn).thenReturn(false);
    when(() => provider.error).thenReturn('Service initialization failed');
    when(() => provider.refreshServiceStatus()).thenAnswer((_) async {});
    return ClockInOutPageTestFixture(clockInOutProvider: provider);
  }

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          inversePrimary: Colors.blue.shade200,
          onPrimary: Colors.white,
          primaryContainer: Colors.blue.shade100,
          onPrimaryContainer: Colors.blue.shade900,
        ),
      ),
      home: ChangeNotifierProvider<ClockInOutProvider>.value(
        value: clockInOutProvider,
        child: const ClockInOutPage(),
      ),
    );
  }
}

void main() {
  group('ClockInOutPage Widget Tests', () {
    testWidgets('shows clocked in state correctly', (
      WidgetTester tester,
    ) async {
      final fixture = ClockInOutPageTestFixture.clockedIn();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Currently Clocked In'), findsOneWidget);
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
      verify(() => fixture.clockInOutProvider.refreshServiceStatus()).called(1);
    });

    testWidgets('shows clocked out state correctly', (
      WidgetTester tester,
    ) async {
      final fixture = ClockInOutPageTestFixture.clockedOut();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Currently Clocked Out'), findsOneWidget);
      expect(find.byIcon(Icons.timer_off_rounded), findsOneWidget);
      verify(() => fixture.clockInOutProvider.refreshServiceStatus()).called(1);
    });

    testWidgets('shows error state when provider has error', (
      WidgetTester tester,
    ) async {
      final fixture = ClockInOutPageTestFixture.withError();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Error: Service initialization failed'), findsOneWidget);
      verify(() => fixture.clockInOutProvider.refreshServiceStatus()).called(1);
    });

    testWidgets('calls clockIn when Clock In button is tapped', (
      WidgetTester tester,
    ) async {
      final fixture = ClockInOutPageTestFixture.clockedOut();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();

      final textFinder = find.text('Clock In');
      expect(textFinder, findsOneWidget);

      await tester.tap(textFinder);
      await tester.pumpAndSettle();

      verify(() => fixture.clockInOutProvider.clockIn()).called(1);
    });

    testWidgets('calls clockOut when Clock Out button is tapped', (
      WidgetTester tester,
    ) async {
      final fixture = ClockInOutPageTestFixture.clockedIn();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      final textFinder = find.text('Clock Out');
      expect(textFinder, findsOneWidget);

      await tester.tap(textFinder);
      await tester.pumpAndSettle();

      verify(() => fixture.clockInOutProvider.clockOut()).called(1);
    });

    testWidgets('opens Add Geofence bottom sheet when button is tapped', (
      WidgetTester tester,
    ) async {
      final fixture = ClockInOutPageTestFixture.clockedOut();

      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Geofence Location'), findsOneWidget);
    });
  });
}
