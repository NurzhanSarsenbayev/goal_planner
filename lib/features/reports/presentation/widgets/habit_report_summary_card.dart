import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/habit_report_summary.dart';

class HabitReportSummaryCard extends StatelessWidget {
  const HabitReportSummaryCard({required this.summary, super.key});

  final HabitReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.habitsTab, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _primaryValue(l10n),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(_subtitle(l10n), style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricPill(
                    value: _consistencyValue(),
                    label: l10n.reportsConsistencyMetric,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricPill(
                    value: _streakValue(l10n),
                    label: l10n.reportsHabitStreakMetric,
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
                    label: l10n.reportsMissedMetric,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricPill(
                    value: summary.skippedCount.toString(),
                    label: l10n.reportsSkippedMetric,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _primaryValue(AppLocalizations l10n) {
    if (summary.actionableExpectedMarkCount == 0) {
      return l10n.reportsHabitsDoneOnly(summary.doneCount);
    }

    return l10n.reportsHabitsDoneProgress(
      summary.doneCount,
      summary.actionableExpectedMarkCount,
    );
  }

  String _subtitle(AppLocalizations l10n) {
    if (summary.activeHabitCount == 0) {
      return l10n.reportsArchivedHabitHistory;
    }

    if (summary.markedCount == 0) {
      return l10n.reportsActiveHabitsNoMarks(summary.activeHabitCount);
    }

    return l10n.reportsActiveHabitsTracked(summary.activeHabitCount);
  }

  String _consistencyValue() {
    if (summary.actionableExpectedMarkCount == 0) {
      return '—';
    }

    return '${summary.consistencyPercent}%';
  }

  String _streakValue(AppLocalizations l10n) {
    final streakDays = summary.currentStreakDays;

    if (streakDays == 1) {
      return l10n.reportsOneDay;
    }

    return l10n.reportsDays(streakDays);
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
