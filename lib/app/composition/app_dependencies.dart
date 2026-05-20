import 'dart:async';

import '../../data/local/app_database.dart' as local;
import '../../data/repositories/drift_goal_repository.dart';
import '../../data/repositories/drift_milestone_repository.dart';
import '../../data/repositories/drift_planner_cleanup_repository.dart';
import '../../data/repositories/drift_recurring_task_repository.dart';
import '../../data/repositories/drift_task_repository.dart';
import '../../data/repositories/drift_habit_repository.dart';
import '../../data/repositories/drift_planner_backup_restore_repository.dart';
import '../../features/backup/application/planner_backup_restore_service.dart';
import '../../features/backup/application/planner_backup_validator.dart';
import '../../features/planner/application/planner_initialization_service.dart';
import '../../features/backup/application/planner_backup_export_service.dart';
import '../../features/backup/application/planner_backup_file_export_service.dart';
import '../../features/backup/application/planner_backup_file_storage.dart';
import '../../features/recurring/application/recurring_occurrence_store_coordinator.dart';
import '../../features/recurring/application/recurring_rule_store_coordinator.dart';
import '../../features/goals/application/goal_store_coordinator.dart';
import '../../features/milestones/application/milestone_store_coordinator.dart';
import '../../features/tasks/application/task_store_coordinator.dart';
import '../../features/habits/application/habit_store.dart';
import '../../features/reminders/application/local_notification_service.dart';
import '../../state/planner_store.dart';

class AppDependencies {
  AppDependencies._({
    required local.AppDatabase database,
    required this.store,
    required this.habitStore,
    required this.backupFileExportService,
    required this.backupFileStorage,
    required this.backupRestoreService,
    required this.localNotificationService,
  }) : _database = database;

  factory AppDependencies.create() {
    final database = local.AppDatabase();

    final cleanupRepository = DriftPlannerCleanupRepository(database);
    final goalRepository = DriftGoalRepository(database);
    final milestoneRepository = DriftMilestoneRepository(database);
    final taskRepository = DriftTaskRepository(database);
    final recurringTaskRepository = DriftRecurringTaskRepository(database);
    final habitRepository = DriftHabitRepository(database);
    final backupRestoreRepository = DriftPlannerBackupRestoreRepository(
      database,
    );

    final backupExportService = PlannerBackupExportService(
      goalRepository: goalRepository,
      milestoneRepository: milestoneRepository,
      taskRepository: taskRepository,
      recurringTaskRepository: recurringTaskRepository,
      habitRepository: habitRepository,
    );

    const backupFileStorage = PlannerBackupFileStorage();

    final backupFileExportService = PlannerBackupFileExportService(
      exportService: backupExportService,
      fileStorage: backupFileStorage,
    );

    final backupRestoreService = PlannerBackupRestoreService(
      fileStorage: backupFileStorage,
      validator: const PlannerBackupValidator(),
      restoreRepository: backupRestoreRepository,
    );

    final goalStoreCoordinator = GoalStoreCoordinator(
      goalRepository: goalRepository,
      cleanupRepository: cleanupRepository,
    );

    final milestoneStoreCoordinator = MilestoneStoreCoordinator(
      milestoneRepository: milestoneRepository,
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

    final taskStoreCoordinator = TaskStoreCoordinator(
      taskRepository: taskRepository,
      recurringOccurrenceStoreCoordinator: recurringOccurrenceStoreCoordinator,
    );

    final store = PlannerStore(
      goalStoreCoordinator: goalStoreCoordinator,
      milestoneStoreCoordinator: milestoneStoreCoordinator,
      taskStoreCoordinator: taskStoreCoordinator,
      initializationService: initializationService,
      recurringRuleStoreCoordinator: recurringRuleStoreCoordinator,
      recurringOccurrenceStoreCoordinator: recurringOccurrenceStoreCoordinator,
    );

    final habitStore = HabitStore(habitRepository: habitRepository);

    final localNotificationService = LocalNotificationService();

    return AppDependencies._(
      database: database,
      store: store,
      habitStore: habitStore,
      backupFileExportService: backupFileExportService,
      backupFileStorage: backupFileStorage,
      backupRestoreService: backupRestoreService,
      localNotificationService: localNotificationService,
    );
  }

  final local.AppDatabase _database;
  final PlannerStore store;
  final HabitStore habitStore;
  final PlannerBackupFileExportService backupFileExportService;
  final PlannerBackupFileStorage backupFileStorage;
  final PlannerBackupRestoreService backupRestoreService;
  final LocalNotificationService localNotificationService;

  Future<void> dispose() async {
    store.dispose();
    habitStore.dispose();
    await _database.close();
  }
}
