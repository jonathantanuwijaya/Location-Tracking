import 'package:tracking_practice/core/init/service_locator.dart';
import 'package:tracking_practice/core/interfaces/i_background_service_handler.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/logic/background_track_logic.dart';

class LocationDataProcessor implements ILocationDataProcessor {
  LocationDataProcessor({
    BackgroundTrackLogic? backgroundTrackLogic,
    LocationStorageService? storageService,
  }) : _backgroundTrackLogic =
           backgroundTrackLogic ?? locator<BackgroundTrackLogic>(),
       _storageService = storageService ?? locator<LocationStorageService>();
  final BackgroundTrackLogic _backgroundTrackLogic;
  final LocationStorageService _storageService;

  @override
  Future<LocationTimeSummary> processLocationData(
    GeofenceData locationData,
    Map<String, int> currentDurations,
  ) async {
    return _backgroundTrackLogic.calculateLocationDurationSummary(
      locationData,
      currentDurations,
    );
  }

  @override
  Future<void> saveLocationData(LocationTimeSummary summary) async {
    await _storageService.storeLocationData(summary);
  }
}
