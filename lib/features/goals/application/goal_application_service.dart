import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';

class GoalApplicationService {
  const GoalApplicationService();

  GoalMutationResult createGoal({
    required List<Goal> goals,
    required String title,
    required String description,
    DateTime? now,
  }) {
    final createdAt = now ?? DateTime.now();

    final goal = Goal(
      id: 'goal_${createdAt.microsecondsSinceEpoch}',
      title: title,
      description: description,
      status: GoalStatus.active,
      createdAt: createdAt,
    );

    return GoalMutationResult(goals: [...goals, goal], goalToPersist: goal);
  }

  GoalMutationResult updateGoalDetails({
    required List<Goal> goals,
    required String goalId,
    required String title,
    required String description,
  }) {
    Goal? updatedGoal;

    final updatedGoals = goals.map((goal) {
      if (goal.id != goalId) {
        return goal;
      }

      updatedGoal = goal.copyWith(title: title, description: description);

      return updatedGoal!;
    }).toList();

    if (updatedGoal == null) {
      return GoalMutationResult(goals: goals);
    }

    return GoalMutationResult(goals: updatedGoals, goalToPersist: updatedGoal);
  }

  GoalDeletionResult deleteGoalWithRelatedData({
    required String goalId,
    required List<Goal> goals,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
  }) {
    final deletedRecurringRuleIds = recurringRules
        .where((rule) => rule.goalId == goalId)
        .map((rule) => rule.id)
        .toSet();

    return GoalDeletionResult(
      goals: goals.where((goal) => goal.id != goalId).toList(),
      milestones: milestones
          .where((milestone) => milestone.goalId != goalId)
          .toList(),
      tasks: tasks.where((task) => task.goalId != goalId).toList(),
      recurringRules: recurringRules
          .where((rule) => rule.goalId != goalId)
          .toList(),
      recurringExceptions: recurringExceptions.where((exception) {
        return !deletedRecurringRuleIds.contains(exception.ruleId);
      }).toList(),
      goalIdToDelete: goalId,
    );
  }
}

class GoalMutationResult {
  const GoalMutationResult({required this.goals, this.goalToPersist});

  final List<Goal> goals;
  final Goal? goalToPersist;

  bool get hasChange => goalToPersist != null;
}

class GoalDeletionResult {
  const GoalDeletionResult({
    required this.goals,
    required this.milestones,
    required this.tasks,
    required this.recurringRules,
    required this.recurringExceptions,
    required this.goalIdToDelete,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final List<RecurringTaskException> recurringExceptions;
  final String goalIdToDelete;
}
