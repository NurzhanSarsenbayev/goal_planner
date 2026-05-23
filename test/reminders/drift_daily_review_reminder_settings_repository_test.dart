import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_daily_review_reminder_settings_repository.dart';
import 'package:goal_planner/features/reminders/domain/daily_review_reminder_settings.dart';

void main() {
  group('DriftDailyReviewReminderSettingsRepository', () {
    late local.AppDatabase database;
    late DriftDailyReviewReminderSettingsRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftDailyReviewReminderSettingsRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('returns default settings when row does not exist', () async {
      final settings = await repository.loadSettings();

      expect(settings.isEnabled, isTrue);
      expect(settings.timeMinutes, 21 * 60);
    });

    test('persists and loads settings', () async {
      final settings = DailyReviewReminderSettings(
        isEnabled: false,
        timeMinutes: 22 * 60 + 30,
      );

      await repository.saveSettings(settings);

      final loaded = await repository.loadSettings();

      expect(loaded.isEnabled, isFalse);
      expect(loaded.timeMinutes, 1350);
    });

    test('updates existing settings row', () async {
      await repository.saveSettings(
        DailyReviewReminderSettings(isEnabled: true, timeMinutes: 21 * 60),
      );

      await repository.saveSettings(
        DailyReviewReminderSettings(isEnabled: false, timeMinutes: 20 * 60),
      );

      final loaded = await repository.loadSettings();

      expect(loaded.isEnabled, isFalse);
      expect(loaded.timeMinutes, 1200);
    });
  });
}
