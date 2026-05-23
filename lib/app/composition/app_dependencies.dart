import 'dart:async';

import '../../data/local/app_database.dart' as local;
import '../../data/repositories/drift_goal_repository.dart';
import '../../data/repositories/drift_milestone_repository.dart';
import '../../data/repositories/drift_planner_cleanup_repository.dart';
import '../../data/repositories/drift_recurring_task_repository.dart';
import '../../data/repositories/drift_task_repository.dart';
import '../../data/repositories/drift_habit_repository.dart';
import '../../data/repositories/drift_planner_backup_restore_repository.dart';
import '../../data/repositories/drift_standalone_reminder_repository.dart';
import '../../data/repositories/drift_daily_review_reminder_settings_repository.dart';
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
import '../../features/reminders/application/task_reminder_application_service.dart';
import '../../features/reminders/application/task_reminder_scheduler.dart';
import '../../features/reminders/application/task_reminder_resync_service.dart';
import '../../features/reminders/application/task_reminder_lifecycle_service.dart';
import '../../features/reminders/application/standalone_reminder_application_service.dart';
import '../../features/reminders/application/standalone_reminder_scheduler.dart';
import '../../features/reminders/application/standalone_reminder_store.dart';
import '../../features/reminders/application/standalone_reminder_resync_service.dart';
import '../../features/reminders/application/daily_review_pending_checker.dart';
import '../../features/reminders/application/daily_review_reminder_scheduler.dart';
import '../../features/reminders/application/daily_review_reminder_settings_store.dart';
import '../../state/planner_store.dart';

class AppDependencies {
  AppDependencies._({
    required local.AppDatabase database,
    required this.store,
    required this.habitStore,
    required this.backupFileExportService,
    required this.backupFileStorage,
    required this.backupRestoreService,
    required this.taskReminderLifecycleService,
    required this.standaloneReminderApplicationService,
    required this.standaloneReminderStore,
    required this.standaloneReminderResyncService,
    required this.dailyReviewReminderScheduler,
    required this.dailyReviewReminderSettingsStore,
  }) : _database = database;

  factory AppDependencies.create() {
    final database = local.AppDatabase();

    final cleanupRepository = DriftPlannerCleanupRepository(database);
    final goalRepository = DriftGoalRepository(database);
    final milestoneRepository = DriftMilestoneRepository(database);
    final taskRepository = DriftTaskRepository(database);
    final recurringTaskRepository = DriftRecurringTaskRepository(database);
    final habitRepository = DriftHabitRepository(database);
    final standaloneReminderRepository = DriftStandaloneReminderRepository(
      database,
    );
    final dailyReviewReminderSettingsRepository =
        DriftDailyReviewReminderSettingsRepository(database);
    final backupRestoreRepository = DriftPlannerBackupRestoreRepository(
      database,
    );

    final dailyReviewPendingChecker = DailyReviewPendingChecker(
      taskRepository: taskRepository,
      habitRepository: habitRepository,
    );

    final backupExportService = PlannerBackupExportService(
      goalRepository: goalRepository,
      milestoneRepository: milestoneRepository,
      taskRepository: taskRepository,
      recurringTaskRepository: recurringTaskRepository,
      habitRepository: habitRepository,
      standaloneReminderRepository: standaloneReminderRepository,
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

    final localNotificationService = LocalNotificationService();

    final dailyReviewReminderScheduler = DailyReviewReminderScheduler(
      settingsRepository: dailyReviewReminderSettingsRepository,
      pendingChecker: dailyReviewPendingChecker,
      notifications: localNotificationService,
    );

    final taskReminderScheduler = TaskReminderScheduler(
      notifications: localNotificationService,
    );

    final standaloneReminderScheduler = StandaloneReminderScheduler(
      notifications: localNotificationService,
    );

    final standaloneReminderResyncService = StandaloneReminderResyncService(
      repository: standaloneReminderRepository,
      scheduler: standaloneReminderScheduler,
    );

    final standaloneReminderApplicationService =
        StandaloneReminderApplicationService(
          repository: standaloneReminderRepository,
          scheduler: standaloneReminderScheduler,
        );

    final standaloneReminderStore = StandaloneReminderStore(
      applicationService: standaloneReminderApplicationService,
    );

    final taskReminderApplicationService = TaskReminderApplicationService(
      taskReminderScheduler: taskReminderScheduler,
    );

    final taskReminderResyncService = TaskReminderResyncService(
      taskReminderScheduler: taskReminderScheduler,
    );

    final taskReminderLifecycleService = TaskReminderLifecycleService(
      notifications: localNotificationService,
      taskReminderResyncService: taskReminderResyncService,
    );

    final dailyReviewReminderSettingsStore = DailyReviewReminderSettingsStore(
      settingsRepository: dailyReviewReminderSettingsRepository,
      syncDailyReviewReminder:
          dailyReviewReminderScheduler.syncDailyReviewReminder,
    );

    final taskStoreCoordinator = TaskStoreCoordinator(
      taskRepository: taskRepository,
      recurringOccurrenceStoreCoordinator: recurringOccurrenceStoreCoordinator,
      taskReminderApplicationService: taskReminderApplicationService,
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

    return AppDependencies._(
      database: database,
      store: store,
      habitStore: habitStore,
      backupFileExportService: backupFileExportService,
      backupFileStorage: backupFileStorage,
      backupRestoreService: backupRestoreService,
      taskReminderLifecycleService: taskReminderLifecycleService,
      standaloneReminderApplicationService:
          standaloneReminderApplicationService,
      standaloneReminderStore: standaloneReminderStore,
      standaloneReminderResyncService: standaloneReminderResyncService,
      dailyReviewReminderScheduler: dailyReviewReminderScheduler,
      dailyReviewReminderSettingsStore: dailyReviewReminderSettingsStore,
    );
  }

  final local.AppDatabase _database;
  final PlannerStore store;
  final HabitStore habitStore;
  final PlannerBackupFileExportService backupFileExportService;
  final PlannerBackupFileStorage backupFileStorage;
  final PlannerBackupRestoreService backupRestoreService;
  final TaskReminderLifecycleService taskReminderLifecycleService;
  final StandaloneReminderApplicationService
  standaloneReminderApplicationService;
  final StandaloneReminderStore standaloneReminderStore;
  final StandaloneReminderResyncService standaloneReminderResyncService;
  final DailyReviewReminderScheduler dailyReviewReminderScheduler;
  final DailyReviewReminderSettingsStore dailyReviewReminderSettingsStore;

  Future<void> dispose() async {
    store.dispose();
    habitStore.dispose();
    standaloneReminderStore.dispose();
    dailyReviewReminderSettingsStore.dispose();
    await _database.close();
  }
}
