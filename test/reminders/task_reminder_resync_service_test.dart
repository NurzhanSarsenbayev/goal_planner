import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/application/task_reminder_resync_service.dart';
import 'package:goal_planner/features/reminders/application/task_reminder_scheduler.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('TaskReminderResyncService', () {
    test('syncs reminders for all provided tasks', () async {
      final notifications = FakeTaskReminderNotificationClient();
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
  });
}

class FakeTaskReminderNotificationClient
    implements TaskReminderNotificationClient {
  final List<int> canceledIds = [];
  final List<ScheduledTaskReminderCall> scheduledReminders = [];

  @override
  Future<void> cancelTaskReminder(int id) async {
    canceledIds.add(id);
  }

  @override
  Future<void> scheduleTaskReminder({
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
