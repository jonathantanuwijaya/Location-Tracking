import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/screens/clock_in_out_page.dart';

// Mock
class MockClockInOutProvider extends Mock implements ClockInOutProvider {}

class ClockInOutPageTestFixture {
  final MockClockInOutProvider clockInOutProvider;

  ClockInOutPageTestFixture({required this.clockInOutProvider});

  // Different test scenarios
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
      home: ChangeNotifierProvider<ClockInOutProvider>.value(
        value: clockInOutProvider,
        child: const ClockInOutPage(),
      ),
    );
  }
}

void main() {
  group('ClockInOutPage Widget Tests', () {
    testWidgets('shows clocked in state correctly', (WidgetTester tester) async {
      // Arrange
      final fixture = ClockInOutPageTestFixture.clockedIn();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Currently Clocked In'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      verify(() => fixture.clockInOutProvider.refreshServiceStatus()).called(1);
    });

    testWidgets('shows clocked out state correctly', (WidgetTester tester) async {
      // Arrange
      final fixture = ClockInOutPageTestFixture.clockedOut();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Currently Clocked Out'), findsOneWidget);
      expect(find.byIcon(Icons.timer_off), findsOneWidget);
      verify(() => fixture.clockInOutProvider.refreshServiceStatus()).called(1);
    });

    testWidgets('shows error state when provider has error', (WidgetTester tester) async {
      // Arrange
      final fixture = ClockInOutPageTestFixture.withError();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Error: Service initialization failed'), findsOneWidget);
      verify(() => fixture.clockInOutProvider.refreshServiceStatus()).called(1);
    });

    testWidgets('calls clockIn when Clock In button is tapped', (WidgetTester tester) async {
      // Arrange
      final fixture = ClockInOutPageTestFixture.clockedOut();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Find and tap the Clock In button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Clock In'));
      await tester.pumpAndSettle();
      
      // Assert
      verify(() => fixture.clockInOutProvider.clockIn()).called(1);
    });

    testWidgets('calls clockOut when Clock Out button is tapped', (WidgetTester tester) async {
      // Arrange
      final fixture = ClockInOutPageTestFixture.clockedIn();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Find and tap the Clock Out button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Clock Out'));
      await tester.pumpAndSettle();
      
      // Assert
      verify(() => fixture.clockInOutProvider.clockOut()).called(1);
    });

    testWidgets('opens Add Geofence bottom sheet when button is tapped', (WidgetTester tester) async {
      // Arrange
      final fixture = ClockInOutPageTestFixture.clockedOut();
      
      // Act
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      // Find and tap the Add Geofence button - using icon instead of text since it's an ElevatedButton.icon
      await tester.tap(find.byIcon(Icons.add_location));
      await tester.pumpAndSettle();
      
      // Assert - Bottom sheet should be visible
      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });
} 