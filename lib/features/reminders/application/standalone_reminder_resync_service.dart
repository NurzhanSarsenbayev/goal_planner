import '../domain/standalone_reminder.dart';
import 'standalone_reminder_repository.dart';
import 'standalone_reminder_scheduler.dart';

class StandaloneReminderResyncService {
  const StandaloneReminderResyncService({
    required StandaloneReminderRepository repository,
    required StandaloneReminderScheduler scheduler,
  }) : _repository = repository,
       _scheduler = scheduler;

  final StandaloneReminderRepository _repository;
  final StandaloneReminderScheduler _scheduler;

  Future<List<StandaloneReminder>> loadStandaloneReminders() {
    return _repository.loadStandaloneReminders();
  }

  Future<void> syncStandaloneReminders() async {
    final reminders = await _repository.loadStandaloneReminders();

    for (final reminder in reminders) {
      await _scheduler.syncStandaloneReminder(reminder);
    }
  }

  Future<void> syncAfterStandaloneReminderSetReplacement({
    required Iterable<StandaloneReminder> previousReminders,
    required Iterable<StandaloneReminder> currentReminders,
  }) async {
    final currentReminderIds = currentReminders
        .map((reminder) => reminder.id)
        .toSet();

    for (final previousReminder in previousReminders) {
      if (!currentReminderIds.contains(previousReminder.id)) {
        await _scheduler.cancelStandaloneReminder(previousReminder.id);
      }
    }

    for (final currentReminder in currentReminders) {
      await _scheduler.syncStandaloneReminder(currentReminder);
    }
  }
}
