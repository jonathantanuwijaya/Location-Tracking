import 'package:flutter/material.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/services/logic/location_storage_service.dart';

class GeofenceDataBottomSheet extends StatefulWidget {
  const GeofenceDataBottomSheet({super.key});

  @override
  State<GeofenceDataBottomSheet> createState() => _GeofenceDataBottomSheetState();
}

class _GeofenceDataBottomSheetState extends State<GeofenceDataBottomSheet> {
  final LocationStorageService _storageService = LocationStorageService();
  List<GeofenceData> _geofenceData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGeofenceData();
  }

  Future<void> _loadGeofenceData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _storageService.getAllGeofenceData();
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
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Geofence Locations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadGeofenceData,
                    tooltip: 'Refresh geofence data',
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(child: _buildContent(scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
          ],
        ),
      );
    }

    if (_geofenceData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No geofence locations available'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Latitude:'),
                Text(geofence.latitude.toStringAsFixed(6)),
              ],
            ),
            const SizedBox(height: 4.0),
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