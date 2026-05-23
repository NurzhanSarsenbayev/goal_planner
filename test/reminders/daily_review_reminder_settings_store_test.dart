import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/application/daily_review_reminder_settings_repository.dart';
import 'package:goal_planner/features/reminders/application/daily_review_reminder_settings_store.dart';
import 'package:goal_planner/features/reminders/domain/daily_review_reminder_settings.dart';

void main() {
  group('DailyReviewReminderSettingsStore', () {
    test('initializes settings from repository', () async {
      final repository = _FakeDailyReviewReminderSettingsRepository(
        DailyReviewReminderSettings(isEnabled: false, timeMinutes: 20 * 60),
      );
      final store = _store(repository: repository);

      await store.initialize();

      expect(store.isInitialized, isTrue);
      expect(store.isLoading, isFalse);
      expect(store.settings.isEnabled, isFalse);
      expect(store.settings.timeMinutes, 1200);
      expect(repository.loadCount, 1);
    });

    test('does not initialize twice', () async {
      final repository = _FakeDailyReviewReminderSettingsRepository(
        const DailyReviewReminderSettings.defaults(),
      );
      final store = _store(repository: repository);

      await store.initialize();
      await store.initialize();

      expect(repository.loadCount, 1);
    });

    test('updates enabled setting and syncs reminder', () async {
      final repository = _FakeDailyReviewReminderSettingsRepository(
        const DailyReviewReminderSettings.defaults(),
      );
      var syncCount = 0;
      final store = _store(
        repository: repository,
        syncDailyReviewReminder: () async {
          syncCount++;
        },
      );

      await store.initialize();
      await store.setEnabled(false);

      expect(store.settings.isEnabled, isFalse);
      expect(repository.savedSettings.single.isEnabled, isFalse);
      expect(syncCount, 1);
    });

    test('updates time setting and syncs reminder', () async {
      final repository = _FakeDailyReviewReminderSettingsRepository(
        const DailyReviewReminderSettings.defaults(),
      );
      var syncCount = 0;
      final store = _store(
        repository: repository,
        syncDailyReviewReminder: () async {
          syncCount++;
        },
      );

      await store.initialize();
      await store.setTimeMinutes(22 * 60 + 30);

      expect(store.settings.timeMinutes, 1350);
      expect(repository.savedSettings.single.timeMinutes, 1350);
      expect(syncCount, 1);
    });

    test('ignores unchanged settings', () async {
      final repository = _FakeDailyReviewReminderSettingsRepository(
        const DailyReviewReminderSettings.defaults(),
      );
      var syncCount = 0;
      final store = _store(
        repository: repository,
        syncDailyReviewReminder: () async {
          syncCount++;
        },
      );

      await store.initialize();
      await store.setEnabled(true);
      await store.setTimeMinutes(21 * 60);

      expect(repository.savedSettings, isEmpty);
      expect(syncCount, 0);
    });
  });
}

DailyReviewReminderSettingsStore _store({
  required _FakeDailyReviewReminderSettingsRepository repository,
  Future<void> Function()? syncDailyReviewReminder,
}) {
  return DailyReviewReminderSettingsStore(
    settingsRepository: repository,
    syncDailyReviewReminder: syncDailyReviewReminder ?? () async {},
  );
}

class _FakeDailyReviewReminderSettingsRepository
    implements DailyReviewReminderSettingsRepository {
  _FakeDailyReviewReminderSettingsRepository(this.settings);

  DailyReviewReminderSettings settings;
  final savedSettings = <DailyReviewReminderSettings>[];
  int loadCount = 0;

  @override
  Future<DailyReviewReminderSettings> loadSettings() async {
    loadCount++;

    return settings;
  }

  @override
  Future<void> saveSettings(DailyReviewReminderSettings settings) async {
    this.settings = settings;
    savedSettings.add(settings);
  }
}
