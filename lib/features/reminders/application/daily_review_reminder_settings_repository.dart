import '../domain/daily_review_reminder_settings.dart';

abstract interface class DailyReviewReminderSettingsRepository {
  Future<DailyReviewReminderSettings> loadSettings();

  Future<void> saveSettings(DailyReviewReminderSettings settings);
}
