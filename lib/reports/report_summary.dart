import '../models/goal.dart';
import '../models/planner_task.dart';
import 'report_period.dart';

class ReportSummary {
  const ReportSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.completedTasks,
    required this.goalLinkedTasks,
    required this.standaloneTasks,
    required this.goalGroups,
  });

  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final List<PlannerTask> completedTasks;
  final List<PlannerTask> goalLinkedTasks;
  final List<PlannerTask> standaloneTasks;
  final List<GoalTaskReportGroup> goalGroups;

  int get completedCount => completedTasks.length;

  int get goalLinkedCount => goalLinkedTasks.length;

  int get standaloneCount => standaloneTasks.length;
}

class GoalTaskReportGroup {
  const GoalTaskReportGroup({required this.goal, required this.tasks});

  final Goal goal;
  final List<PlannerTask> tasks;
}
