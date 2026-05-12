import 'package:flutter/material.dart';

import '../../domain/habit_report_summary.dart';
import '../../../../l10n/app_localizations.dart';

class HabitReportSection extends StatelessWidget {
  const HabitReportSection({required this.summary, super.key});

  final HabitReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final groups = [
      for (final group in summary.habitGroups)
        if (_shouldShowGroup(group)) group,
    ];

    if (groups.isEmpty) {
      return Text(
        l10n.reportsNoHabitMarks,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        for (final group in groups) ...[
          _HabitReportTile(group: group),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  bool _shouldShowGroup(HabitReportGroup group) {
    return group.expectedMarkCount > 0 ||
        group.doneCount > 0 ||
        group.missedCount > 0 ||
        group.skippedCount > 0 ||
        group.partialCount > 0;
  }
}

class _HabitReportTile extends StatelessWidget {
  const _HabitReportTile({required this.group});

  final HabitReportGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        title: Text(
          group.habit.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_subtitle(l10n)),
        trailing: group.actionableExpectedMarkCount == 0
            ? null
            : Text(
                '${group.consistencyPercent}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
      ),
    );
  }

  String _subtitle(AppLocalizations l10n) {
    final parts = <String>[
      _doneText(l10n),
      if (group.missedCount > 0)
        l10n.reportsHabitMissedCount(group.missedCount),
      if (group.skippedCount > 0)
        l10n.reportsHabitSkippedCount(group.skippedCount),
      if (group.partialCount > 0)
        l10n.reportsHabitPartialCount(group.partialCount),
    ];

    return parts.join(' · ');
  }

  String _doneText(AppLocalizations l10n) {
    if (group.actionableExpectedMarkCount == 0) {
      return l10n.reportsHabitsDoneOnly(group.doneCount);
    }

    return l10n.reportsHabitsDoneProgress(
      group.doneCount,
      group.actionableExpectedMarkCount,
    );
  }
}
