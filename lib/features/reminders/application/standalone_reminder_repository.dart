import '../domain/standalone_reminder.dart';

abstract class StandaloneReminderRepository {
  Future<List<StandaloneReminder>> loadStandaloneReminders();

  Future<void> saveStandaloneReminder(StandaloneReminder reminder);

  Future<void> updateStandaloneReminder(StandaloneReminder reminder);

  Future<void> deleteStandaloneReminder(String reminderId);
}
