import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';

class MockMainTabViewProvider extends Mock implements MainTabViewProvider {}

class MockClockInOutProvider extends Mock implements ClockInOutProvider {}

class MockLocationTimeSummaryProvider extends Mock
    implements LocationTimeSummaryProvider {}

class MockHistoryTimeSummaryProvider extends Mock
    implements HistoryTimeSummaryProvider {}

void registerFallbackValues() {
  registerFallbackValue(0); // For tab index
}
