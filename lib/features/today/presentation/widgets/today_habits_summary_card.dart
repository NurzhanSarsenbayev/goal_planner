import 'package:flutter/material.dart';

import '../../../habits/application/habit_today_summary.dart';
import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

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
                      l10n.todayHabitsTitle,
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
                _primaryText(l10n),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                _detailsText(l10n),
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

  String _primaryText(AppLocalizations l10n) {
    if (summary.actionableHabitCount == 0) {
      return l10n.todayHabitsDoneOnly(summary.doneCount);
    }

    return l10n.todayHabitsDoneProgress(
      summary.doneCount,
      summary.actionableHabitCount,
    );
  }

  String _detailsText(AppLocalizations l10n) {
    final parts = <String>[
      if (summary.failedCount > 0)
        l10n.todayHabitsMissedCount(summary.failedCount),
      if (summary.skippedCount > 0)
        l10n.todayHabitsSkippedCount(summary.skippedCount),
      if (summary.incompleteCount > 0)
        l10n.todayHabitsPartialCount(summary.incompleteCount),
      if (summary.unmarkedCount > 0)
        l10n.todayHabitsNotMarkedCount(summary.unmarkedCount),
    ];

    if (parts.isEmpty) {
      return l10n.todayHabitsAllMarked;
    }

    return parts.join(' · ');
  }
}
