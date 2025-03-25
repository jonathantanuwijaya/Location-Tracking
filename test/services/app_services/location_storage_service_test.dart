import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/core/constants/storage_key.dart';
import 'package:tracking_practice/core/util/hive_storage.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';

class MockHiveStorage extends Mock implements HiveStorage {}

void main() {
  late LocationStorageService service;
  late MockHiveStorage mockStorage;
  final dateFormat = DateFormat('dd-MM-yyyy');

  setUp(() {
    mockStorage = MockHiveStorage();
    service = LocationStorageService(storage: mockStorage);
    
    // Register fallback values
    registerFallbackValue(StorageKeyConstant.clockInOutData);
    registerFallbackValue(StorageKeyConstant.geofenceData);
    registerFallbackValue('any-data');
  });

  group('LocationStorageService', () {
    group('storeLocationData', () {
      test('adds new data when no existing data', () async {
        // Arrange
        final locationSummary = LocationTimeSummary(
          date: DateTime(2023, 5, 10),
          locationDurations: {'Office': 300, 'Home': 120},
        );
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenAnswer((_) async => null);
        when(() => mockStorage.insert(any(), any()))
            .thenAnswer((_) async => {});

        // Act
        await service.storeLocationData(locationSummary);

        // Assert - just check that insert was called with the right key
        verify(() => mockStorage.insert(
              StorageKeyConstant.clockInOutData,
              any(),
            )).called(1);
      });

      test('merges data when existing data for date exists', () async {
        // Arrange
        final locationSummary = LocationTimeSummary(
          date: DateTime(2023, 5, 10),
          locationDurations: {'Office': 300, 'Home': 120},
        );
        
        final existingData = [
          {
            '10-05-2023': {
              'date': '2023-05-10T00:00:00.000',
              'locationDurations': {'Office': 200, 'Café': 100},
            },
          },
        ];
        
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenAnswer((_) async => jsonEncode(existingData));
        
        List<dynamic> capturedData = [];
        when(() => mockStorage.insert(any(), any()))
            .thenAnswer((invocation) {
              final data = invocation.positionalArguments[1] as String;
              capturedData.add(jsonDecode(data));
              return Future.value();
            });

        // Act
        await service.storeLocationData(locationSummary);

        // Assert
        verify(() => mockStorage.insert(any(), any())).called(1);
        
        // Check the captured data
        final List<dynamic> decodedJson = capturedData.first as List;
        final Map<String, dynamic> firstEntry = decodedJson.first as Map<String, dynamic>;
        final Map<String, dynamic> dateEntry = firstEntry['10-05-2023'] as Map<String, dynamic>;
        final Map<String, dynamic> durations = dateEntry['locationDurations'] as Map<String, dynamic>;
        
        // Check if durations were properly merged
        expect(durations['Office'], 500); // 200 + 300
        expect(durations['Home'], 120);
        expect(durations['Café'], 100);
      });

      test('handles errors gracefully', () async {
        // Arrange
        final locationSummary = LocationTimeSummary(
          date: DateTime(2023, 5, 10),
          locationDurations: {'Office': 300, 'Home': 120},
        );
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenThrow('Storage error');

        // Act & Assert
        await expectLater(
          () => service.storeLocationData(locationSummary),
          throwsA(anything),
        );
      });
    });

    group('getAllLocationData', () {
      test('returns parsed data when available', () async {
        // Arrange
        final mockData = [
          {
            '10-05-2023': {
              'date': '2023-05-10T00:00:00.000',
              'locationDurations': {'Office': 300, 'Home': 120},
            },
          },
        ];
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenAnswer((_) async => jsonEncode(mockData));

        // Act
        final result = await service.getAllLocationData();

        // Assert
        expect(result.length, 1);
        expect(result.first.keys.first, '10-05-2023');
      });

      test('returns empty list when no data', () async {
        // Arrange
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getAllLocationData();

        // Assert
        expect(result, isEmpty);
      });

      test('returns empty list on error', () async {
        // Arrange
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenThrow('Storage error');

        // Act
        final result = await service.getAllLocationData();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getAllLocationTimeSummaries', () {
      test('returns properly mapped summaries', () async {
        // Arrange
        final mockData = [
          {
            '10-05-2023': {
              'date': '2023-05-10T00:00:00.000',
              'locationDurations': {'Office': 300, 'Home': 120},
            },
          },
        ];
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenAnswer((_) async => jsonEncode(mockData));

        // Act
        final result = await service.getAllLocationTimeSummaries();

        // Assert
        expect(result.length, 1);
        expect(result.first.date, DateTime(2023, 5, 10));
        expect(result.first.locationDurations['Office'], 300);
        expect(result.first.locationDurations['Home'], 120);
      });

      test('returns empty list when no data', () async {
        // Arrange
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getAllLocationTimeSummaries();

        // Assert
        expect(result, isEmpty);
      });

      test('handles errors gracefully', () async {
        // Arrange
        when(() => mockStorage.get(StorageKeyConstant.clockInOutData))
            .thenThrow('Storage error');

        // Act
        final result = await service.getAllLocationTimeSummaries();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('storeGeofenceData', () {
      test('adds new geofence when none exists with same name', () async {
        // Arrange
        final geofenceData = GeofenceData(
          name: 'New Office',
          latitude: 37.4220,
          longitude: -122.0841,
        );
        
        final existingGeofences = [
          {
            'name': 'Home',
            'latitude': 37.7749,
            'longitude': -122.4194,
          },
        ];
        
        when(() => mockStorage.get(StorageKeyConstant.geofenceData))
            .thenAnswer((_) async => jsonEncode(existingGeofences));
        
        List<dynamic> capturedData = [];
        when(() => mockStorage.insert(any(), any()))
            .thenAnswer((invocation) {
              final data = invocation.positionalArguments[1] as String;
              capturedData.add(jsonDecode(data));
              return Future.value();
            });

        // Act
        await service.storeGeofenceData(geofenceData);

        // Assert
        verify(() => mockStorage.insert(any(), any())).called(1);
        
        // Check the captured data
        final List<dynamic> decodedJson = capturedData.first as List;
        expect(decodedJson.length, 2); // Both Home and New Office
        
        // Find the New Office entry
        final newOfficeEntry = decodedJson.firstWhere(
          (item) => (item as Map<String, dynamic>)['name'] == 'New Office',
          orElse: () => null,
        );
        
        expect(newOfficeEntry, isNotNull);
        expect(newOfficeEntry['latitude'], 37.422);
        expect(newOfficeEntry['longitude'], -122.0841);
      });

      test('updates existing geofence with same name', () async {
        // Arrange
        final geofenceData = GeofenceData(
          name: 'Home',
          latitude: 37.8888,  // Updated coordinates
          longitude: -122.9999,
        );
        
        final existingGeofences = [
          {
            'name': 'Home',
            'latitude': 37.7749,
            'longitude': -122.4194,
          },
        ];
        
        when(() => mockStorage.get(StorageKeyConstant.geofenceData))
            .thenAnswer((_) async => jsonEncode(existingGeofences));
        
        List<dynamic> capturedData = [];
        when(() => mockStorage.insert(any(), any()))
            .thenAnswer((invocation) {
              final data = invocation.positionalArguments[1] as String;
              capturedData.add(jsonDecode(data));
              return Future.value();
            });

        // Act
        await service.storeGeofenceData(geofenceData);

        // Assert
        verify(() => mockStorage.insert(any(), any())).called(1);
        
        // Check the captured data
        final List<dynamic> decodedJson = capturedData.first as List;
        expect(decodedJson.length, 1); // Still only one geofence
        
        final geofence = decodedJson.first as Map<String, dynamic>;
        expect(geofence['name'], 'Home');
        expect(geofence['latitude'], 37.8888);
        expect(geofence['longitude'], -122.9999);
      });

      test('handles errors gracefully', () async {
        // Arrange
        final geofenceData = GeofenceData(
          name: 'Office',
          latitude: 37.4220,
          longitude: -122.0841,
        );
        when(() => mockStorage.get(StorageKeyConstant.geofenceData))
            .thenThrow('Storage error');

        // Act & Assert
        await expectLater(
          () => service.storeGeofenceData(geofenceData),
          throwsA(anything),
        );
      });
    });

    group('getAllGeofenceData', () {
      test('returns parsed geofence data when available', () async {
        // Arrange
        final mockData = [
          {
            'name': 'Office',
            'latitude': 37.4220,
            'longitude': -122.0841,
          },
          {
            'name': 'Home',
            'latitude': 37.7749,
            'longitude': -122.4194,
          },
        ];
        when(() => mockStorage.get(StorageKeyConstant.geofenceData))
            .thenAnswer((_) async => jsonEncode(mockData));

        // Act
        final result = await service.getAllGeofenceData();

        // Assert
        expect(result.length, 2);
        expect(result[0].name, 'Office');
        expect(result[0].latitude, 37.4220);
        expect(result[0].longitude, -122.0841);
        expect(result[1].name, 'Home');
      });

      test('returns empty list when no data', () async {
        // Arrange
        when(() => mockStorage.get(StorageKeyConstant.geofenceData))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getAllGeofenceData();

        // Assert
        expect(result, isEmpty);
      });

      test('returns empty list on error', () async {
        // Arrange
        when(() => mockStorage.get(StorageKeyConstant.geofenceData))
            .thenThrow('Storage error');

        // Act
        final result = await service.getAllGeofenceData();

        // Assert
        expect(result, isEmpty);
      });
    });
  });
} 