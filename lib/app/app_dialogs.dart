import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../models/recurring_task_rule.dart';
import '../shared/planner_dates.dart';
import '../features/recurring/presentation/widgets/add_recurring_task_rule_dialog.dart';

Future<DateTime?> showScheduleTaskDatePicker(
  BuildContext context, {
  required DateTime? initialDate,
}) {
  final today = todayDate();

  return showDatePicker(
    context: context,
    initialDate: initialDate ?? today,
    firstDate: DateTime(today.year - 1),
    lastDate: DateTime(today.year + 5),
  );
}

Future<AddRecurringTaskRuleDraft?> showAddRecurringTaskRuleDialog(
  BuildContext context, {
  required List<Goal> goals,
  required List<Milestone> milestones,
  DateTime? initialDate,
}) {
  return showDialog<AddRecurringTaskRuleDraft>(
    context: context,
    builder: (context) {
      return AddRecurringTaskRuleDialog(
        goals: goals,
        milestones: milestones,
        initialDate: initialDate,
      );
    },
  );
}

Future<AddRecurringTaskRuleDraft?> showEditRecurringTaskRuleDialog(
  BuildContext context, {
  required RecurringTaskRule rule,
  required List<Goal> goals,
  required List<Milestone> milestones,
}) {
  return showDialog<AddRecurringTaskRuleDraft>(
    context: context,
    builder: (context) {
      return AddRecurringTaskRuleDialog(
        goals: goals,
        milestones: milestones,
        initialRule: rule,
        dialogTitle: 'Edit recurring task',
        submitLabel: 'Save',
      );
    },
  );
}

Future<void> handleTaskCompletionWithDateFlow(
  BuildContext context, {
  required PlannerTask task,
  required void Function(String taskId) onToggleTaskCompleted,
  required void Function({
    required String taskId,
    required DateTime completedAt,
  })
  onCompleteTaskOnDate,
}) async {
  if (task.isCompleted) {
    onToggleTaskCompleted(task.id);
    return;
  }

  final scheduledDate = task.scheduledDate;
  final today = todayDate();

  if (scheduledDate == null || dateOnly(scheduledDate) == today) {
    onToggleTaskCompleted(task.id);
    return;
  }

  final normalizedScheduledDate = dateOnly(scheduledDate);

  if (normalizedScheduledDate.isBefore(today)) {
    final completedAt = await _showPastScheduledTaskCompletionDialog(
      context,
      scheduledDate: normalizedScheduledDate,
    );

    if (completedAt == null) {
      return;
    }

    onCompleteTaskOnDate(taskId: task.id, completedAt: completedAt);
    return;
  }

  final shouldCompleteToday = await _showFutureScheduledTaskCompletionDialog(
    context,
    scheduledDate: normalizedScheduledDate,
  );

  if (shouldCompleteToday != true) {
    return;
  }

  onCompleteTaskOnDate(taskId: task.id, completedAt: today);
}

Future<DateTime?> _showPastScheduledTaskCompletionDialog(
  BuildContext context, {
  required DateTime scheduledDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text('When was it completed?'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(todayDate());
            },
            child: const Text('Today'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(
                context,
              ).pop(todayDate().subtract(const Duration(days: 1)));
            },
            child: const Text('Yesterday'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(scheduledDate);
            },
            child: Text('Scheduled date: ${formatPlannerDate(scheduledDate)}'),
          ),
        ],
      );
    },
  );
}

Future<bool?> _showFutureScheduledTaskCompletionDialog(
  BuildContext context, {
  required DateTime scheduledDate,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Complete early?'),
        content: Text(
          'This task is scheduled for ${formatPlannerDate(scheduledDate)}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Complete today'),
          ),
        ],
      );
    },
  );
}
