import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';
import 'package:tracking_practice/core/util/datetime_extension.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';

/// Widget that displays the location time summary data
class LocationTimeSummaryPage extends StatelessWidget {
  const LocationTimeSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationTimeSummaryProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        final summary = provider.summary;
        if (summary == null) {
          return const Center(child: Text('No data available'));
        }

        final formattedDurations = summary.getFormattedDurations();

        return Padding(
          padding: EdgeInsets.all(Sizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary Page',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gapH32,
              Text(
                summary.date.formalDate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              gapH16,
              ...formattedDurations.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
