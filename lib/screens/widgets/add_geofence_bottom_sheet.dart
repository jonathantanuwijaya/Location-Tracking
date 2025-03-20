import 'package:flutter/material.dart';
import 'package:tracking_practice/models/geofence_data.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';

class AddGeofence extends StatelessWidget {
  const AddGeofence({
    super.key,
    required this.provider,
    required this.latitudeController,
    required this.longitudeController,
    required this.nameController,
  });
  final ClockInOutProvider provider;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Geofence',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: latitudeController,
            decoration: const InputDecoration(
              labelText: 'Latitude',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: longitudeController,
            decoration: const InputDecoration(
              labelText: 'Longitude',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              if (latitudeController.text.isEmpty ||
                  longitudeController.text.isEmpty ||
                  nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }

              try {
                final latitude = double.parse(latitudeController.text);
                final longitude = double.parse(longitudeController.text);
                final name = nameController.text;

                // Create GeofenceData and save
                final geofenceData = GeofenceData(
                  latitude: latitude,
                  longitude: longitude,
                  name: name,
                );

                provider.saveGeofenceData(geofenceData);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid latitude or longitude format'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Save'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
