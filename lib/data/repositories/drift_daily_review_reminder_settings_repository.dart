import 'package:drift/drift.dart' as drift;

import '../../features/reminders/daily_review/application/daily_review_reminder_settings_repository.dart';
import '../../features/reminders/daily_review/domain/daily_review_reminder_settings.dart'
    as domain;
import '../local/app_database.dart' as local;

class DriftDailyReviewReminderSettingsRepository
    implements DailyReviewReminderSettingsRepository {
  const DriftDailyReviewReminderSettingsRepository(this._database);

  static const _settingsId = 'default';

  final local.AppDatabase _database;

  @override
  Future<domain.DailyReviewReminderSettings> loadSettings() async {
    final row = await (_database.select(
      _database.dailyReviewReminderSettingsTable,
    )..where((table) => table.id.equals(_settingsId))).getSingleOrNull();

    if (row == null) {
      return const domain.DailyReviewReminderSettings.defaults();
    }

    return domain.DailyReviewReminderSettings(
      isEnabled: row.isEnabled,
      timeMinutes: row.timeMinutes,
    );
  }

  @override
  Future<void> saveSettings(domain.DailyReviewReminderSettings settings) async {
    await _database
        .into(_database.dailyReviewReminderSettingsTable)
        .insertOnConflictUpdate(
          local.DailyReviewReminderSettingsTableCompanion.insert(
            id: _settingsId,
            isEnabled: drift.Value(settings.isEnabled),
            timeMinutes: drift.Value(settings.timeMinutes),
          ),
        );
  }
}
