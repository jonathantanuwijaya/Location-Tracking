import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/providers/main_tab_view/main_tab_view_provider.dart';
import 'package:tracking_practice/screens/clock_in_out_page.dart';
import 'package:tracking_practice/screens/location_time_summary_page.dart';
import 'package:tracking_practice/screens/widgets/geofence_data_bottom_sheet.dart';
import 'package:tracking_practice/screens/widgets/history_summary_bottom_sheet.dart';

/// Main page with bottom navigation bar
class MainPage extends StatefulWidget {
  /// Creates a new [MainPage] instance
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // List of pages to display in the bottom navigation bar
  final List<Widget> _pages = [
    const ClockInOutPage(),
    const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: LocationTimeSummaryPage(),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MainTabViewProvider>(
      builder: (context, provider, child) {
        final state = provider.state;
        final selectedIndex = state.selectedIndex;
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                    ),
                    builder: (context) => const GeofenceDataBottomSheet(),
                  );
                },
                tooltip: 'View Geofence Locations',
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                    ),
                    builder: (context) => const HistorySummaryBottomSheet(),
                  );
                },
                tooltip: 'View History',
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(
              selectedIndex == 0 ? 'Clock In/Out' : 'Location Summary',
            ),
          ),
          body: _pages[selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time),
                label: 'Clock In/Out',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: 'Location Summary',
              ),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: (index) => provider.changeTab(index),
          ),
        );
      },
    );
  }
}
