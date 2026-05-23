import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/daily_review/domain/daily_review_reminder_settings.dart';

void main() {
  group('DailyReviewReminderSettings', () {
    test('uses enabled 21:00 defaults', () {
      const settings = DailyReviewReminderSettings.defaults();

      expect(settings.isEnabled, isTrue);
      expect(settings.timeMinutes, 21 * 60);
      expect(defaultDailyReviewReminderTimeMinutes, 21 * 60);
    });

    test('stores settings data', () {
      final settings = DailyReviewReminderSettings(
        isEnabled: false,
        timeMinutes: 22 * 60 + 30,
      );

      expect(settings.isEnabled, isFalse);
      expect(settings.timeMinutes, 1350);
    });

    test('copies settings with changed fields', () {
      const settings = DailyReviewReminderSettings.defaults();

      final changed = settings.copyWith(isEnabled: false, timeMinutes: 20 * 60);

      expect(changed.isEnabled, isFalse);
      expect(changed.timeMinutes, 1200);
    });

    test('allows midnight and end of day time values', () {
      expect(
        () => DailyReviewReminderSettings(isEnabled: true, timeMinutes: 0),
        returnsNormally,
      );

      expect(
        () => DailyReviewReminderSettings(isEnabled: true, timeMinutes: 1439),
        returnsNormally,
      );
    });

    test('rejects invalid time values', () {
      expect(
        () => DailyReviewReminderSettings(isEnabled: true, timeMinutes: -1),
        throwsAssertionError,
      );

      expect(
        () => DailyReviewReminderSettings(isEnabled: true, timeMinutes: 1440),
        throwsAssertionError,
      );
    });
  });
}
