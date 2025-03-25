import 'package:flutter/material.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/screens/widgets/base/base_bottom_sheet.dart';
import 'package:tracking_practice/screens/widgets/base/base_form_field.dart';

class AddGeofence extends StatelessWidget {
  const AddGeofence({
    required this.provider,
    required this.latitudeController,
    required this.longitudeController,
    required this.nameController,
    super.key,
  });
  final ClockInOutProvider provider;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController nameController;

  Future<void> _handleSave(BuildContext context) async {
    final (success, error) = await provider.validateAndSaveGeofenceData(
      latitudeController.text,
      longitudeController.text,
      nameController.text,
    );

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to save geofence data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: 'Add Geofence',
      content: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BaseFormField(
              controller: latitudeController,
              labelText: 'Latitude',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            gapH12,
            BaseFormField(
              controller: longitudeController,
              labelText: 'Longitude',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            gapH12,
            BaseFormField(controller: nameController, labelText: 'Name'),
            gapH20,
            ElevatedButton(
              onPressed: () => _handleSave(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Save'),
            ),
            gapH16,
          ],
        ),
      ),
    );
  }
}
