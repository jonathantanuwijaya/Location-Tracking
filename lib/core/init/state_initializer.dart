import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/app_services/service_background.dart';
import 'package:tracking_practice/services/repository/location_time_summary_repository.dart';

class StateInitializer extends StatelessWidget {
  final Widget child;
  const StateInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (context) => LocationTimeSummaryProvider(
                LocationTimeSummaryRepository(FlutterBackgroundService()),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => HistoryTimeSummaryProvider(LocationStorageService()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => ClockInOutProvider(
                ServiceBackground.instance,
                LocationStorageService(),
              ),
        ),
        ChangeNotifierProvider<MainTabViewProvider>(
          create: (context) => MainTabViewProvider(),
        ),
      ],
      child: child,
    );
  }
}
