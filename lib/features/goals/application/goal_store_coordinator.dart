import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import '../../planner/application/planner_cleanup_repository.dart';
import 'goal_application_service.dart';
import 'goal_repository.dart';

class GoalStoreMutation {
  const GoalStoreMutation({
    required this.goals,
    required this.milestones,
    required this.tasks,
    required this.recurringRules,
    required this.recurringExceptions,
    required this.persistOperation,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final List<RecurringTaskException> recurringExceptions;
  final Future<void> Function() persistOperation;
}

class GoalStoreCoordinator {
  GoalStoreCoordinator({
    required GoalRepository goalRepository,
    required PlannerCleanupRepository cleanupRepository,
    GoalApplicationService? goalApplicationService,
  }) : _goalRepository = goalRepository,
       _cleanupRepository = cleanupRepository,
       _goalApplicationService =
           goalApplicationService ?? const GoalApplicationService();

  final GoalRepository _goalRepository;
  final PlannerCleanupRepository _cleanupRepository;
  final GoalApplicationService _goalApplicationService;

  GoalStoreMutation? createGoal({
    required List<Goal> goals,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
    required String title,
    required String description,
  }) {
    final result = _goalApplicationService.createGoal(
      goals: goals,
      title: title,
      description: description,
    );

    final goalToPersist = result.goalToPersist;

    if (goalToPersist == null) {
      return null;
    }

    return GoalStoreMutation(
      goals: result.goals,
      milestones: milestones,
      tasks: tasks,
      recurringRules: recurringRules,
      recurringExceptions: recurringExceptions,
      persistOperation: () => _goalRepository.saveGoal(goalToPersist),
    );
  }

  GoalStoreMutation? updateGoal({
    required List<Goal> goals,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
    required String goalId,
    required String title,
    required String description,
  }) {
    final result = _goalApplicationService.updateGoalDetails(
      goals: goals,
      goalId: goalId,
      title: title,
      description: description,
    );

    final goalToPersist = result.goalToPersist;

    if (goalToPersist == null) {
      return null;
    }

    return GoalStoreMutation(
      goals: result.goals,
      milestones: milestones,
      tasks: tasks,
      recurringRules: recurringRules,
      recurringExceptions: recurringExceptions,
      persistOperation: () => _goalRepository.saveGoal(goalToPersist),
    );
  }

  GoalStoreMutation deleteGoalWithRelatedData({
    required String goalId,
    required List<Goal> goals,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
  }) {
    final result = _goalApplicationService.deleteGoalWithRelatedData(
      goalId: goalId,
      goals: goals,
      milestones: milestones,
      tasks: tasks,
      recurringRules: recurringRules,
      recurringExceptions: recurringExceptions,
    );

    return GoalStoreMutation(
      goals: result.goals,
      milestones: result.milestones,
      tasks: result.tasks,
      recurringRules: result.recurringRules,
      recurringExceptions: result.recurringExceptions,
      persistOperation: () =>
          _cleanupRepository.deleteGoalWithRelatedData(result.goalIdToDelete),
    );
  }
}
