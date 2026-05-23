import 'package:drift/drift.dart' as drift;

import '../../features/reminders/standalone/application/standalone_reminder_repository.dart';
import '../../features/reminders/standalone/domain/standalone_reminder.dart' as domain;
import '../local/app_database.dart' as local;

class DriftStandaloneReminderRepository
    implements StandaloneReminderRepository {
  const DriftStandaloneReminderRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<List<domain.StandaloneReminder>> loadStandaloneReminders() async {
    final rows =
        await (_database.select(_database.standaloneReminders)..orderBy([
              (table) => drift.OrderingTerm.asc(table.timeMinutes),
              (table) => drift.OrderingTerm.asc(table.createdAt),
            ]))
            .get();

    return rows.map(_mapStandaloneReminder).toList();
  }

  @override
  Future<void> saveStandaloneReminder(
    domain.StandaloneReminder reminder,
  ) async {
    await _database
        .into(_database.standaloneReminders)
        .insertOnConflictUpdate(
          local.StandaloneRemindersCompanion.insert(
            id: reminder.id,
            title: reminder.title,
            scheduleType: drift.Value(
              _scheduleTypeToStorage(reminder.scheduleType),
            ),
            scheduledDate: drift.Value(reminder.scheduledDate),
            timeMinutes: reminder.timeMinutes,
            isEnabled: drift.Value(reminder.isEnabled),
            createdAt: reminder.createdAt,
            updatedAt: reminder.updatedAt,
          ),
        );
  }

  @override
  Future<void> updateStandaloneReminder(
    domain.StandaloneReminder reminder,
  ) async {
    await (_database.update(
      _database.standaloneReminders,
    )..where((table) => table.id.equals(reminder.id))).write(
      local.StandaloneRemindersCompanion(
        title: drift.Value(reminder.title),
        scheduleType: drift.Value(
          _scheduleTypeToStorage(reminder.scheduleType),
        ),
        scheduledDate: drift.Value(reminder.scheduledDate),
        timeMinutes: drift.Value(reminder.timeMinutes),
        isEnabled: drift.Value(reminder.isEnabled),
        createdAt: drift.Value(reminder.createdAt),
        updatedAt: drift.Value(reminder.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteStandaloneReminder(String reminderId) async {
    await (_database.delete(
      _database.standaloneReminders,
    )..where((table) => table.id.equals(reminderId))).go();
  }
}

domain.StandaloneReminder _mapStandaloneReminder(local.StandaloneReminder row) {
  return domain.StandaloneReminder(
    id: row.id,
    title: row.title,
    scheduleType: _scheduleTypeFromStorage(row.scheduleType),
    scheduledDate: row.scheduledDate,
    timeMinutes: row.timeMinutes,
    isEnabled: row.isEnabled,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

String _scheduleTypeToStorage(
  domain.StandaloneReminderScheduleType scheduleType,
) {
  switch (scheduleType) {
    case domain.StandaloneReminderScheduleType.once:
      return 'once';
    case domain.StandaloneReminderScheduleType.daily:
      return 'daily';
  }
}

domain.StandaloneReminderScheduleType _scheduleTypeFromStorage(String value) {
  switch (value) {
    case 'once':
      return domain.StandaloneReminderScheduleType.once;
    case 'daily':
      return domain.StandaloneReminderScheduleType.daily;
    default:
      return domain.StandaloneReminderScheduleType.daily;
  }
}
