import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';
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
        padding: EdgeInsets.all(Sizes.p16),
        child: LocationTimeSummaryPage(),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MainTabViewProvider>(
      builder: (context, provider, child) {
        final selectedIndex = provider.selectedIndex;
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.map_outlined),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Sizes.p24),
                      ),
                    ),
                    builder: (context) => const GeofenceDataBottomSheet(),
                  );
                },
                tooltip: 'View Geofence Locations',
              ),
              IconButton(
                icon: const Icon(Icons.history_outlined),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Sizes.p24),
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
              selectedIndex == 0 ? 'Clock In Out' : 'Location Summary',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: _pages[selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: Sizes.p4),
                  child: Icon(Icons.access_time_rounded),
                ),
                label: 'Clock In Out',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: Sizes.p4),
                  child: Icon(Icons.place_rounded),
                ),
                label: 'Location Summary',
              ),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey.shade600,
            backgroundColor: Colors.white,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            onTap: (index) => provider.changeTab(index),
          ),
        );
      },
    );
  }
}
