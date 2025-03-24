import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';
import 'package:tracking_practice/core/util/datetime_extension.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/screens/widgets/base/base_bottom_sheet.dart';
import 'package:tracking_practice/screens/widgets/base/base_empty_state.dart';
import 'package:tracking_practice/screens/widgets/base/base_error_state.dart';

class HistorySummaryBottomSheet extends StatelessWidget {
  const HistorySummaryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryTimeSummaryProvider>(
      builder: (context, provider, child) {
        return BaseBottomSheet(
          title: 'Location History',
          onRefresh: () => provider.refreshSummaries(),
          content: _buildContent(provider),
        );
      },
    );
  }

  Widget _buildContent(HistoryTimeSummaryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return BaseErrorState(error: provider.error!);
    }

    if (provider.summaries.isEmpty) {
      return const BaseEmptyState(
        message: 'No history available',
        icon: Icons.history,
      );
    }

    return ListView.builder(
      itemCount: provider.summaries.length,
      itemBuilder: (context, index) {
        final summary = provider.summaries[index];
        return _buildSummaryCard(context, summary);
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, LocationTimeSummary summary) {
    final formattedDurations = summary.getFormattedDurations();

    return Card(
      margin: const EdgeInsets.only(bottom: Sizes.p16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.date.formalDate,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            gapH8,
            const Divider(),
            ...formattedDurations.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(entry.value),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
