import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';
import 'package:tracking_practice/services/background/service_background.dart';

class MockServiceBackground extends Mock implements ServiceBackground {}
class MockLocationStorageService extends Mock implements LocationStorageService {}

class FakeGeofenceData extends Fake implements GeofenceData {}

void main() {
  late ClockInOutProvider provider;
  late MockServiceBackground mockServiceBackground;
  late MockLocationStorageService mockLocationStorageService;

  setUpAll(() {
    registerFallbackValue(FakeGeofenceData());
  });

  setUp(() {
    mockServiceBackground = MockServiceBackground();
    mockLocationStorageService = MockLocationStorageService();
    provider = ClockInOutProvider(
      mockServiceBackground,
      mockLocationStorageService,
    );
  });

  group('ClockInOutProvider', () {
    test('initialize - sets initial state correctly', () async {
      // Arrange
      when(() => mockServiceBackground.isRunning())
          .thenAnswer((_) async => true);
      when(() => mockLocationStorageService.getAllGeofenceData())
          .thenAnswer((_) async => [
                GeofenceData(
                  name: 'Test Location',
                  latitude: 37.4220,
                  longitude: -122.0841,
                ),
              ]);

      // Act
      await provider.initialize();

      // Assert
      expect(provider.isClockedIn, true);
      expect(provider.geofenceData.length, 1);
      expect(provider.geofenceData.first.name, 'Test Location');
      expect(provider.error, null);
    });

    test('initialize - handles errors', () async {
      // Arrange
      when(() => mockServiceBackground.isRunning())
          .thenThrow(Exception('Test error'));

      // Act
      await provider.initialize();

      // Assert
      expect(provider.error, contains('Failed to initialize provider'));
    });

    test('clockIn - sets isClockedIn to true when successful', () async {
      // Arrange
      when(() => mockServiceBackground.start()).thenAnswer((_) async => {});

      // Act
      await provider.clockIn();

      // Assert
      expect(provider.isClockedIn, true);
      expect(provider.error, null);
      verify(() => mockServiceBackground.start()).called(1);
    });

    test('clockIn - handles errors', () async {
      // Arrange
      when(() => mockServiceBackground.start())
          .thenThrow(Exception('Test error'));

      // Act
      await provider.clockIn();

      // Assert
      expect(provider.isClockedIn, false);
      expect(provider.error, contains('Failed to clock in'));
      verify(() => mockServiceBackground.start()).called(1);
    });

    test('clockOut - sets isClockedIn to false when successful', () async {
      // Arrange
      when(() => mockServiceBackground.stop()).thenAnswer((_) async => {});
      
      // First make sure it's clocked in by calling clockIn
      when(() => mockServiceBackground.start()).thenAnswer((_) async => {});
      await provider.clockIn();
      expect(provider.isClockedIn, true); // Verify setup

      // Act
      await provider.clockOut();

      // Assert
      expect(provider.isClockedIn, false);
      expect(provider.error, null);
      verify(() => mockServiceBackground.stop()).called(1);
    });

    test('clockOut - handles errors', () async {
      // Arrange
      when(() => mockServiceBackground.stop())
          .thenThrow(Exception('Test error'));
      
      // First make sure it's clocked in by calling clockIn
      when(() => mockServiceBackground.start()).thenAnswer((_) async => {});
      await provider.clockIn();
      expect(provider.isClockedIn, true); // Verify setup

      // Act
      await provider.clockOut();

      // Assert
      expect(provider.error, contains('Failed to clock out'));
      verify(() => mockServiceBackground.stop()).called(1);
    });

    test('validateCoordinate - returns null for valid coordinates', () {
      // Act & Assert
      expect(provider.validateCoordinate('37.4220'), null);
      expect(provider.validateCoordinate('-122.0841'), null);
      expect(provider.validateCoordinate('0'), null);
    });

    test('validateCoordinate - returns error message for invalid coordinates', () {
      // Act & Assert
      expect(provider.validateCoordinate(null), 'This field is required');
      expect(provider.validateCoordinate(''), 'This field is required');
      expect(provider.validateCoordinate('abc'), 'Invalid coordinate format');
    });

    test('validateName - returns null for valid names', () {
      // Act & Assert
      expect(provider.validateName('Test Location'), null);
    });

    test('validateName - returns error message for invalid names', () {
      // Act & Assert
      expect(provider.validateName(null), 'Name is required');
      expect(provider.validateName(''), 'Name is required');
    });

    test('validateAndSaveGeofenceData - returns success when valid', () async {
      // Arrange
      when(() => mockLocationStorageService.storeGeofenceData(any()))
          .thenAnswer((_) async => {});
      when(() => mockLocationStorageService.getAllGeofenceData())
          .thenAnswer((_) async => [
                GeofenceData(
                  name: 'Test Location',
                  latitude: 37.4220,
                  longitude: -122.0841,
                ),
              ]);

      // Act
      final result = await provider.validateAndSaveGeofenceData(
        '37.4220',
        '-122.0841',
        'Test Location',
      );

      // Assert
      expect(result.$1, true);
      expect(result.$2, null);
      expect(provider.geofenceData.length, 1);
      verify(() => mockLocationStorageService.storeGeofenceData(any())).called(1);
    });

    test('validateAndSaveGeofenceData - returns error when invalid', () async {
      // Act
      final result = await provider.validateAndSaveGeofenceData(
        '',
        '-122.0841',
        'Test Location',
      );

      // Assert
      expect(result.$1, false);
      expect(result.$2, 'This field is required');
      verifyNever(() => mockLocationStorageService.storeGeofenceData(any()));
    });

    test('refreshServiceStatus - updates isClockedIn status', () async {
      // Arrange
      when(() => mockServiceBackground.isRunning())
          .thenAnswer((_) async => true);

      // Act
      await provider.refreshServiceStatus();

      // Assert
      expect(provider.isClockedIn, true);
      expect(provider.error, null);
      verify(() => mockServiceBackground.isRunning()).called(1);
    });

    test('refreshServiceStatus - handles errors', () async {
      // Arrange
      when(() => mockServiceBackground.isRunning())
          .thenThrow(Exception('Test error'));

      // Act
      await provider.refreshServiceStatus();

      // Assert
      expect(provider.error, contains('Failed to refresh service status'));
    });
  });
} 