import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/today/application/today_task_view_builder.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/shared/planner_dates.dart';

void main() {
  group('TodayTaskViewBuilder', () {
    test('sorts pending today tasks by time with untimed tasks last', () {
      final today = todayDate();

      final view = const TodayTaskViewBuilder().build(
        goals: [],
        tasks: [
          _task(id: 'untimed_b', title: 'B', scheduledDate: today),
          _task(
            id: 'late',
            title: 'Late',
            scheduledDate: today,
            scheduledTimeMinutes: 18 * 60,
          ),
          _task(
            id: 'early',
            title: 'Early',
            scheduledDate: today,
            scheduledTimeMinutes: 8 * 60,
          ),
          _task(id: 'untimed_a', title: 'A', scheduledDate: today),
        ],
      );

      expect(view.pendingTodayTasks.map((task) => task.id), [
        'early',
        'late',
        'untimed_a',
        'untimed_b',
      ]);
    });

    test('sorts overdue tasks by date then time', () {
      final today = todayDate();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final view = const TodayTaskViewBuilder().build(
        goals: [],
        tasks: [
          _task(
            id: 'yesterday_early',
            title: 'Yesterday early',
            scheduledDate: yesterday,
            scheduledTimeMinutes: 8 * 60,
          ),
          _task(
            id: 'two_days_ago_late',
            title: 'Two days ago late',
            scheduledDate: twoDaysAgo,
            scheduledTimeMinutes: 18 * 60,
          ),
          _task(
            id: 'two_days_ago_early',
            title: 'Two days ago early',
            scheduledDate: twoDaysAgo,
            scheduledTimeMinutes: 8 * 60,
          ),
        ],
      );

      expect(view.overdueTasks.map((task) => task.id), [
        'two_days_ago_early',
        'two_days_ago_late',
        'yesterday_early',
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
