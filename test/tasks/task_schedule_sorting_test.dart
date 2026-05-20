import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/tasks/application/task_schedule_sorting.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('task schedule sorting', () {
    test('sorts timed tasks before untimed tasks by time', () {
      final tasks = [
        _task(id: 'untimed_b', title: 'B'),
        _task(id: 'late', title: 'Late', scheduledTimeMinutes: 18 * 60),
        _task(id: 'early', title: 'Early', scheduledTimeMinutes: 8 * 60),
        _task(id: 'untimed_a', title: 'A'),
      ]..sort(compareTasksByScheduledTimeThenTitle);

      expect(tasks.map((task) => task.id), [
        'early',
        'late',
        'untimed_a',
        'untimed_b',
      ]);
    });

    test('sorts equal-time tasks by title', () {
      final tasks = [
        _task(id: 'b', title: 'Beta', scheduledTimeMinutes: 9 * 60),
        _task(id: 'a', title: 'Alpha', scheduledTimeMinutes: 9 * 60),
      ]..sort(compareTasksByScheduledTimeThenTitle);

      expect(tasks.map((task) => task.id), ['a', 'b']);
    });

    test('sorts scheduled tasks by date then time then title', () {
      final tasks = [
        _task(
          id: 'tomorrow',
          title: 'Tomorrow',
          scheduledDate: DateTime(2026, 5, 21),
          scheduledTimeMinutes: 8 * 60,
        ),
        _task(
          id: 'today_late',
          title: 'Today late',
          scheduledDate: DateTime(2026, 5, 20),
          scheduledTimeMinutes: 18 * 60,
        ),
        _task(
          id: 'today_early',
          title: 'Today early',
          scheduledDate: DateTime(2026, 5, 20),
          scheduledTimeMinutes: 8 * 60,
        ),
      ]..sort(compareTasksByScheduledDateTimeThenTitle);

      expect(tasks.map((task) => task.id), [
        'today_early',
        'today_late',
        'tomorrow',
      ]);
    });
  });
}

PlannerTask _task({
  required String id,
  required String title,
  DateTime? scheduledDate,
  int? scheduledTimeMinutes,
}) {
  return PlannerTask(
    id: id,
    title: title,
    description: '',
    scheduledDate: scheduledDate,
    scheduledTimeMinutes: scheduledTimeMinutes,
    createdAt: DateTime(2026, 5, 20),
  );
}
