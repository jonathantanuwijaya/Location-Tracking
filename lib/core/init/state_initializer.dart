import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/core/init/service_locator.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';

class StateInitializer extends StatelessWidget {
  const StateInitializer({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocationTimeSummaryProvider>(
          create: (context) => locator<LocationTimeSummaryProvider>(),
        ),
        ChangeNotifierProvider<HistoryTimeSummaryProvider>(
          create: (context) => locator<HistoryTimeSummaryProvider>(),
        ),
        ChangeNotifierProvider<ClockInOutProvider>(
          create: (context) => locator<ClockInOutProvider>()..initialize(),
        ),
        ChangeNotifierProvider<MainTabViewProvider>(
          create: (context) => locator<MainTabViewProvider>(),
        ),
      ],
      child: child,
    );
  }
}
