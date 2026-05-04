import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import '../../planner/application/planner_cleanup_repository.dart';
import 'milestone_application_service.dart';
import 'milestone_repository.dart';

class MilestoneStoreMutation {
  const MilestoneStoreMutation({
    required this.milestones,
    required this.tasks,
    required this.recurringRules,
    required this.recurringExceptions,
    required this.persistOperation,
  });

  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final List<RecurringTaskException> recurringExceptions;
  final Future<void> Function() persistOperation;
}

class MilestoneStoreCoordinator {
  MilestoneStoreCoordinator({
    required MilestoneRepository milestoneRepository,
    required PlannerCleanupRepository cleanupRepository,
    MilestoneApplicationService? milestoneApplicationService,
  }) : _milestoneRepository = milestoneRepository,
       _cleanupRepository = cleanupRepository,
       _milestoneApplicationService =
           milestoneApplicationService ?? const MilestoneApplicationService();

  final MilestoneRepository _milestoneRepository;
  final PlannerCleanupRepository _cleanupRepository;
  final MilestoneApplicationService _milestoneApplicationService;

  MilestoneStoreMutation? addMilestone({
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
    required Milestone milestone,
  }) {
    final result = _milestoneApplicationService.addMilestone(
      milestones: milestones,
      milestone: milestone,
    );

    final milestoneToPersist = result.milestoneToPersist;

    if (milestoneToPersist == null) {
      return null;
    }

    return MilestoneStoreMutation(
      milestones: result.milestones,
      tasks: tasks,
      recurringRules: recurringRules,
      recurringExceptions: recurringExceptions,
      persistOperation: () =>
          _milestoneRepository.saveMilestone(milestoneToPersist),
    );
  }

  MilestoneStoreMutation? updateMilestone({
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
    required String milestoneId,
    required String title,
    required String description,
  }) {
    final result = _milestoneApplicationService.updateMilestoneDetails(
      milestones: milestones,
      milestoneId: milestoneId,
      title: title,
      description: description,
    );

    final milestoneToPersist = result.milestoneToPersist;

    if (milestoneToPersist == null) {
      return null;
    }

    return MilestoneStoreMutation(
      milestones: result.milestones,
      tasks: tasks,
      recurringRules: recurringRules,
      recurringExceptions: recurringExceptions,
      persistOperation: () =>
          _milestoneRepository.saveMilestone(milestoneToPersist),
    );
  }

  MilestoneStoreMutation deleteMilestoneAndMoveTasksToDirect({
    required String milestoneId,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
  }) {
    final result = _milestoneApplicationService
        .deleteMilestoneAndMoveTasksToDirect(
          milestoneId: milestoneId,
          milestones: milestones,
          tasks: tasks,
          recurringRules: recurringRules,
        );

    return MilestoneStoreMutation(
      milestones: result.milestones,
      tasks: result.tasks,
      recurringRules: result.recurringRules,
      recurringExceptions: recurringExceptions,
      persistOperation: () => _cleanupRepository
          .deleteMilestoneAndMoveTasksToDirect(result.milestoneIdToDelete),
    );
  }

  MilestoneStoreMutation deleteMilestoneWithTasks({
    required String milestoneId,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required List<RecurringTaskRule> recurringRules,
    required List<RecurringTaskException> recurringExceptions,
  }) {
    final result = _milestoneApplicationService.deleteMilestoneWithTasks(
      milestoneId: milestoneId,
      milestones: milestones,
      tasks: tasks,
      recurringRules: recurringRules,
      recurringExceptions: recurringExceptions,
    );

    return MilestoneStoreMutation(
      milestones: result.milestones,
      tasks: result.tasks,
      recurringRules: result.recurringRules,
      recurringExceptions: result.recurringExceptions,
      persistOperation: () => _cleanupRepository.deleteMilestoneWithTasks(
        result.milestoneIdToDelete,
      ),
    );
  }
}
