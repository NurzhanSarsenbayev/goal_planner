import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/calendar/application/calendar_task_view_builder.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('CalendarTaskViewBuilder', () {
    test('sorts selected date tasks by time with untimed tasks last', () {
      final selectedDate = DateTime(2026, 5, 20);

      final tasks = const CalendarTaskViewBuilder().tasksForDate(
        date: selectedDate,
        tasks: [
          _task(
            id: 'other_date',
            title: 'Other date',
            scheduledDate: DateTime(2026, 5, 21),
            scheduledTimeMinutes: 7 * 60,
          ),
          _task(id: 'untimed_b', title: 'B', scheduledDate: selectedDate),
          _task(
            id: 'late',
            title: 'Late',
            scheduledDate: selectedDate,
            scheduledTimeMinutes: 18 * 60,
          ),
          _task(
            id: 'early',
            title: 'Early',
            scheduledDate: selectedDate,
            scheduledTimeMinutes: 8 * 60,
          ),
          _task(id: 'untimed_a', title: 'A', scheduledDate: selectedDate),
        ],
      );

      expect(tasks.map((task) => task.id), [
        'early',
        'late',
        'untimed_a',
        'untimed_b',
      ]);
    });
  });
}

PlannerTask _task({
  required String id,
  required String title,
  required DateTime scheduledDate,
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
