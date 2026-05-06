import 'package:flutter/material.dart';

import '../../domain/habit_report_summary.dart';

class HabitReportSection extends StatelessWidget {
  const HabitReportSection({required this.summary, super.key});

  final HabitReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final groups = [
      for (final group in summary.habitGroups)
        if (_shouldShowGroup(group)) group,
    ];

    if (groups.isEmpty) {
      return Text(
        'No habit marks in this period.',
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
    return Card(
      child: ListTile(
        title: Text(
          group.habit.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_subtitle()),
        trailing: group.actionableExpectedMarkCount == 0
            ? null
            : Text(
                '${group.consistencyPercent}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[
      _doneText(),
      if (group.missedCount > 0) '${group.missedCount} missed',
      if (group.skippedCount > 0) '${group.skippedCount} skipped',
      if (group.partialCount > 0) '${group.partialCount} partial',
    ];

    return parts.join(' · ');
  }

  String _doneText() {
    if (group.actionableExpectedMarkCount == 0) {
      return '${group.doneCount} done';
    }

    return '${group.doneCount}/${group.actionableExpectedMarkCount} done';
  }
}
