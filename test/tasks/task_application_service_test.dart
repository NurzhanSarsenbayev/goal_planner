import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/tasks/application/task_application_service.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('TaskApplicationService', () {
    const service = TaskApplicationService();

    test('creates scheduled task with optional scheduled time', () {
      final task = service.createTask(
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20, 23, 59),
        scheduledTimeMinutes: 9 * 60 + 30,
        reminderMinutesBefore: 15,
        now: DateTime(2026, 5, 20),
      );

      expect(task.scheduledDate, DateTime(2026, 5, 20));
      expect(task.scheduledTimeMinutes, 570);
      expect(task.reminderMinutesBefore, 15);
    });

    test('schedules existing task for date and time', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        createdAt: DateTime(2026, 5, 20),
      );

      final result = service.scheduleTaskForDateAndTime(
        tasks: [task],
        taskId: task.id,
        scheduledDate: DateTime(2026, 5, 21, 23, 59),
        scheduledTimeMinutes: 8 * 60,
      );

      expect(result.taskToPersist, isNotNull);
      expect(result.tasks.single.scheduledDate, DateTime(2026, 5, 21));
      expect(result.tasks.single.scheduledTimeMinutes, 480);
    });

    test('scheduleTaskForDateAndTime can clear scheduled time', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        createdAt: DateTime(2026, 5, 20),
      );

      final result = service.scheduleTaskForDateAndTime(
        tasks: [task],
        taskId: task.id,
        scheduledDate: DateTime(2026, 5, 21),
        scheduledTimeMinutes: null,
      );

      expect(result.taskToPersist, isNotNull);
      expect(result.tasks.single.scheduledDate, DateTime(2026, 5, 21));
      expect(result.tasks.single.scheduledTimeMinutes, isNull);
    });
  });
}
