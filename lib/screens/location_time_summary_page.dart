import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';
import 'package:tracking_practice/core/util/datetime_extension.dart';
import 'package:tracking_practice/providers/location_time_summary/location_time_summary_provider.dart';

class LocationTimeSummaryPage extends StatelessWidget {
  const LocationTimeSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationTimeSummaryProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return _buildErrorView(context, provider.error!);
        }

        final summary = provider.summary;
        if (summary == null) {
          return _buildEmptyView(context);
        }

        final formattedDurations = summary.getFormattedDurations();

        return Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context, summary.date.formalDate),
              const Divider(height: 32),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children:
                      formattedDurations.entries
                          .map(
                            (entry) => _buildLocationItem(
                              context,
                              entry.key,
                              entry.value,
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Summary',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        gapH4,
        Text(
          date,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLocationItem(
    BuildContext context,
    String location,
    String duration,
  ) {
    final locationColor = Colors.teal.shade600;

    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.p16),
      child: Container(
        padding: const EdgeInsets.all(Sizes.p16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Sizes.p16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // 0.05 opacity = 13/255
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH4,
                  Text(
                    'Time spent',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.p12,
                vertical: Sizes.p8,
              ),
              decoration: BoxDecoration(
                color: locationColor.withAlpha(25), // 0.1 opacity = 25/255
                borderRadius: BorderRadius.circular(Sizes.p30),
              ),
              child: Text(
                duration,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: locationColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_off_rounded, size: 48, color: Colors.grey.shade500),
          gapH16,
          Text(
            'No Time Data Available',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          gapH8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p32),
            child: Text(
              'Clock in to start tracking your location time',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(Sizes.p20),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.shade700,
            ),
          ),
          gapH16,
          Text(
            'Error',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          gapH8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
