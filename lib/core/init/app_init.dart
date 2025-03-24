import 'dart:async';
import 'dart:developer' as developer;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path_helper;
import 'package:path_provider/path_provider.dart';
import 'package:tracking_practice/services/app_services/service_background.dart';

/// A class responsible for initializing the application components
class ApplicationInitializer {
  /// Main initialization method that orchestrates all initialization tasks
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize device orientation
    await _initDeviceOrientation();

    // Initialize local storage
    await initLocalStorage();

    // Initialize location services
    await _initLocationServices();

    FlutterError.onError = (details) {
      // custom logger
      log(details.exceptionAsString());
      FlutterError.presentError(details);
    };
  }

  /// Initialize device orientation settings
  Future<void> _initDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Initialize location services and permissions
  Future<void> _initLocationServices() async {
    final hasPermission =
        await ServiceBackground.instance.requestLocationPermission();
    if (!hasPermission) {
      developer.log('Location permission denied');
    }

    await ServiceBackground.instance.init();
  }

  /// Initialize local storage (Hive)
  Future<void> initLocalStorage() async {
    final appDir = await getApplicationDocumentsDirectory();
    final hivePath = path_helper.join(appDir.path, '.hidden');
    Hive.init(hivePath);
  }
}
