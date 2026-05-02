import '../../../models/goal.dart';
import '../../../models/planner_task.dart';
import '../../../shared/planner_dates.dart';
import '../domain/report_period.dart';
import '../domain/report_summary.dart';

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

        return _isInsidePeriod(
          date: completedDate,
          startDate: startDate,
          endDate: endDate,
        );
      }).toList()..sort((first, second) {
        final firstCompletedAt = first.completedAt!;
        final secondCompletedAt = second.completedAt!;

        return secondCompletedAt.compareTo(firstCompletedAt);
      });

  final plannedTasks =
      tasks.where((task) {
        final scheduledDate = task.scheduledDate;

        if (scheduledDate == null) {
          return false;
        }

        return _isInsidePeriod(
          date: dateOnly(scheduledDate),
          startDate: startDate,
          endDate: endDate,
        );
      }).toList()..sort((first, second) {
        final firstScheduledDate = first.scheduledDate!;
        final secondScheduledDate = second.scheduledDate!;

        return firstScheduledDate.compareTo(secondScheduledDate);
      });

  final completedPlannedTasks = plannedTasks.where((task) {
    final completedAt = task.completedAt;

    if (!task.isCompleted || completedAt == null) {
      return false;
    }

    return _isInsidePeriod(
      date: dateOnly(completedAt),
      startDate: startDate,
      endDate: endDate,
    );
  }).toList();

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
    plannedTasks: plannedTasks,
    completedPlannedTasks: completedPlannedTasks,
    goalLinkedTasks: goalLinkedTasks,
    standaloneTasks: standaloneTasks,
    goalGroups: _groupTasksByGoal(goals: goals, tasks: goalLinkedTasks),
    dayGroups: _groupTasksByDay(completedTasks),
    currentStreakDays: _currentStreakDays(tasks: tasks, today: endDate),
  );
}

bool _isInsidePeriod({
  required DateTime date,
  required DateTime startDate,
  required DateTime endDate,
}) {
  return !date.isBefore(startDate) && !date.isAfter(endDate);
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

List<DayTaskReportGroup> _groupTasksByDay(List<PlannerTask> tasks) {
  final groups = <DayTaskReportGroup>[];

  for (final task in tasks) {
    final completedAt = task.completedAt;

    if (completedAt == null) {
      continue;
    }

    final completedDate = dateOnly(completedAt);

    if (groups.isEmpty || groups.last.date != completedDate) {
      groups.add(DayTaskReportGroup(date: completedDate, tasks: [task]));
    } else {
      groups.last.tasks.add(task);
    }
  }

  return groups;
}

int _currentStreakDays({
  required List<PlannerTask> tasks,
  required DateTime today,
}) {
  final completedDates = tasks
      .where((task) => task.isCompleted && task.completedAt != null)
      .map((task) => dateOnly(task.completedAt!))
      .toSet();

  var currentDate = dateOnly(today);
  var streak = 0;

  while (completedDates.contains(currentDate)) {
    streak += 1;
    currentDate = currentDate.subtract(const Duration(days: 1));
  }

  return streak;
}
