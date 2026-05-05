import 'package:flutter/material.dart';

import '../../application/habit_week_summary.dart';

class HabitWeekSummaryRow extends StatelessWidget {
  const HabitWeekSummaryRow({required this.summary, super.key});

  final HabitWeekSummary summary;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      '${summary.doneCount}/${summary.totalDays} done',
      if (summary.failedCount > 0) '${summary.failedCount} missed',
      if (summary.skippedCount > 0) '${summary.skippedCount} skipped',
      if (summary.incompleteCount > 0) '${summary.incompleteCount} partial',
    ];

    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
