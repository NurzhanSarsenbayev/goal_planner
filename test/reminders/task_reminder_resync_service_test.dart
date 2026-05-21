import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/application/task_reminder_resync_service.dart';
import 'package:goal_planner/features/reminders/application/task_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/application/reminder_notification_client.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('TaskReminderResyncService', () {
    test('syncs reminders for all provided tasks', () async {
      final notifications = FakeReminderNotificationClient();
      final scheduler = TaskReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 20, 8),
      );
      final service = TaskReminderResyncService(
        taskReminderScheduler: scheduler,
      );

      final eligibleTask = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      final taskWithoutReminder = PlannerTask(
        id: 'task_2',
        title: 'Read',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 600,
        createdAt: DateTime(2026, 5, 20),
      );

      await service.syncTaskReminders([eligibleTask, taskWithoutReminder]);

      expect(notifications.canceledIds, [
        taskReminderNotificationId('task_1'),
        taskReminderNotificationId('task_2'),
      ]);

      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.id,
        taskReminderNotificationId('task_1'),
      );
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 20, 9, 15),
      );
    });

    test(
      'cancels removed tasks and syncs current tasks after replacement',
      () async {
        final notifications = FakeReminderNotificationClient();
        final scheduler = TaskReminderScheduler(
          notifications: notifications,
          now: () => DateTime(2026, 5, 20, 8),
        );
        final service = TaskReminderResyncService(
          taskReminderScheduler: scheduler,
        );

        final removedTask = PlannerTask(
          id: 'old_task',
          title: 'Old task',
          description: '',
          scheduledDate: DateTime(2026, 5, 20),
          scheduledTimeMinutes: 540,
          reminderMinutesBefore: 15,
          createdAt: DateTime(2026, 5, 19),
        );

        final keptTask = PlannerTask(
          id: 'kept_task',
          title: 'Kept task',
          description: '',
          scheduledDate: DateTime(2026, 5, 20),
          scheduledTimeMinutes: 570,
          reminderMinutesBefore: 15,
          createdAt: DateTime(2026, 5, 19),
        );

        final restoredTask = PlannerTask(
          id: 'restored_task',
          title: 'Restored task',
          description: '',
          scheduledDate: DateTime(2026, 5, 20),
          scheduledTimeMinutes: 600,
          reminderMinutesBefore: 15,
          createdAt: DateTime(2026, 5, 20),
        );

        await service.syncAfterTaskSetReplacement(
          previousTasks: [removedTask, keptTask],
          currentTasks: [keptTask, restoredTask],
        );

        expect(notifications.canceledIds, [
          taskReminderNotificationId('old_task'),
          taskReminderNotificationId('kept_task'),
          taskReminderNotificationId('restored_task'),
        ]);

        expect(notifications.scheduledReminders, hasLength(2));
        expect(notifications.scheduledReminders.map((call) => call.id), [
          taskReminderNotificationId('kept_task'),
          taskReminderNotificationId('restored_task'),
        ]);
      },
    );
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
