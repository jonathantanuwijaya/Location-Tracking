import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';
import 'package:tracking_practice/providers/clock_in_out/clock_in_out_provider.dart';
import 'package:tracking_practice/screens/widgets/add_geofence_bottom_sheet.dart';

class ClockInOutPage extends StatefulWidget {
  const ClockInOutPage({super.key});

  @override
  State<ClockInOutPage> createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ClockInOutProvider>(
      context,
      listen: false,
    ).refreshServiceStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClockInOutProvider>(
      builder: (context, clockInOutProvider, child) {
        if (clockInOutProvider.error != null) {
          return Center(child: Text('Error: ${clockInOutProvider.error}'));
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  clockInOutProvider.isClockedIn
                      ? Icons.timer
                      : Icons.timer_off,
                  size: 100,
                  color:
                      clockInOutProvider.isClockedIn
                          ? Colors.green
                          : Colors.red,
                ),
                gapH20,
                Text(
                  clockInOutProvider.isClockedIn
                      ? 'Currently Clocked In'
                      : 'Currently Clocked Out',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                gapH40,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => clockInOutProvider.clockIn(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.p40,
                          vertical: Sizes.p16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.p30),
                        ),
                      ),
                      child: const Text('Clock In'),
                    ),
                    ElevatedButton(
                      onPressed: clockInOutProvider.clockOut,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.p40,
                          vertical: Sizes.p16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.p30),
                        ),
                      ),
                      child: const Text('Clock Out'),
                    ),
                  ],
                ),
                gapH20,
                ElevatedButton.icon(
                  onPressed:
                      () => _showAddGeofenceBottomSheet(
                        context,
                        clockInOutProvider,
                      ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p40,
                      vertical: Sizes.p16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.p30),
                    ),
                  ),
                  icon: const Icon(Icons.add_location),
                  label: const Text('Add Geofence'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddGeofenceBottomSheet(
    BuildContext context,
    ClockInOutProvider provider,
  ) {
    final latitudeController = TextEditingController();
    final longitudeController = TextEditingController();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.p20)),
      ),
      builder: (context) {
        return AddGeofence(
          provider: provider,
          latitudeController: latitudeController,
          longitudeController: longitudeController,
          nameController: nameController,
        );
      },
    );
  }
}
