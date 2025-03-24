import 'package:flutter/material.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/screens/widgets/base/base_bottom_sheet.dart';
import 'package:tracking_practice/screens/widgets/base/base_empty_state.dart';
import 'package:tracking_practice/screens/widgets/base/base_error_state.dart';
import 'package:tracking_practice/services/app_services/location_storage_service.dart';

class GeofenceDataBottomSheet extends StatefulWidget {
  const GeofenceDataBottomSheet({super.key});

  @override
  State<GeofenceDataBottomSheet> createState() =>
      _GeofenceDataBottomSheetState();
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
    return BaseBottomSheet(
      title: 'Geofence Locations',
      onRefresh: _loadGeofenceData,
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return BaseErrorState(error: _error!);
    }

    if (_geofenceData.isEmpty) {
      return const BaseEmptyState(
        message: 'No geofence locations available',
        icon: Icons.location_off,
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
        padding: EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              geofence.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            gapH8,
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Latitude:'),
                Text(geofence.latitude.toStringAsFixed(6)),
              ],
            ),
            gapH4,
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
