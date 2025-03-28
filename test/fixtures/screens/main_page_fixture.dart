import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';
import 'package:tracking_practice/screens/main_page.dart';

import '../mocks/provider_mocks.dart';

class MainPageFixture {
  /// All provider mocks required by the MainPage
  final MockMainTabViewProvider mainTabViewProvider;
  final MockClockInOutProvider clockInOutProvider;
  final MockLocationTimeSummaryProvider locationTimeSummaryProvider;
  final MockHistoryTimeSummaryProvider historyTimeSummaryProvider;

  const MainPageFixture({
    required this.mainTabViewProvider,
    required this.clockInOutProvider,
    required this.locationTimeSummaryProvider,
    required this.historyTimeSummaryProvider,
  });

  static MainPageFixture standard({int selectedTab = 0}) {
    final mainTabViewProvider = MockMainTabViewProvider();
    final clockInOutProvider = MockClockInOutProvider();
    final locationTimeSummaryProvider = MockLocationTimeSummaryProvider();
    final historyTimeSummaryProvider = MockHistoryTimeSummaryProvider();

    when(() => mainTabViewProvider.selectedIndex).thenReturn(selectedTab);
    when(() => mainTabViewProvider.changeTab(any())).thenAnswer((_) {});

    when(() => clockInOutProvider.error).thenReturn(null);
    when(() => clockInOutProvider.isClockedIn).thenReturn(false);
    when(
      () => clockInOutProvider.refreshServiceStatus(),
    ).thenAnswer((_) async {});
    when(() => clockInOutProvider.clockIn()).thenAnswer((_) async {});
    when(() => clockInOutProvider.clockOut()).thenAnswer((_) async {});

    when(() => locationTimeSummaryProvider.error).thenReturn(null);
    when(() => locationTimeSummaryProvider.summary).thenReturn(null);
    when(() => locationTimeSummaryProvider.isLoading).thenReturn(false);

    when(() => historyTimeSummaryProvider.error).thenReturn(null);
    when(() => historyTimeSummaryProvider.isLoading).thenReturn(false);
    when(() => historyTimeSummaryProvider.summaries).thenReturn([]);
    when(
      () => historyTimeSummaryProvider.refreshSummaries(),
    ).thenAnswer((_) async {});

    return MainPageFixture(
      mainTabViewProvider: mainTabViewProvider,
      clockInOutProvider: clockInOutProvider,
      locationTimeSummaryProvider: locationTimeSummaryProvider,
      historyTimeSummaryProvider: historyTimeSummaryProvider,
    );
  }

  static MainPageFixture clockedIn() {
    final fixture = standard();
    when(() => fixture.clockInOutProvider.isClockedIn).thenReturn(true);
    return fixture;
  }

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainTabViewProvider>.value(
          value: mainTabViewProvider,
        ),
        ChangeNotifierProvider<ClockInOutProvider>.value(
          value: clockInOutProvider,
        ),
        ChangeNotifierProvider<LocationTimeSummaryProvider>.value(
          value: locationTimeSummaryProvider,
        ),
        ChangeNotifierProvider<HistoryTimeSummaryProvider>.value(
          value: historyTimeSummaryProvider,
        ),
      ],
      child: MaterialApp(
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
        home: const MainPage(),
      ),
    );
  }
}
