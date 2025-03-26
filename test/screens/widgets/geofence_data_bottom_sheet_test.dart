import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/screens/widgets/base/base_bottom_sheet.dart';
import 'package:tracking_practice/screens/widgets/base/base_empty_state.dart';
import 'package:tracking_practice/screens/widgets/base/base_error_state.dart';
import 'package:tracking_practice/screens/widgets/geofence_data_bottom_sheet.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';

class MockLocationStorageService extends Mock implements LocationStorageService {}

class MockGeofenceDataBottomSheet extends StatefulWidget {
  final MockLocationStorageService mockStorageService;

  const MockGeofenceDataBottomSheet({
    Key? key,
    required this.mockStorageService,
  }) : super(key: key);

  @override
  State<MockGeofenceDataBottomSheet> createState() => _MockGeofenceDataBottomSheetState();
}

class _MockGeofenceDataBottomSheetState extends State<MockGeofenceDataBottomSheet> {
  late List<GeofenceData> _geofenceData;
  late bool _isLoading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _geofenceData = [];
    _isLoading = true;
    _loadGeofenceData();
  }

  Future<void> _loadGeofenceData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.mockStorageService.getAllGeofenceData();
      setState(() {
        _geofenceData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Geofence Locations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Failed to load geofence data'));
    }

    if (_geofenceData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48),
            SizedBox(height: 16),
            Text('No geofence locations available'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _geofenceData.length,
      itemBuilder: (context, index) {
        final geofence = _geofenceData[index];
        return _buildGeofenceCard(context, geofence);
      },
    );
  }

  Widget _buildGeofenceCard(BuildContext context, GeofenceData geofence) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              geofence.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Latitude:'),
                Text(geofence.latitude.toStringAsFixed(6)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Longitude:'),
                Text(geofence.longitude.toStringAsFixed(6)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GeofenceDataBottomSheetTestFixture {
  final MockLocationStorageService locationStorageService;

  GeofenceDataBottomSheetTestFixture({required this.locationStorageService});

  // Different test scenarios
  static GeofenceDataBottomSheetTestFixture withData() {
    final service = MockLocationStorageService();
    final geofenceData = [
      GeofenceData(name: 'Office', latitude: 37.4220, longitude: -122.0841),
      GeofenceData(name: 'Home', latitude: 37.7749, longitude: -122.4194),
    ];
    
    when(() => service.getAllGeofenceData())
      .thenAnswer((_) async => geofenceData);
    
    return GeofenceDataBottomSheetTestFixture(locationStorageService: service);
  }

  static GeofenceDataBottomSheetTestFixture empty() {
    final service = MockLocationStorageService();
    when(() => service.getAllGeofenceData())
      .thenAnswer((_) async => []);
    
    return GeofenceDataBottomSheetTestFixture(locationStorageService: service);
  }

  static GeofenceDataBottomSheetTestFixture withError() {
    final service = MockLocationStorageService();
    when(() => service.getAllGeofenceData())
      .thenThrow('Failed to load geofence data');
    
    return GeofenceDataBottomSheetTestFixture(locationStorageService: service);
  }

  Widget buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 400,
          child: MockGeofenceDataBottomSheet(
            mockStorageService: locationStorageService,
          ),
        ),
      ),
    );
  }
}

void main() {
  setUp(() {
    registerFallbackValue(0);
  });
  
  group('Geofence Data Bottom Sheet Tests', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      final fixture = GeofenceDataBottomSheetTestFixture.withData();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows geofence data when loaded successfully', (WidgetTester tester) async {
      final fixture = GeofenceDataBottomSheetTestFixture.withData();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Geofence Locations'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Latitude:'), findsNWidgets(2));
      expect(find.text('Longitude:'), findsNWidgets(2));
      expect(find.text('37.422000'), findsOneWidget);
      expect(find.text('-122.084100'), findsOneWidget);
    });

    testWidgets('shows empty state when no geofence data is available', (WidgetTester tester) async {
      final fixture = GeofenceDataBottomSheetTestFixture.empty();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('No geofence locations available'), findsOneWidget);
      expect(find.byIcon(Icons.location_off), findsOneWidget);
    });

    testWidgets('shows error state when loading fails', (WidgetTester tester) async {
      final fixture = GeofenceDataBottomSheetTestFixture.withError();
      
      await tester.pumpWidget(fixture.buildTestableWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Failed to load geofence data'), findsOneWidget);
    });
  });
} 