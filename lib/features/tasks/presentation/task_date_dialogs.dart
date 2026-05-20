import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/planner_task.dart';
import '../../../shared/planner_dates.dart';
import '../../../shared/planner_time.dart';

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

Future<int?> showScheduleTaskTimePicker(
  BuildContext context, {
  required int? initialTimeMinutes,
}) async {
  final initialTime = initialTimeMinutes == null
      ? TimeOfDay.now()
      : TimeOfDay(
          hour: initialTimeMinutes ~/ 60,
          minute: initialTimeMinutes % 60,
        );

  final pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  if (pickedTime == null) {
    return null;
  }

  return plannerTimeMinutes(hour: pickedTime.hour, minute: pickedTime.minute);
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
      final l10n = AppLocalizations.of(context);
      final scheduledDateText = formatPlannerDate(scheduledDate);

      return SimpleDialog(
        title: Text(l10n.taskCompletionPastTitle),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(todayDate());
            },
            child: Text(l10n.taskCompletionTodayOption),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(
                context,
              ).pop(todayDate().subtract(const Duration(days: 1)));
            },
            child: Text(l10n.taskCompletionYesterdayOption),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(scheduledDate);
            },
            child: Text(
              l10n.taskCompletionScheduledDateOption(scheduledDateText),
            ),
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
      final l10n = AppLocalizations.of(context);
      final scheduledDateText = formatPlannerDate(scheduledDate);

      return AlertDialog(
        title: Text(l10n.taskCompletionFutureTitle),
        content: Text(l10n.taskCompletionFutureMessage(scheduledDateText)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(l10n.taskCompletionCompleteTodayButton),
          ),
        ],
      );
    },
  );
}
