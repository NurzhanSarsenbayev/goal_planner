abstract class ReminderNotificationClient {
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  });

  Future<void> cancelReminder(int id);
}
