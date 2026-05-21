import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('PlannerTask scheduled time', () {
    test('stores optional scheduled time as minutes since midnight', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 9 * 60 + 30,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      expect(task.scheduledTimeMinutes, 570);
      expect(task.reminderMinutesBefore, 15);
    });

    test('scheduleForDate keeps existing scheduled time', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        createdAt: DateTime(2026, 5, 20),
      );

      final updatedTask = task.scheduleForDate(DateTime(2026, 5, 21, 23, 59));

      expect(updatedTask.scheduledDate, DateTime(2026, 5, 21));
      expect(updatedTask.scheduledTimeMinutes, 570);
    });

    test('scheduleForDateAndTime updates date and time', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        createdAt: DateTime(2026, 5, 20),
      );

      final updatedTask = task.scheduleForDateAndTime(
        date: DateTime(2026, 5, 21, 23, 59),
        timeMinutes: 8 * 60,
      );

      expect(updatedTask.scheduledDate, DateTime(2026, 5, 21));
      expect(updatedTask.scheduledTimeMinutes, 480);
    });

    test('unschedule clears date and time', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      final updatedTask = task.unschedule();

      expect(updatedTask.scheduledDate, isNull);
      expect(updatedTask.scheduledTimeMinutes, isNull);
      expect(updatedTask.reminderMinutesBefore, isNull);
    });

    test(
      'scheduleForDateAndTime clears reminder when scheduled time is cleared',
      () {
        final task = PlannerTask(
          id: 'task_1',
          title: 'Plan day',
          description: '',
          scheduledDate: DateTime(2026, 5, 20),
          scheduledTimeMinutes: 570,
          reminderMinutesBefore: 15,
          createdAt: DateTime(2026, 5, 20),
        );

        final updatedTask = task.scheduleForDateAndTime(
          date: DateTime(2026, 5, 21),
          timeMinutes: null,
        );

        expect(updatedTask.scheduledDate, DateTime(2026, 5, 21));
        expect(updatedTask.scheduledTimeMinutes, isNull);
        expect(updatedTask.reminderMinutesBefore, isNull);
      },
    );

    test('copyWith can clear scheduled time', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        createdAt: DateTime(2026, 5, 20),
      );

      final updatedTask = task.copyWith(scheduledTimeMinutes: null);

      expect(updatedTask.scheduledDate, DateTime(2026, 5, 20));
      expect(updatedTask.scheduledTimeMinutes, isNull);
    });

    test('setReminder updates reminder for timed task', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        createdAt: DateTime(2026, 5, 20),
      );

      final updatedTask = task.setReminder(15);

      expect(updatedTask.reminderMinutesBefore, 15);
    });

    test('setReminder clears reminder', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      final updatedTask = task.setReminder(null);

      expect(updatedTask.reminderMinutesBefore, isNull);
    });

    test('setReminder does not keep reminder for untimed task', () {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        createdAt: DateTime(2026, 5, 20),
      );

      final updatedTask = task.setReminder(15);

      expect(updatedTask.reminderMinutesBefore, isNull);
    });
  });
}
