import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/models/goal.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/reports/report_builder.dart';
import 'package:goal_planner/reports/report_period.dart';

void main() {
  group('buildReportSummary', () {
    final today = DateTime(2026, 4, 27);

    test('includes only tasks completed today for today period', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _completedTask(id: 'today', completedAt: today),
          _completedTask(
            id: 'yesterday',
            completedAt: today.subtract(const Duration(days: 1)),
          ),
        ],
        period: ReportPeriod.today,
        today: today,
      );

      expect(summary.completedTasks.map((task) => task.id), ['today']);
      expect(summary.completedCount, 1);
    });

    test('last 7 days includes today through six days ago', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _completedTask(id: 'today', completedAt: today),
          _completedTask(
            id: 'six-days-ago',
            completedAt: today.subtract(const Duration(days: 6)),
          ),
          _completedTask(
            id: 'seven-days-ago',
            completedAt: today.subtract(const Duration(days: 7)),
          ),
        ],
        period: ReportPeriod.last7Days,
        today: today,
      );

      expect(summary.completedTasks.map((task) => task.id).toSet(), {
        'today',
        'six-days-ago',
      });
    });

    test('last 14 days includes today through thirteen days ago', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _completedTask(id: 'today', completedAt: today),
          _completedTask(
            id: 'thirteen-days-ago',
            completedAt: today.subtract(const Duration(days: 13)),
          ),
          _completedTask(
            id: 'fourteen-days-ago',
            completedAt: today.subtract(const Duration(days: 14)),
          ),
        ],
        period: ReportPeriod.last14Days,
        today: today,
      );

      expect(summary.completedTasks.map((task) => task.id).toSet(), {
        'today',
        'thirteen-days-ago',
      });
    });

    test('counts goal-linked and standalone completed tasks', () {
      final goal = _goal(id: 'goal-1', title: 'Blog');

      final summary = buildReportSummary(
        goals: [goal],
        tasks: [
          _completedTask(id: 'goal-task', completedAt: today, goalId: goal.id),
          _completedTask(id: 'standalone-task', completedAt: today),
        ],
        period: ReportPeriod.today,
        today: today,
      );

      expect(summary.completedCount, 2);
      expect(summary.goalLinkedCount, 1);
      expect(summary.standaloneCount, 1);
      expect(summary.goalGroups.length, 1);
      expect(summary.goalGroups.first.goal.id, goal.id);
      expect(summary.goalGroups.first.tasks.first.id, 'goal-task');
    });

    test('ignores tasks that are not completed', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _task(id: 'not-completed', completedAt: today, isCompleted: false),
        ],
        period: ReportPeriod.today,
        today: today,
      );

      expect(summary.completedTasks, isEmpty);
    });

    test('counts active days in selected period', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _completedTask(id: 'today-1', completedAt: today),
          _completedTask(
            id: 'today-2',
            completedAt: today.add(const Duration(hours: 1)),
          ),
          _completedTask(
            id: 'yesterday',
            completedAt: today.subtract(const Duration(days: 1)),
          ),
        ],
        period: ReportPeriod.last7Days,
        today: today,
      );

      expect(summary.activeDaysCount, 2);
    });

    test('groups completed tasks by day from newest to oldest', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _completedTask(
            id: 'yesterday',
            completedAt: today.subtract(const Duration(days: 1)),
          ),
          _completedTask(id: 'today', completedAt: today),
        ],
        period: ReportPeriod.last7Days,
        today: today,
      );

      expect(summary.dayGroups.length, 2);
      expect(summary.dayGroups[0].date, today);
      expect(summary.dayGroups[0].tasks.first.id, 'today');
      expect(
        summary.dayGroups[1].date,
        today.subtract(const Duration(days: 1)),
      );
      expect(summary.dayGroups[1].tasks.first.id, 'yesterday');
    });

    test('calculates planned task count and plan completion percent', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _completedTask(
            id: 'planned-completed-1',
            completedAt: today,
            scheduledDate: today,
          ),
          _completedTask(
            id: 'planned-completed-2',
            completedAt: today,
            scheduledDate: today,
          ),
          _task(
            id: 'planned-not-completed',
            completedAt: null,
            isCompleted: false,
            scheduledDate: today,
          ),
          _completedTask(id: 'completed-unplanned', completedAt: today),
        ],
        period: ReportPeriod.today,
        today: today,
      );

      expect(summary.completedCount, 3);
      expect(summary.plannedCount, 3);
      expect(summary.completedPlannedCount, 2);
      expect(summary.planCompletionPercent, 67);
    });

    test('plan completion percent is zero when nothing was planned', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [_completedTask(id: 'completed-unplanned', completedAt: today)],
        period: ReportPeriod.today,
        today: today,
      );

      expect(summary.plannedCount, 0);
      expect(summary.planCompletionPercent, 0);
    });

    test('calculates current streak ending today', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _completedTask(id: 'today', completedAt: today),
          _completedTask(
            id: 'yesterday',
            completedAt: today.subtract(const Duration(days: 1)),
          ),
          _completedTask(
            id: 'two-days-ago',
            completedAt: today.subtract(const Duration(days: 2)),
          ),
          _completedTask(
            id: 'four-days-ago',
            completedAt: today.subtract(const Duration(days: 4)),
          ),
        ],
        period: ReportPeriod.last14Days,
        today: today,
      );

      expect(summary.currentStreakDays, 3);
    });

    test('current streak is zero when today has no completed tasks', () {
      final summary = buildReportSummary(
        goals: [],
        tasks: [
          _completedTask(
            id: 'yesterday',
            completedAt: today.subtract(const Duration(days: 1)),
          ),
        ],
        period: ReportPeriod.last7Days,
        today: today,
      );

      expect(summary.currentStreakDays, 0);
    });
  });
}

Goal _goal({required String id, required String title}) {
  return Goal(
    id: id,
    title: title,
    description: '',
    status: GoalStatus.active,
    createdAt: DateTime(2026),
  );
}

PlannerTask _completedTask({
  required String id,
  required DateTime completedAt,
  String? goalId,
  DateTime? scheduledDate,
}) {
  return _task(
    id: id,
    completedAt: completedAt,
    goalId: goalId,
    scheduledDate: scheduledDate,
    isCompleted: true,
  );
}

PlannerTask _task({
  required String id,
  required DateTime? completedAt,
  required bool isCompleted,
  String? goalId,
  DateTime? scheduledDate,
}) {
  return PlannerTask(
    id: id,
    title: id,
    description: '',
    createdAt: DateTime(2026),
    goalId: goalId,
    scheduledDate: scheduledDate,
    isCompleted: isCompleted,
    completedAt: completedAt,
  );
}
