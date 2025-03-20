import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path/path.dart' as path_helper;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';
import 'package:tracking_practice/services/logic/location_storage_service.dart';
import 'package:tracking_practice/services/logic/service_background.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracking_practice/services/repository/location_time_summary_repository.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/screens/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceBackground.instance.requestLocationPermission();
  ServiceBackground.instance.init();
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(path_helper.join(appDir.path, '.hidden'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Location Tracking',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MainPage(),
      ),
    );
  }
}
