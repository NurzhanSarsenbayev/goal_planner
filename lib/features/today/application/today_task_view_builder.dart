import '../../../models/goal.dart';
import '../../../models/planner_task.dart';
import '../../../shared/planner_dates.dart';

class TodayTaskViewBuilder {
  const TodayTaskViewBuilder();

  TodayTaskView build({
    required List<Goal> goals,
    required List<PlannerTask> tasks,
  }) {
    final overdueTasks = tasks.where(_isOverdue).toList()
      ..sort((first, second) {
        return first.scheduledDate!.compareTo(second.scheduledDate!);
      });

    final pendingTodayTasks = tasks
        .where((task) => task.isScheduledForToday && !task.isCompleted)
        .toList();

    final doneTodayTasks = tasks.where(_wasCompletedToday).toList();

    return TodayTaskView(
      goals: goals,
      overdueTasks: overdueTasks,
      pendingTodayTasks: pendingTodayTasks,
      doneTodayTasks: doneTodayTasks,
    );
  }

  bool _wasCompletedToday(PlannerTask task) {
    final completedAt = task.completedAt;

    if (completedAt == null) {
      return false;
    }

    return dateOnly(completedAt) == todayDate();
  }

  bool _isOverdue(PlannerTask task) {
    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null || task.isCompleted) {
      return false;
    }

    return dateOnly(scheduledDate).isBefore(todayDate());
  }
}

class TodayTaskView {
  const TodayTaskView({
    required this.goals,
    required this.overdueTasks,
    required this.pendingTodayTasks,
    required this.doneTodayTasks,
  });

  final List<Goal> goals;
  final List<PlannerTask> overdueTasks;
  final List<PlannerTask> pendingTodayTasks;
  final List<PlannerTask> doneTodayTasks;

  bool get isEmpty {
    return overdueTasks.isEmpty &&
        pendingTodayTasks.isEmpty &&
        doneTodayTasks.isEmpty;
  }

  Goal? findGoalById(String? goalId) {
    if (goalId == null) {
      return null;
    }

    for (final goal in goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }

  bool isOverdue(PlannerTask task) {
    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null || task.isCompleted) {
      return false;
    }

    return dateOnly(scheduledDate).isBefore(todayDate());
  }
}
