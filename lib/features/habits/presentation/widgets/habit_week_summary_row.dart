import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/habit_week_summary.dart';

class HabitWeekSummaryRow extends StatelessWidget {
  const HabitWeekSummaryRow({required this.summary, super.key});

  final HabitWeekSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final parts = <String>[
      l10n.habitWeekSummaryDone(summary.doneCount, summary.totalDays),
      if (summary.failedCount > 0)
        l10n.habitWeekSummaryMissed(summary.failedCount),
      if (summary.skippedCount > 0)
        l10n.habitWeekSummarySkipped(summary.skippedCount),
      if (summary.incompleteCount > 0)
        l10n.habitWeekSummaryPartial(summary.incompleteCount),
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
