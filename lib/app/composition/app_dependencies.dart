import 'dart:async';

import '../../data/local/app_database.dart' as local;
import '../../data/repositories/drift_goal_repository.dart';
import '../../data/repositories/drift_milestone_repository.dart';
import '../../data/repositories/drift_planner_cleanup_repository.dart';
import '../../data/repositories/drift_recurring_task_repository.dart';
import '../../data/repositories/drift_task_repository.dart';
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

    final store = PlannerStore(
      cleanupRepository,
      goalRepository,
      milestoneRepository,
      taskRepository,
      recurringTaskRepository,
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
