import 'package:flutter/material.dart';

import '../../../habits/application/habit_today_summary.dart';

class TodayHabitsSummaryCard extends StatelessWidget {
  const TodayHabitsSummaryCard({
    required this.summary,
    required this.onOpenHabits,
    super.key,
  });

  final HabitTodaySummary summary;
  final VoidCallback onOpenHabits;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasHabits) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onOpenHabits,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.track_changes_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Habits today',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${summary.doneCount}/${summary.totalHabitCount} done',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                _detailsText(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _detailsText() {
    final parts = <String>[
      if (summary.failedCount > 0) '${summary.failedCount} missed',
      if (summary.skippedCount > 0) '${summary.skippedCount} skipped',
      if (summary.incompleteCount > 0) '${summary.incompleteCount} partial',
      if (summary.unmarkedCount > 0) '${summary.unmarkedCount} not marked',
    ];

    if (parts.isEmpty) {
      return 'All habits are marked for today.';
    }

    return parts.join(' · ');
  }
}
