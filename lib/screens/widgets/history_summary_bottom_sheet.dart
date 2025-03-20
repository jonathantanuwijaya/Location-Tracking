import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_practice/core/util/datetime_extension.dart';
import 'package:tracking_practice/models/location_time_summary.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_provider.dart';
import 'package:tracking_practice/providers/history_time_summary/history_time_summary_state.dart';

class HistorySummaryBottomSheet extends StatelessWidget {
  const HistorySummaryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Consumer<HistoryTimeSummaryProvider>(
          builder: (context, provider, child) {
            final state = provider.state;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => provider.refreshSummaries(),
                        tooltip: 'Refresh history',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(child: _buildContent(state, scrollController)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    HistoryTimeSummaryState state,
    ScrollController scrollController,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
          ],
        ),
      );
    }

    if (state.summaries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No history available'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: state.summaries.length,
      itemBuilder: (context, index) {
        final summary = state.summaries[index];
        return _buildSummaryCard(context, summary);
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, LocationTimeSummary summary) {
    final formattedDurations = summary.getFormattedDurations();

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.date.formalDate,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            ...formattedDurations.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
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
