import '../models/goal.dart';
import '../models/planner_task.dart';
import 'report_period.dart';

class ReportSummary {
  const ReportSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.completedTasks,
    required this.plannedTasks,
    required this.completedPlannedTasks,
    required this.goalLinkedTasks,
    required this.standaloneTasks,
    required this.goalGroups,
    required this.dayGroups,
    required this.currentStreakDays,
  });

  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final List<PlannerTask> completedTasks;
  final List<PlannerTask> plannedTasks;
  final List<PlannerTask> completedPlannedTasks;
  final List<PlannerTask> goalLinkedTasks;
  final List<PlannerTask> standaloneTasks;
  final List<GoalTaskReportGroup> goalGroups;
  final List<DayTaskReportGroup> dayGroups;
  final int currentStreakDays;

  int get completedCount => completedTasks.length;

  int get plannedCount => plannedTasks.length;

  int get completedPlannedCount => completedPlannedTasks.length;

  int get goalLinkedCount => goalLinkedTasks.length;

  int get standaloneCount => standaloneTasks.length;

  int get activeDaysCount => dayGroups.length;

  int get planCompletionPercent {
    if (plannedCount == 0) {
      return 0;
    }

    return ((completedPlannedCount / plannedCount) * 100).round();
  }
}

class GoalTaskReportGroup {
  const GoalTaskReportGroup({required this.goal, required this.tasks});

  final Goal goal;
  final List<PlannerTask> tasks;
}

class DayTaskReportGroup {
  const DayTaskReportGroup({required this.date, required this.tasks});

  final DateTime date;
  final List<PlannerTask> tasks;
}
