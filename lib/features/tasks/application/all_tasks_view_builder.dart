import '../../../models/goal.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_rule.dart';
import '../../../shared/planner_dates.dart';

class AllTasksViewBuilder {
  const AllTasksViewBuilder();

  AllTasksView build({
    required List<Goal> goals,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
  }) {
    final visibleTasks = tasks.where(_shouldShowTaskInAllTasks).toList();

    return AllTasksView(
      goals: goals,
      visibleTasks: visibleTasks,
      recurringRules: recurringRules,
    );
  }

  bool _shouldShowTaskInAllTasks(PlannerTask task) {
    if (task.recurringRuleId == null) {
      return true;
    }

    if (task.isCompleted) {
      return true;
    }

    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null) {
      return true;
    }

    final normalizedScheduledDate = dateOnly(scheduledDate);

    return !normalizedScheduledDate.isAfter(todayDate());
  }
}

class AllTasksView {
  const AllTasksView({
    required this.goals,
    required this.visibleTasks,
    required this.recurringRules,
  });

  final List<Goal> goals;
  final List<PlannerTask> visibleTasks;
  final List<RecurringTaskRule> recurringRules;

  bool get hasVisibleTasks => visibleTasks.isNotEmpty;

  bool get hasRecurringRules => recurringRules.isNotEmpty;

  bool get isEmpty => !hasVisibleTasks && !hasRecurringRules;

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
}
