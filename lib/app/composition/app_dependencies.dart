import 'dart:async';

import '../../data/local/app_database.dart' as local;
import '../../data/repositories/drift_goal_repository.dart';
import '../../data/repositories/drift_milestone_repository.dart';
import '../../data/repositories/drift_planner_cleanup_repository.dart';
import '../../data/repositories/drift_recurring_task_repository.dart';
import '../../data/repositories/drift_task_repository.dart';
import '../../features/planner/application/planner_initialization_service.dart';
import '../../features/recurring/application/recurring_occurrence_store_coordinator.dart';
import '../../features/recurring/application/recurring_rule_store_coordinator.dart';
import '../../features/goals/application/goal_store_coordinator.dart';
import '../../state/planner_store.dart';

class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.cleanupRepository,
    required this.goalRepository,
    required this.milestoneRepository,
    required this.taskRepository,
    required this.recurringTaskRepository,
    required this.store,
  });

  factory AppDependencies.create() {
    final database = local.AppDatabase();

    final cleanupRepository = DriftPlannerCleanupRepository(database);
    final goalRepository = DriftGoalRepository(database);
    final milestoneRepository = DriftMilestoneRepository(database);
    final taskRepository = DriftTaskRepository(database);
    final recurringTaskRepository = DriftRecurringTaskRepository(database);
    final goalStoreCoordinator = GoalStoreCoordinator(
      goalRepository: goalRepository,
      cleanupRepository: cleanupRepository,
    );

    final initializationService = PlannerInitializationService(
      goalRepository: goalRepository,
      milestoneRepository: milestoneRepository,
      taskRepository: taskRepository,
      recurringTaskRepository: recurringTaskRepository,
    );

    final recurringRuleStoreCoordinator = RecurringRuleStoreCoordinator(
      recurringTaskRepository: recurringTaskRepository,
    );

    final recurringOccurrenceStoreCoordinator =
        RecurringOccurrenceStoreCoordinator(
          recurringTaskRepository: recurringTaskRepository,
        );

    final store = PlannerStore(
      cleanupRepository: cleanupRepository,
      goalStoreCoordinator: goalStoreCoordinator,
      milestoneRepository: milestoneRepository,
      taskRepository: taskRepository,
      initializationService: initializationService,
      recurringRuleStoreCoordinator: recurringRuleStoreCoordinator,
      recurringOccurrenceStoreCoordinator: recurringOccurrenceStoreCoordinator,
    );

    return AppDependencies._(
      database: database,
      cleanupRepository: cleanupRepository,
      goalRepository: goalRepository,
      milestoneRepository: milestoneRepository,
      taskRepository: taskRepository,
      recurringTaskRepository: recurringTaskRepository,
      store: store,
    );
  }

  final local.AppDatabase database;
  final DriftPlannerCleanupRepository cleanupRepository;
  final DriftGoalRepository goalRepository;
  final DriftMilestoneRepository milestoneRepository;
  final DriftTaskRepository taskRepository;
  final DriftRecurringTaskRepository recurringTaskRepository;
  final PlannerStore store;

  Future<void> dispose() async {
    store.dispose();
    await database.close();
  }
}
