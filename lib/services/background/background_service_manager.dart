// ignore_for_file: avoid_void_async

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:tracking_practice/core/constants/location_constants.dart';
import 'package:tracking_practice/core/constants/service_port_key.dart';
import 'package:tracking_practice/services/background/background_service_handler.dart';

/// Manager for background service operations
class BackgroundServiceManager {
  const BackgroundServiceManager._();

  /// Singleton instance
  static const BackgroundServiceManager instance = BackgroundServiceManager._();

  /// Initialize the background service
  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: false,
        initialNotificationContent:
            LocationConstants.defaultNotificationContent,
        initialNotificationTitle: LocationConstants.defaultNotificationTitle,
        foregroundServiceNotificationId:
            LocationConstants.foregroundServiceNotificationId,
      ),
      iosConfiguration: IosConfiguration(
        onBackground: _onIosBackground,
        autoStart: false,
        onForeground: _onStart,
      ),
    );
  }

  Future<void> startService() async {
    await FlutterBackgroundService().startService();
  }

  Future<bool> isServiceRunning() async {
    return FlutterBackgroundService().isRunning();
  }

  Future<void> stopService() async {
    FlutterBackgroundService().invoke(ServicePortKey.stopService);
  }
}

/// Common background processing logic for both Android and iOS
Future<bool> _handleBackgroundProcessing(ServiceInstance service) async {
  final handler = BackgroundServiceHandler();
  await handler.initializeBackgroundLocationTracking(service);
  return true;
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  if (kReleaseMode) {
    DartPluginRegistrant.ensureInitialized();
  }

  await _handleBackgroundProcessing(service);
}

/// iOS background handler
@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  return _handleBackgroundProcessing(service);
}
