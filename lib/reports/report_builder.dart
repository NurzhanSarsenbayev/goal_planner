import '../models/goal.dart';
import '../models/planner_task.dart';
import '../shared/planner_dates.dart';
import 'report_period.dart';
import 'report_summary.dart';

ReportSummary buildReportSummary({
  required List<Goal> goals,
  required List<PlannerTask> tasks,
  required ReportPeriod period,
  required DateTime today,
}) {
  final endDate = dateOnly(today);
  final startDate = period.startDate(endDate);

  final completedTasks =
      tasks.where((task) {
        final completedAt = task.completedAt;

        if (!task.isCompleted || completedAt == null) {
          return false;
        }

        final completedDate = dateOnly(completedAt);

        return !completedDate.isBefore(startDate) &&
            !completedDate.isAfter(endDate);
      }).toList()..sort((first, second) {
        final firstCompletedAt = first.completedAt!;
        final secondCompletedAt = second.completedAt!;

        return secondCompletedAt.compareTo(firstCompletedAt);
      });

  final goalLinkedTasks = completedTasks
      .where((task) => task.goalId != null)
      .toList();

  final standaloneTasks = completedTasks
      .where((task) => task.goalId == null)
      .toList();

  return ReportSummary(
    period: period,
    startDate: startDate,
    endDate: endDate,
    completedTasks: completedTasks,
    goalLinkedTasks: goalLinkedTasks,
    standaloneTasks: standaloneTasks,
    goalGroups: _groupTasksByGoal(goals: goals, tasks: goalLinkedTasks),
  );
}

List<GoalTaskReportGroup> _groupTasksByGoal({
  required List<Goal> goals,
  required List<PlannerTask> tasks,
}) {
  final groups = <GoalTaskReportGroup>[];

  for (final goal in goals) {
    final goalTasks = tasks.where((task) => task.goalId == goal.id).toList();

    if (goalTasks.isEmpty) {
      continue;
    }

    groups.add(GoalTaskReportGroup(goal: goal, tasks: goalTasks));
  }

  return groups;
}
