import 'package:flutter/material.dart';

import '../../domain/habit_report_summary.dart';

class HabitReportSummaryCard extends StatelessWidget {
  const HabitReportSummaryCard({required this.summary, super.key});

  final HabitReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Habits', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _primaryValue(),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(_subtitle(), style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricPill(
                    value: _consistencyValue(),
                    label: 'consistency',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricPill(
                    value: _streakValue(),
                    label: 'habit streak',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MetricPill(
                    value: summary.missedCount.toString(),
                    label: 'missed',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricPill(
                    value: summary.skippedCount.toString(),
                    label: 'skipped',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _primaryValue() {
    if (summary.actionableExpectedMarkCount == 0) {
      return '${summary.doneCount} done';
    }

    return '${summary.doneCount}/${summary.actionableExpectedMarkCount} done';
  }

  String _subtitle() {
    if (summary.activeHabitCount == 0) {
      return 'History from archived habits.';
    }

    if (summary.markedCount == 0) {
      return '${summary.activeHabitCount} active habits, no marks yet.';
    }

    return '${summary.activeHabitCount} active habits tracked.';
  }

  String _consistencyValue() {
    if (summary.actionableExpectedMarkCount == 0) {
      return '—';
    }

    return '${summary.consistencyPercent}%';
  }

  String _streakValue() {
    final streakDays = summary.currentStreakDays;

    if (streakDays == 1) {
      return '1 day';
    }

    return '$streakDays days';
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
