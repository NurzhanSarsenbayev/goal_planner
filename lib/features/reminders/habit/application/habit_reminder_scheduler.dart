import '../../../habits/domain/habit.dart';
import '../../common/application/reminder_notification_client.dart';
import '../../common/application/reminder_notification_texts.dart';
import 'habit_reminder_pending_checker.dart';

class HabitReminderScheduler {
  HabitReminderScheduler({
    required HabitReminderPendingChecker pendingChecker,
    required ReminderNotificationClient notifications,
    DateTime Function()? now,
    ReminderNotificationTexts? notificationTexts,
  }) : _pendingChecker = pendingChecker,
       _notifications = notifications,
       _now = now ?? DateTime.now,
       _notificationTexts = notificationTexts ?? ReminderNotificationTexts();

  final HabitReminderPendingChecker _pendingChecker;
  final ReminderNotificationClient _notifications;
  final DateTime Function() _now;
  final ReminderNotificationTexts _notificationTexts;

  Future<void> syncHabitReminder(Habit habit) async {
    final notificationId = habitReminderNotificationId(habit.id);

    await _notifications.cancelReminder(notificationId);

    if (!habit.isReminderEnabled || habit.reminderTimeMinutes == null) {
      return;
    }

    final shouldNotify = await _pendingChecker.shouldNotifyHabitToday(habit);

    if (!shouldNotify) {
      return;
    }

    final scheduledAt = _todayReminderDateTime(habit.reminderTimeMinutes!);

    if (!scheduledAt.isAfter(_now())) {
      return;
    }

    await _notifications.scheduleReminder(
      id: notificationId,
      title: habit.title,
      body: _notificationTexts.habitReminderBody,
      scheduledAt: scheduledAt,
      payload: habit.id,
    );
  }

  Future<void> cancelHabitReminder(String habitId) {
    return _notifications.cancelReminder(habitReminderNotificationId(habitId));
  }

  DateTime _todayReminderDateTime(int timeMinutes) {
    final currentTime = _now();

    return DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    ).add(Duration(minutes: timeMinutes));
  }
}

int habitReminderNotificationId(String habitId) {
  return _stablePositiveHash('habit_reminder_$habitId');
}

int _stablePositiveHash(String value) {
  var hash = 0x811c9dc5;

  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }

  return hash;
}
