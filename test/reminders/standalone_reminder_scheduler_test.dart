import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_client.dart';
import 'package:goal_planner/features/reminders/standalone/application/standalone_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/standalone/domain/standalone_reminder.dart';

void main() {
  group('StandaloneReminderScheduler', () {
    test('schedules enabled reminder later today', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = StandaloneReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 21, 8),
      );

      await scheduler.syncStandaloneReminder(
        _reminder(timeMinutes: 9 * 60, isEnabled: true),
      );

      expect(notifications.canceledIds, [
        standaloneReminderNotificationId('reminder_1'),
      ]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 21, 9),
      );
      expect(notifications.scheduledReminders.single.title, 'Plan your day');
      expect(notifications.scheduledReminders.single.body, 'Reminder');
      expect(notifications.scheduledReminders.single.payload, 'reminder_1');
      expect(
        notifications.scheduledReminders.single.repeat,
        ReminderRepeat.daily,
      );
    });

    test('cancels expired one-time reminder without scheduling it', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = StandaloneReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 22, 19),
      );

      await scheduler.syncStandaloneReminder(
        _reminder(
          scheduleType: StandaloneReminderScheduleType.once,
          scheduledDate: DateTime(2026, 5, 22),
          timeMinutes: 18 * 60 + 30,
          isEnabled: true,
        ),
      );

      expect(notifications.canceledIds, [
        standaloneReminderNotificationId('reminder_1'),
      ]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test(
      'schedules enabled reminder tomorrow when time already passed',
      () async {
        final notifications = FakeReminderNotificationClient();
        final scheduler = StandaloneReminderScheduler(
          notifications: notifications,
          now: () => DateTime(2026, 5, 21, 10),
        );

        await scheduler.syncStandaloneReminder(
          _reminder(timeMinutes: 9 * 60, isEnabled: true),
        );

        expect(notifications.scheduledReminders, hasLength(1));
        expect(
          notifications.scheduledReminders.single.scheduledAt,
          DateTime(2026, 5, 22, 9),
        );
        expect(
          notifications.scheduledReminders.single.repeat,
          ReminderRepeat.daily,
        );
      },
    );

    test('schedules enabled reminder tomorrow when time is now', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = StandaloneReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 21, 9),
      );

      await scheduler.syncStandaloneReminder(
        _reminder(timeMinutes: 9 * 60, isEnabled: true),
      );

      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 22, 9),
      );
      expect(
        notifications.scheduledReminders.single.repeat,
        ReminderRepeat.daily,
      );
    });

    test('cancels disabled reminder without scheduling it', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = StandaloneReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 21, 8),
      );

      await scheduler.syncStandaloneReminder(
        _reminder(timeMinutes: 9 * 60, isEnabled: false),
      );

      expect(notifications.canceledIds, [
        standaloneReminderNotificationId('reminder_1'),
      ]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('cancels reminder by id', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = StandaloneReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 21, 8),
      );

      await scheduler.cancelStandaloneReminder('reminder_1');

      expect(notifications.canceledIds, [
        standaloneReminderNotificationId('reminder_1'),
      ]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('schedules one-time reminder at selected date and time', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = StandaloneReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 21, 8),
      );

      await scheduler.syncStandaloneReminder(
        _reminder(
          scheduleType: StandaloneReminderScheduleType.once,
          scheduledDate: DateTime(2026, 5, 22),
          timeMinutes: 18 * 60 + 30,
          isEnabled: true,
        ),
      );

      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 22, 18, 30),
      );
      expect(
        notifications.scheduledReminders.single.repeat,
        ReminderRepeat.none,
      );
    });
  });
}

StandaloneReminder _reminder({
  StandaloneReminderScheduleType scheduleType =
      StandaloneReminderScheduleType.daily,
  DateTime? scheduledDate,
  required int timeMinutes,
  required bool isEnabled,
}) {
  final now = DateTime(2026, 5, 21, 8);

  return StandaloneReminder(
    id: 'reminder_1',
    title: 'Plan your day',
    scheduleType: scheduleType,
    scheduledDate: scheduledDate,
    timeMinutes: timeMinutes,
    isEnabled: isEnabled,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeReminderNotificationClient implements ReminderNotificationClient {
  final scheduledReminders = <ScheduledReminder>[];
  final canceledIds = <int>[];

  @override
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
    ReminderRepeat repeat = ReminderRepeat.none,
  }) async {
    scheduledReminders.add(
      ScheduledReminder(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        payload: payload,
        repeat: repeat,
      ),
    );
  }

  @override
  Future<void> cancelReminder(int id) async {
    canceledIds.add(id);
  }
}

class ScheduledReminder {
  ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.payload,
    required this.repeat,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? payload;
  final ReminderRepeat repeat;
}
