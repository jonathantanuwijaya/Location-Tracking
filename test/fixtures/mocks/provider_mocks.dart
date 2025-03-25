import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';

/// Mock implementations for provider classes
/// This centralized file prevents duplicate mock definitions across tests

/// Mock for MainTabViewProvider
class MockMainTabViewProvider extends Mock implements MainTabViewProvider {}

/// Mock for ClockInOutProvider
class MockClockInOutProvider extends Mock implements ClockInOutProvider {}

/// Mock for LocationTimeSummaryProvider
class MockLocationTimeSummaryProvider extends Mock implements LocationTimeSummaryProvider {}

/// Mock for HistoryTimeSummaryProvider
class MockHistoryTimeSummaryProvider extends Mock implements HistoryTimeSummaryProvider {}

/// Register common fallback values needed for mocktail
void registerFallbackValues() {
  // Register common parameter types used in verify() or any() calls
  registerFallbackValue(0); // For tab index
} 