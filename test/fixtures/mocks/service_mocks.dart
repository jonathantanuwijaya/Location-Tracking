import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/core/util/hive_storage.dart';
import 'package:tracking_practice/services/app_services/location_service.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/background/service_background.dart';

/// Mock implementations for service classes
/// This centralized file prevents duplicate mock definitions across tests

/// Mock for LocationService
class MockLocationService extends Mock implements GeolocatorLocationService {}

/// Mock for ServiceBackground
class MockServiceBackground extends Mock implements ServiceBackground {}

/// Mock for LocationStorageService
class MockLocationStorageService extends Mock implements LocationStorageService {}

/// Mock for HiveStorage
class MockHiveStorage extends Mock implements HiveStorage {}

/// Register service-related fallback values
void registerServiceFallbackValues() {
  registerFallbackValue('any-key');
  registerFallbackValue('any-value');
  registerFallbackValue(Future<void>.value());
} 