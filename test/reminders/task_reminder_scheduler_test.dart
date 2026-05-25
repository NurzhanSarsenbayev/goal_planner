import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/task/application/task_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_client.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_texts.dart';

void main() {
  group('TaskReminderScheduler', () {
    test('schedules reminder for eligible task', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = TaskReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 20, 8),
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      await scheduler.syncTaskReminder(task);

      final expectedId = taskReminderNotificationId(task.id);

      expect(notifications.canceledIds, [expectedId]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(notifications.scheduledReminders.single.id, expectedId);
      expect(notifications.scheduledReminders.single.title, 'Plan day');
      expect(notifications.scheduledReminders.single.body, 'Task reminder');
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 20, 9, 15),
      );
      expect(notifications.scheduledReminders.single.payload, 'task_1');
    });

    test('uses configured notification body', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = TaskReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 20, 8),
        notificationTexts: ReminderNotificationTexts(
          taskReminderBody: 'Напоминание о задаче',
        ),
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      await scheduler.syncTaskReminder(task);

      expect(
        notifications.scheduledReminders.single.body,
        'Напоминание о задаче',
      );
    });

    test(
      'does not schedule reminder when task has no scheduled date',
      () async {
        final notifications = FakeReminderNotificationClient();
        final scheduler = TaskReminderScheduler(
          notifications: notifications,
          now: () => DateTime(2026, 5, 20, 8),
        );

        final task = PlannerTask(
          id: 'task_1',
          title: 'Plan day',
          description: '',
          scheduledTimeMinutes: 570,
          reminderMinutesBefore: 15,
          createdAt: DateTime(2026, 5, 20),
        );

        await scheduler.syncTaskReminder(task);

        expect(notifications.canceledIds, [
          taskReminderNotificationId(task.id),
        ]);
        expect(notifications.scheduledReminders, isEmpty);
      },
    );

    test(
      'does not schedule reminder when task has no scheduled time',
      () async {
        final notifications = FakeReminderNotificationClient();
        final scheduler = TaskReminderScheduler(
          notifications: notifications,
          now: () => DateTime(2026, 5, 20, 8),
        );

        final task = PlannerTask(
          id: 'task_1',
          title: 'Plan day',
          description: '',
          scheduledDate: DateTime(2026, 5, 20),
          createdAt: DateTime(2026, 5, 20),
        );

        await scheduler.syncTaskReminder(task);

        expect(notifications.canceledIds, [
          taskReminderNotificationId(task.id),
        ]);
        expect(notifications.scheduledReminders, isEmpty);
      },
    );

    test('does not schedule reminder when reminder is not set', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = TaskReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 20, 8),
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        createdAt: DateTime(2026, 5, 20),
      );

      await scheduler.syncTaskReminder(task);

      expect(notifications.canceledIds, [taskReminderNotificationId(task.id)]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('does not schedule reminder for completed task', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = TaskReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 20, 8),
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        isCompleted: true,
        completedAt: DateTime(2026, 5, 20),
        createdAt: DateTime(2026, 5, 20),
      );

      await scheduler.syncTaskReminder(task);

      expect(notifications.canceledIds, [taskReminderNotificationId(task.id)]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test(
      'does not schedule reminder when reminder time is in the past',
      () async {
        final notifications = FakeReminderNotificationClient();
        final scheduler = TaskReminderScheduler(
          notifications: notifications,
          now: () => DateTime(2026, 5, 20, 10),
        );

        final task = PlannerTask(
          id: 'task_1',
          title: 'Plan day',
          description: '',
          scheduledDate: DateTime(2026, 5, 20),
          scheduledTimeMinutes: 570,
          reminderMinutesBefore: 15,
          createdAt: DateTime(2026, 5, 20),
        );

        await scheduler.syncTaskReminder(task);

        expect(notifications.canceledIds, [
          taskReminderNotificationId(task.id),
        ]);
        expect(notifications.scheduledReminders, isEmpty);
      },
    );

    test('schedules reminder for recurring occurrence', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = TaskReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 20, 8),
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        recurringRuleId: 'rule_1',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      await scheduler.syncTaskReminder(task);

      final expectedId = taskReminderNotificationId(task.id);

      expect(notifications.canceledIds, [expectedId]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(notifications.scheduledReminders.single.id, expectedId);
      expect(notifications.scheduledReminders.single.title, 'Plan day');
      expect(notifications.scheduledReminders.single.body, 'Task reminder');
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 20, 9, 15),
      );
      expect(notifications.scheduledReminders.single.payload, task.id);
    });

    test(
      'uses configured notification body for recurring occurrence',
      () async {
        final notifications = FakeReminderNotificationClient();
        final scheduler = TaskReminderScheduler(
          notifications: notifications,
          now: () => DateTime(2026, 5, 20, 8),
          notificationTexts: ReminderNotificationTexts(
            taskReminderBody: 'Напоминание о задаче',
          ),
        );

        final task = PlannerTask(
          id: 'task_1',
          title: 'Workout',
          description: '',
          recurringRuleId: 'rule_1',
          scheduledDate: DateTime(2026, 5, 20),
          scheduledTimeMinutes: 570,
          reminderMinutesBefore: 15,
          createdAt: DateTime(2026, 5, 20),
        );

        await scheduler.syncTaskReminder(task);

        expect(notifications.scheduledReminders, hasLength(1));
        expect(
          notifications.scheduledReminders.single.body,
          'Напоминание о задаче',
        );
      },
    );

    test('cancels reminder by task id', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = TaskReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 20, 8),
      );

      await scheduler.cancelTaskReminder('task_1');

      expect(notifications.canceledIds, [taskReminderNotificationId('task_1')]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('uses stable notification id for same task id', () {
      expect(
        taskReminderNotificationId('task_1'),
        taskReminderNotificationId('task_1'),
      );
      expect(
        taskReminderNotificationId('task_1'),
        isNot(taskReminderNotificationId('task_2')),
      );
    });
  });
}

class FakeReminderNotificationClient implements ReminderNotificationClient {
  final List<int> canceledIds = [];
  final List<ScheduledTaskReminderCall> scheduledReminders = [];

  @override
  Future<void> cancelReminder(int id) async {
    canceledIds.add(id);
  }

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
      ScheduledTaskReminderCall(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        payload: payload,
      ),
    );
  }
}

class ScheduledTaskReminderCall {
  const ScheduledTaskReminderCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? payload;
}
