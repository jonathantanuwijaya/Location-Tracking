import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';
import 'package:tracking_practice/core/constants/widget_key.dart';
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

        final isClockedIn = clockInOutProvider.isClockedIn;
        final statusColor =
            isClockedIn ? Colors.green.shade600 : Colors.red.shade600;

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isClockedIn ? Icons.timer_rounded : Icons.timer_off_rounded,
                  size: 90,
                  color: statusColor,
                ),
                gapH20,
                Text(
                  isClockedIn
                      ? 'Currently Clocked In'
                      : 'Currently Clocked Out',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                gapH40,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          key: WidgetKey.clockInButton,
                          onPressed:
                              isClockedIn
                                  ? null
                                  : () => clockInOutProvider.clockIn(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.p16,
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green.shade600,
                            elevation: 3,
                            shadowColor: Colors.green.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Sizes.p16),
                            ),
                          ),
                          icon: const Icon(Icons.login_rounded),
                          label: const Text(
                            'Clock In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      gapW12,
                      Expanded(
                        child: ElevatedButton.icon(
                          key: WidgetKey.clockOutButton,
                          onPressed:
                              isClockedIn ? clockInOutProvider.clockOut : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.p16,
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red.shade600,
                            elevation: 3,
                            shadowColor: Colors.red.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Sizes.p16),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            'Clock Out',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                gapH24,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
                  child: ElevatedButton(
                    onPressed:
                        () => _showAddGeofenceBottomSheet(
                          context,
                          clockInOutProvider,
                        ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: Sizes.p16),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Sizes.p16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_location_rounded,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        gapW12,
                        const Text(
                          'Add Geofence Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.p24)),
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
