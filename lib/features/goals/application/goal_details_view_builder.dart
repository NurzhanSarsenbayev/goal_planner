import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_rule.dart';

class GoalDetailsViewBuilder {
  const GoalDetailsViewBuilder();

  GoalDetailsView build({
    required Goal goal,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
  }) {
    final goalTasks = tasks
        .where((task) => task.goalId == goal.id && task.recurringRuleId == null)
        .toList();

    final goalMilestones = milestones
        .where((milestone) => milestone.goalId == goal.id)
        .toList();

    final milestoneIds = goalMilestones
        .map((milestone) => milestone.id)
        .toSet();

    final directGoalRecurringRules = recurringRules
        .where((rule) => rule.goalId == goal.id && rule.milestoneId == null)
        .toList();

    final recurringRulesByMilestoneId = <String, List<RecurringTaskRule>>{};

    for (final milestone in goalMilestones) {
      recurringRulesByMilestoneId[milestone.id] = recurringRules
          .where(
            (rule) =>
                rule.goalId == goal.id && rule.milestoneId == milestone.id,
          )
          .toList();
    }

    final directGoalTasks = goalTasks
        .where(
          (task) =>
              task.milestoneId == null ||
              !milestoneIds.contains(task.milestoneId),
        )
        .toList();

    final completedTasks = goalTasks.where((task) => task.isCompleted).length;

    final tasksByMilestoneId = <String, List<PlannerTask>>{};

    for (final milestone in goalMilestones) {
      tasksByMilestoneId[milestone.id] = goalTasks
          .where((task) => task.milestoneId == milestone.id)
          .toList();
    }

    return GoalDetailsView(
      goalTasks: goalTasks,
      goalMilestones: goalMilestones,
      directGoalTasks: directGoalTasks,
      completedTasks: completedTasks,
      tasksByMilestoneId: tasksByMilestoneId,
      directGoalRecurringRules: directGoalRecurringRules,
      recurringRulesByMilestoneId: recurringRulesByMilestoneId,
    );
  }
}

class GoalDetailsView {
  const GoalDetailsView({
    required this.goalTasks,
    required this.goalMilestones,
    required this.directGoalTasks,
    required this.completedTasks,
    required this.tasksByMilestoneId,
    required this.directGoalRecurringRules,
    required this.recurringRulesByMilestoneId,
  });

  final List<PlannerTask> goalTasks;
  final List<Milestone> goalMilestones;
  final List<PlannerTask> directGoalTasks;
  final int completedTasks;
  final Map<String, List<PlannerTask>> tasksByMilestoneId;
  final List<RecurringTaskRule> directGoalRecurringRules;
  final Map<String, List<RecurringTaskRule>> recurringRulesByMilestoneId;

  List<PlannerTask> tasksForMilestone(String milestoneId) {
    return tasksByMilestoneId[milestoneId] ?? const [];
  }

  List<RecurringTaskRule> recurringRulesForMilestone(String milestoneId) {
    return recurringRulesByMilestoneId[milestoneId] ?? const [];
  }
}
