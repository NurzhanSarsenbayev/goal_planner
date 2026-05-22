enum ReminderRepeat {
  none,
  daily,
}

abstract class ReminderNotificationClient {
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
    ReminderRepeat repeat = ReminderRepeat.none,
  });

  Future<void> cancelReminder(int id);
}
