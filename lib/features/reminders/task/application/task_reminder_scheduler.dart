import '../../../../models/planner_task.dart';
import '../../../../shared/planner_dates.dart';
import '../../common/application/reminder_notification_client.dart';
import '../../common/application/reminder_notification_texts.dart';

class TaskReminderScheduler {
  TaskReminderScheduler({
    required ReminderNotificationClient notifications,
    DateTime Function()? now,
    ReminderNotificationTexts? notificationTexts,
  }) : _notifications = notifications,
       _now = now ?? DateTime.now,
       _notificationTexts = notificationTexts ?? ReminderNotificationTexts();

  final ReminderNotificationClient _notifications;
  final DateTime Function() _now;
  final ReminderNotificationTexts _notificationTexts;

  Future<void> syncTaskReminder(PlannerTask task) async {
    final notificationId = taskReminderNotificationId(task.id);

    await _notifications.cancelReminder(notificationId);

    final reminderAt = _reminderDateTimeFor(task);

    if (reminderAt == null || !reminderAt.isAfter(_now())) {
      return;
    }

    await _notifications.scheduleReminder(
      id: notificationId,
      title: task.title,
      body: _notificationTexts.taskReminderBody,
      scheduledAt: reminderAt,
      payload: task.id,
    );
  }

  Future<void> cancelTaskReminder(String taskId) {
    return _notifications.cancelReminder(taskReminderNotificationId(taskId));
  }

  DateTime? _reminderDateTimeFor(PlannerTask task) {
    if (task.isCompleted) {
      return null;
    }

    final scheduledDate = task.scheduledDate;
    final scheduledTimeMinutes = task.scheduledTimeMinutes;
    final reminderMinutesBefore = task.reminderMinutesBefore;

    if (scheduledDate == null ||
        scheduledTimeMinutes == null ||
        reminderMinutesBefore == null) {
      return null;
    }

    final date = dateOnly(scheduledDate);
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(Duration(minutes: scheduledTimeMinutes));

    return scheduledAt.subtract(Duration(minutes: reminderMinutesBefore));
  }
}

int taskReminderNotificationId(String taskId) {
  return _stablePositiveHash('task_reminder_$taskId');
}

int _stablePositiveHash(String value) {
  var hash = 0x811c9dc5;

  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }

  return hash;
}
