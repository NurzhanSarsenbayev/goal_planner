import 'package:flutter/material.dart';

import '../../../models/planner_task.dart';
import 'task_date_dialogs.dart';

class TaskScheduleDialogActions {
  const TaskScheduleDialogActions();

  Future<void> showScheduleDatePicker(
    BuildContext context, {
    required PlannerTask task,
    required void Function({
      required String taskId,
      required DateTime scheduledDate,
    })
    onScheduleTaskForDate,
  }) async {
    final selectedDate = await showScheduleTaskDatePicker(
      context,
      initialDate: task.scheduledDate,
    );

    if (selectedDate == null) {
      return;
    }

    onScheduleTaskForDate(taskId: task.id, scheduledDate: selectedDate);
  }

  Future<void> showScheduleTimePicker(
    BuildContext context, {
    required PlannerTask task,
    required void Function({
      required String taskId,
      required DateTime scheduledDate,
      required int? scheduledTimeMinutes,
    })
    onScheduleTaskForDateAndTime,
  }) async {
    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null) {
      return;
    }

    final selectedTime = await showScheduleTaskTimePicker(
      context,
      initialTimeMinutes: task.scheduledTimeMinutes,
    );

    if (selectedTime == null) {
      return;
    }

    onScheduleTaskForDateAndTime(
      taskId: task.id,
      scheduledDate: scheduledDate,
      scheduledTimeMinutes: selectedTime,
    );
  }

  void clearScheduledTime(
    PlannerTask task, {
    required void Function({
      required String taskId,
      required DateTime scheduledDate,
      required int? scheduledTimeMinutes,
    })
    onScheduleTaskForDateAndTime,
  }) {
    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null) {
      return;
    }

    onScheduleTaskForDateAndTime(
      taskId: task.id,
      scheduledDate: scheduledDate,
      scheduledTimeMinutes: null,
    );
  }

  Future<void> showReminderPicker(
    BuildContext context, {
    required PlannerTask task,
    required void Function({
      required String taskId,
      required int? reminderMinutesBefore,
    })
    onUpdateTaskReminder,
  }) async {
    final result = await showTaskReminderPicker(
      context,
      initialReminderMinutesBefore: task.reminderMinutesBefore,
    );

    if (result == null) {
      return;
    }

    onUpdateTaskReminder(
      taskId: task.id,
      reminderMinutesBefore: result.minutesBefore,
    );
  }

  static bool canEditScheduleTime(PlannerTask task) {
    return task.scheduledDate != null;
  }

  static bool canEditReminder(PlannerTask task) {
    return canEditScheduleTime(task) && task.scheduledTimeMinutes != null;
  }
}
