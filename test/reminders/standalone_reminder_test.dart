import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/domain/standalone_reminder.dart';

void main() {
  group('StandaloneReminder', () {
    test('stores standalone reminder data', () {
      final createdAt = DateTime(2026, 5, 21, 9);
      final updatedAt = DateTime(2026, 5, 21, 10);

      final reminder = StandaloneReminder(
        id: 'reminder_1',
        title: 'Plan your day',
        timeMinutes: 9 * 60,
        isEnabled: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(reminder.id, 'reminder_1');
      expect(reminder.title, 'Plan your day');
      expect(reminder.timeMinutes, 540);
      expect(reminder.isEnabled, isTrue);
      expect(reminder.createdAt, createdAt);
      expect(reminder.updatedAt, updatedAt);
    });

    test('copies reminder with changed fields', () {
      final createdAt = DateTime(2026, 5, 21, 9);
      final updatedAt = DateTime(2026, 5, 21, 10);
      final nextUpdatedAt = DateTime(2026, 5, 21, 11);

      final reminder = StandaloneReminder(
        id: 'reminder_1',
        title: 'Plan your day',
        timeMinutes: 9 * 60,
        isEnabled: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final changed = reminder.copyWith(
        title: 'Review today',
        timeMinutes: 21 * 60 + 30,
        isEnabled: false,
        updatedAt: nextUpdatedAt,
      );

      expect(changed.id, 'reminder_1');
      expect(changed.title, 'Review today');
      expect(changed.timeMinutes, 1290);
      expect(changed.isEnabled, isFalse);
      expect(changed.createdAt, createdAt);
      expect(changed.updatedAt, nextUpdatedAt);
    });

    test('allows midnight and end of day time values', () {
      final now = DateTime(2026, 5, 21);

      expect(
        () => StandaloneReminder(
          id: 'midnight',
          title: 'Midnight reminder',
          timeMinutes: 0,
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        returnsNormally,
      );

      expect(
        () => StandaloneReminder(
          id: 'end_of_day',
          title: 'End of day reminder',
          timeMinutes: 1439,
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        returnsNormally,
      );
    });

    test('rejects invalid time values', () {
      final now = DateTime(2026, 5, 21);

      expect(
        () => StandaloneReminder(
          id: 'negative',
          title: 'Invalid reminder',
          timeMinutes: -1,
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        throwsAssertionError,
      );

      expect(
        () => StandaloneReminder(
          id: 'too_late',
          title: 'Invalid reminder',
          timeMinutes: 1440,
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        throwsAssertionError,
      );
    });
  });
}
