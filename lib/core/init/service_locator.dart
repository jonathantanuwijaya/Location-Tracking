import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_it/get_it.dart';
import 'package:tracking_practice/core/init/app_init.dart';
import 'package:tracking_practice/core/interfaces/i_background_service_handler.dart';
import 'package:tracking_practice/core/interfaces/i_location_service.dart';
import 'package:tracking_practice/core/interfaces/i_location_storage_service.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';
import 'package:tracking_practice/services/app_services/location_data_service.dart';
import 'package:tracking_practice/services/app_services/location_service.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/background/service_background.dart';
import 'package:tracking_practice/services/logic/background_track_logic.dart';
import 'package:tracking_practice/services/logic/location_tracking_logic.dart';
import 'package:tracking_practice/services/repository/location_time_summary_repository.dart';

final GetIt locator = GetIt.instance;

// Initialize all service dependencies
void setupServiceLocator() {
  // Register base services first
  _registerBaseServices();

  // Register logic services
  _registerLogicServices();

  // Register application services
  _registerApplicationServices();

  // Register providers
  _registerProviders();
}

// Register base services that don't have dependencies
void _registerBaseServices() {
  // Location service
  locator
    ..registerLazySingleton<ILocationService>(GeolocatorLocationService.new)
    // Application initializer
    ..registerLazySingleton<ApplicationInitializer>(ApplicationInitializer.new)
    // Storage service
    ..registerLazySingleton<LocationStorageService>(LocationStorageService.new)
    // Register interface implementation
    ..registerLazySingleton<ILocationStorageService>(locator.call);
}

// Register logic services
void _registerLogicServices() {
  // Background track logic
  locator
    ..registerLazySingleton<BackgroundTrackLogic>(BackgroundTrackLogic.new)
    // Location tracking logic
    ..registerLazySingleton<LocationTrackingLogic>(LocationTrackingLogic.new)
    // Location data processor
    ..registerLazySingleton<ILocationDataProcessor>(
      () => LocationDataProcessor(
        backgroundTrackLogic: locator<BackgroundTrackLogic>(),
        storageService: locator<LocationStorageService>(),
      ),
    );
}

// Register application services
void _registerApplicationServices() {
  // Service background
  locator.registerLazySingleton<ServiceBackground>(ServiceBackground.new);
}

// Register providers
void _registerProviders() {
  // Main tab view provider
  locator
    ..registerFactory<MainTabViewProvider>(MainTabViewProvider.new)
    // Location time summary provider
    ..registerLazySingleton<LocationTimeSummaryProvider>(
      () => LocationTimeSummaryProvider(
        LocationTimeSummaryRepository(FlutterBackgroundService()),
      ),
    )
    // History time summary provider
    ..registerLazySingleton<HistoryTimeSummaryProvider>(
      () => HistoryTimeSummaryProvider(locator<LocationStorageService>()),
    )
    // Clock in/out provider
    ..registerLazySingleton<ClockInOutProvider>(
      () => ClockInOutProvider(
        locator<ServiceBackground>(),
        locator<LocationStorageService>(),
      ),
    );
}
