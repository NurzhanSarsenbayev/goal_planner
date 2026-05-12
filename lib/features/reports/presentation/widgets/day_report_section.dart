import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../../../shared/planner_dates.dart';
import '../../../tasks/presentation/widgets/task_card.dart';

class DayReportSection extends StatelessWidget {
  const DayReportSection({
    super.key,
    required this.date,
    required this.tasks,
    required this.goals,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final DateTime date;
  final List<PlannerTask> tasks;
  final List<Goal> goals;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_localizedDateTitle(l10n)} · ${l10n.reportsCompletedCount(tasks.length)}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        for (final task in tasks) ...[
          TaskCard(
            task: task,
            goal: _findGoalById(task.goalId),
            onToggleCompleted: () {
              onToggleTaskCompleted(task.id);
            },
            onEdit: () {
              onEditTask(task);
            },
            onDelete: () {
              onDeleteTask(task.id);
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _localizedDateTitle(AppLocalizations l10n) {
    final normalizedDate = dateOnly(date);
    final today = todayDate();
    final yesterday = today.subtract(const Duration(days: 1));

    if (normalizedDate == today) {
      return l10n.reportPeriodToday;
    }

    if (normalizedDate == yesterday) {
      return l10n.reportsDateYesterday;
    }

    return formatPlannerDate(normalizedDate);
  }

  Goal? _findGoalById(String? goalId) {
    if (goalId == null) {
      return null;
    }

    for (final goal in goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }
}
