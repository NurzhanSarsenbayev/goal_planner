import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';

class MilestoneApplicationService {
  const MilestoneApplicationService();

  MilestoneMutationResult addMilestone({
    required List<Milestone> milestones,
    required Milestone milestone,
  }) {
    return MilestoneMutationResult(
      milestones: [...milestones, milestone],
      milestoneToPersist: milestone,
    );
  }

  MilestoneMutationResult updateMilestoneDetails({
    required List<Milestone> milestones,
    required String milestoneId,
    required String title,
    required String description,
  }) {
    Milestone? updatedMilestone;

    final updatedMilestones = milestones.map((milestone) {
      if (milestone.id != milestoneId) {
        return milestone;
      }

      updatedMilestone = milestone.copyWith(
        title: title,
        description: description,
      );

      return updatedMilestone!;
    }).toList();

    if (updatedMilestone == null) {
      return MilestoneMutationResult(milestones: milestones);
    }

    return MilestoneMutationResult(
      milestones: updatedMilestones,
      milestoneToPersist: updatedMilestone,
    );
  }

  DeleteMilestoneAndMoveTasksResult deleteMilestoneAndMoveTasksToDirect({
    required String milestoneId,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
  }) {
    return DeleteMilestoneAndMoveTasksResult(
      milestones: milestones
          .where((milestone) => milestone.id != milestoneId)
          .toList(),
      tasks: tasks.map((task) {
        if (task.milestoneId != milestoneId) {
          return task;
        }

        return task.moveToDirectGoal();
      }).toList(),
      recurringRules: recurringRules.map((rule) {
        if (rule.milestoneId != milestoneId) {
          return rule;
        }

        return rule.copyWith(milestoneId: null);
      }).toList(),
      milestoneIdToDelete: milestoneId,
    );
  }

  DeleteMilestoneWithTasksResult deleteMilestoneWithTasks({
    required String milestoneId,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
  }) {
    final deletedRecurringRuleIds = recurringRules
        .where((rule) => rule.milestoneId == milestoneId)
        .map((rule) => rule.id)
        .toSet();

    return DeleteMilestoneWithTasksResult(
      milestones: milestones
          .where((milestone) => milestone.id != milestoneId)
          .toList(),
      tasks: tasks.where((task) => task.milestoneId != milestoneId).toList(),
      recurringRules: recurringRules
          .where((rule) => rule.milestoneId != milestoneId)
          .toList(),
      recurringExceptions: recurringExceptions.where((exception) {
        return !deletedRecurringRuleIds.contains(exception.ruleId);
      }).toList(),
      milestoneIdToDelete: milestoneId,
    );
  }
}

class MilestoneMutationResult {
  const MilestoneMutationResult({
    required this.milestones,
    this.milestoneToPersist,
  });

  final List<Milestone> milestones;
  final Milestone? milestoneToPersist;

  bool get hasChange => milestoneToPersist != null;
}

class DeleteMilestoneAndMoveTasksResult {
  const DeleteMilestoneAndMoveTasksResult({
    required this.milestones,
    required this.tasks,
    required this.recurringRules,
    required this.milestoneIdToDelete,
  });

  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final String milestoneIdToDelete;
}

class DeleteMilestoneWithTasksResult {
  const DeleteMilestoneWithTasksResult({
    required this.milestones,
    required this.tasks,
    required this.recurringRules,
    required this.recurringExceptions,
    required this.milestoneIdToDelete,
  });

  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final List<RecurringTaskException> recurringExceptions;
  final String milestoneIdToDelete;
}
