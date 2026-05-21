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

class TaskReminderSelection {
  const TaskReminderSelection({required this.minutesBefore});

  final int? minutesBefore;
}

Future<TaskReminderSelection?> showTaskReminderPicker(
  BuildContext context, {
  required int? initialReminderMinutesBefore,
}) {
  return showDialog<TaskReminderSelection>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return SimpleDialog(
        title: Text(l10n.taskReminderFieldLabel),
        children: [
          _TaskReminderOption(
            label: l10n.taskReminderNoneOption,
            value: null,
            selectedValue: initialReminderMinutesBefore,
          ),
          _TaskReminderOption(
            label: l10n.taskReminderAtTimeOption,
            value: 0,
            selectedValue: initialReminderMinutesBefore,
          ),
          _TaskReminderOption(
            label: l10n.taskReminderMinutesBeforeOption(5),
            value: 5,
            selectedValue: initialReminderMinutesBefore,
          ),
          _TaskReminderOption(
            label: l10n.taskReminderMinutesBeforeOption(15),
            value: 15,
            selectedValue: initialReminderMinutesBefore,
          ),
          _TaskReminderOption(
            label: l10n.taskReminderMinutesBeforeOption(30),
            value: 30,
            selectedValue: initialReminderMinutesBefore,
          ),
          _TaskReminderOption(
            label: l10n.taskReminderHoursBeforeOption(1),
            value: 60,
            selectedValue: initialReminderMinutesBefore,
          ),
        ],
      );
    },
  );
}

class _TaskReminderOption extends StatelessWidget {
  const _TaskReminderOption({
    required this.label,
    required this.value,
    required this.selectedValue,
  });

  final String label;
  final int? value;
  final int? selectedValue;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop(TaskReminderSelection(minutesBefore: value));
      },
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (value == selectedValue) const Icon(Icons.check, size: 20),
        ],
      ),
    );
  }
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
