import '../domain/standalone_reminder.dart';
import '../../common/application/reminder_notification_client.dart';
import '../../common/application/reminder_notification_texts.dart';

class StandaloneReminderScheduler {
  StandaloneReminderScheduler({
    required ReminderNotificationClient notifications,
    DateTime Function()? now,
    ReminderNotificationTexts? notificationTexts,
  }) : _notifications = notifications,
       _now = now ?? DateTime.now,
       _notificationTexts = notificationTexts ?? ReminderNotificationTexts();

  final ReminderNotificationClient _notifications;
  final DateTime Function() _now;
  final ReminderNotificationTexts _notificationTexts;

  Future<void> syncStandaloneReminder(StandaloneReminder reminder) async {
    final notificationId = standaloneReminderNotificationId(reminder.id);

    await _notifications.cancelReminder(notificationId);

    if (!reminder.isEnabled || isStandaloneReminderExpired(reminder, _now())) {
      return;
    }

    await _notifications.scheduleReminder(
      id: notificationId,
      title: reminder.title,
      body: _notificationTexts.standaloneReminderBody,
      scheduledAt: _nextReminderDateTime(reminder),
      payload: reminder.id,
      repeat: reminder.scheduleType == StandaloneReminderScheduleType.daily
          ? ReminderRepeat.daily
          : ReminderRepeat.none,
    );
  }

  Future<void> cancelStandaloneReminder(String reminderId) {
    return _notifications.cancelReminder(
      standaloneReminderNotificationId(reminderId),
    );
  }

  DateTime _nextReminderDateTime(StandaloneReminder reminder) {
    switch (reminder.scheduleType) {
      case StandaloneReminderScheduleType.once:
        return _oneTimeReminderDateTime(reminder);
      case StandaloneReminderScheduleType.daily:
        return _nextDailyReminderDateTime(reminder.timeMinutes);
    }
  }

  DateTime _oneTimeReminderDateTime(StandaloneReminder reminder) {
    return standaloneReminderDateTime(reminder)!;
  }

  DateTime _nextDailyReminderDateTime(int timeMinutes) {
    final currentTime = _now();
    final todayAtReminderTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    ).add(Duration(minutes: timeMinutes));

    if (todayAtReminderTime.isAfter(currentTime)) {
      return todayAtReminderTime;
    }

    return todayAtReminderTime.add(const Duration(days: 1));
  }
}

int standaloneReminderNotificationId(String reminderId) {
  return _stablePositiveHash('standalone_reminder_$reminderId');
}

int _stablePositiveHash(String value) {
  var hash = 0x811c9dc5;

  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }

  return hash;
}
