import 'package:flutter/material.dart';

import '../../application/today_task_view_builder.dart';

class TodaySummaryCard extends StatelessWidget {
  const TodaySummaryCard({required this.view, super.key});

  final TodayTaskView view;

  @override
  Widget build(BuildContext context) {
    final overdueCount = view.overdueTasks.length;
    final todoCount = view.pendingTodayTasks.length;
    final doneCount = view.doneTodayTasks.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              _summaryText(
                overdueCount: overdueCount,
                todoCount: todoCount,
                doneCount: doneCount,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'To do',
                    value: todoCount.toString(),
                    icon: Icons.radio_button_unchecked,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Overdue',
                    value: overdueCount.toString(),
                    icon: Icons.warning_amber_outlined,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Done',
                    value: doneCount.toString(),
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _summaryText({
    required int overdueCount,
    required int todoCount,
    required int doneCount,
  }) {
    if (overdueCount == 0 && todoCount == 0 && doneCount == 0) {
      return 'Nothing planned yet. Add one small task to start the day.';
    }

    if (todoCount == 0 && overdueCount == 0) {
      return 'All planned tasks are done for today.';
    }

    if (overdueCount > 0) {
      return 'Handle overdue tasks first, then continue with today.';
    }

    return 'Focus on today’s planned tasks.';
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
