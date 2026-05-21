import '../domain/standalone_reminder.dart';
import 'standalone_reminder_repository.dart';
import 'standalone_reminder_scheduler.dart';

class StandaloneReminderApplicationService {
  const StandaloneReminderApplicationService({
    required StandaloneReminderRepository repository,
    required StandaloneReminderScheduler scheduler,
    DateTime Function()? now,
  }) : _repository = repository,
       _scheduler = scheduler,
       _now = now ?? DateTime.now;

  final StandaloneReminderRepository _repository;
  final StandaloneReminderScheduler _scheduler;
  final DateTime Function() _now;

  Future<List<StandaloneReminder>> loadStandaloneReminders() {
    return _repository.loadStandaloneReminders();
  }

  Future<StandaloneReminder?> createStandaloneReminder({
    required String title,
    required int timeMinutes,
  }) async {
    final normalizedTitle = title.trim();

    if (normalizedTitle.isEmpty) {
      return null;
    }

    final timestamp = _now();
    final reminder = StandaloneReminder(
      id: 'standalone_reminder_${timestamp.microsecondsSinceEpoch}',
      title: normalizedTitle,
      timeMinutes: timeMinutes,
      isEnabled: true,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await _repository.saveStandaloneReminder(reminder);
    await _scheduler.syncStandaloneReminder(reminder);

    return reminder;
  }

  Future<StandaloneReminder> updateStandaloneReminder({
    required StandaloneReminder reminder,
    required String title,
    required int timeMinutes,
  }) async {
    final updated = reminder.copyWith(
      title: title.trim(),
      timeMinutes: timeMinutes,
      updatedAt: _now(),
    );

    await _repository.updateStandaloneReminder(updated);
    await _scheduler.syncStandaloneReminder(updated);

    return updated;
  }

  Future<StandaloneReminder> setStandaloneReminderEnabled({
    required StandaloneReminder reminder,
    required bool isEnabled,
  }) async {
    final updated = reminder.copyWith(isEnabled: isEnabled, updatedAt: _now());

    await _repository.updateStandaloneReminder(updated);
    await _scheduler.syncStandaloneReminder(updated);

    return updated;
  }

  Future<void> deleteStandaloneReminder(String reminderId) async {
    await _repository.deleteStandaloneReminder(reminderId);
    await _scheduler.cancelStandaloneReminder(reminderId);
  }
}
