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

    test('daily reminder is never expired', () {
      final now = DateTime(2026, 5, 21, 12);

      final reminder = StandaloneReminder(
        id: 'daily',
        title: 'Plan your day',
        scheduleType: StandaloneReminderScheduleType.daily,
        scheduledDate: null,
        timeMinutes: 9 * 60,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(isStandaloneReminderExpired(reminder, now), isFalse);
      expect(standaloneReminderDateTime(reminder), isNull);
    });

    test('detects expired one-time reminder', () {
      final now = DateTime(2026, 5, 21, 12);

      final reminder = StandaloneReminder(
        id: 'once',
        title: 'Call vet',
        scheduleType: StandaloneReminderScheduleType.once,
        scheduledDate: DateTime(2026, 5, 21),
        timeMinutes: 11 * 60,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(standaloneReminderDateTime(reminder), DateTime(2026, 5, 21, 11));
      expect(isStandaloneReminderExpired(reminder, now), isTrue);
    });

    test('keeps future one-time reminder active', () {
      final now = DateTime(2026, 5, 21, 12);

      final reminder = StandaloneReminder(
        id: 'once',
        title: 'Call vet',
        scheduleType: StandaloneReminderScheduleType.once,
        scheduledDate: DateTime(2026, 5, 21),
        timeMinutes: 13 * 60,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(standaloneReminderDateTime(reminder), DateTime(2026, 5, 21, 13));
      expect(isStandaloneReminderExpired(reminder, now), isFalse);
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

    test('stores one-time reminder date', () {
      final now = DateTime(2026, 5, 21, 8);
      final scheduledDate = DateTime(2026, 5, 22);

      final reminder = StandaloneReminder(
        id: 'once',
        title: 'Call vet',
        scheduleType: StandaloneReminderScheduleType.once,
        scheduledDate: scheduledDate,
        timeMinutes: 18 * 60 + 30,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(reminder.scheduleType, StandaloneReminderScheduleType.once);
      expect(reminder.scheduledDate, scheduledDate);
      expect(reminder.timeMinutes, 1110);
    });

    test('rejects one-time reminder without scheduled date', () {
      final now = DateTime(2026, 5, 21);

      expect(
        () => StandaloneReminder(
          id: 'invalid_once',
          title: 'Invalid',
          scheduleType: StandaloneReminderScheduleType.once,
          scheduledDate: null,
          timeMinutes: 9 * 60,
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        throwsAssertionError,
      );
    });
  });
}
