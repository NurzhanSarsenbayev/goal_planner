import 'dart:async';

import 'package:flutter/material.dart';

import 'settings/app_language.dart';
import '../l10n/app_localizations.dart';
import '../features/recurring/presentation/recurring_rule_dialog_actions.dart';
import '../features/backup/presentation/backup_flow_actions.dart';
import '../features/goals/presentation/goal_dialog_actions.dart';
import '../features/tasks/presentation/task_dialog_actions.dart';
import '../features/reminders/task/application/task_reminder_lifecycle_service.dart';
import '../features/reminders/standalone/application/standalone_reminder_resync_service.dart';
import '../features/reminders/daily_review/application/daily_review_reminder_scheduler.dart';
import '../features/reminders/habit/application/habit_reminder_resync_service.dart';
import 'composition/app_dependencies.dart';
import 'navigation/app_navigation_actions.dart';
import 'navigation/main_tab_builder.dart';
import '../state/planner_store.dart';
import '../features/habits/application/habit_store.dart';
import '../features/reports/application/habit_report_loader.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final AppDependencies _dependencies;
  late final PlannerStore _store;
  late final HabitStore _habitStore;
  late final GoalDialogActions _goalDialogActions;
  late final TaskDialogActions _taskDialogActions;
  late final RecurringRuleDialogActions _recurringRuleDialogActions;
  late final AppNavigationActions _navigationActions;
  late final HabitReportLoader _habitReportLoader;
  late final BackupFlowActions _backupFlowActions;
  DateTime? _lastBackupAt;
  late final TaskReminderLifecycleService _taskReminderLifecycleService;
  late final StandaloneReminderResyncService _standaloneReminderResyncService;
  late final DailyReviewReminderScheduler _dailyReviewReminderScheduler;
  Timer? _dailyReviewReminderResyncDebounce;
  late final HabitReminderResyncService _habitReminderResyncService;
  Locale? _lastReminderTextsLocale;

  int _selectedIndex = 0;

  void _updateLastBackupAt(DateTime? backupAt) {
    if (!mounted) {
      return;
    }

    setState(() {
      _lastBackupAt = backupAt;
    });
  }

  Future<void> _initializeStoreAndReminders() async {
    await _store.initialize();

    try {
      await _taskReminderLifecycleService.initializeAndSyncTaskReminders(
        _store.tasks,
      );
    } catch (_) {
      // Reminder sync must not block app startup.
    }

    try {
      await _standaloneReminderResyncService.syncStandaloneReminders();
    } catch (_) {
      // Standalone reminder sync must not block app startup.
    }

    try {
      await _habitReminderResyncService.syncHabitReminders();
    } catch (_) {
      // Habit reminder sync must not block app startup.
    }

    try {
      await _dailyReviewReminderScheduler.syncDailyReviewReminder();
    } catch (_) {
      // Daily review reminder sync must not block app startup.
    }
  }

  Future<void> _showTestNotification() async {
    try {
      await _taskReminderLifecycleService.initializeNotifications();

      final granted = await _taskReminderLifecycleService
          .requestNotificationPermission();

      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.notificationPermissionDeniedMessage)),
        );
        return;
      }

      await _taskReminderLifecycleService.showTestNotification();

      if (!mounted) {
        return;
      }

      final updatedL10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(updatedL10n.notificationTestSentMessage)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationTestFailureMessage)),
      );
    }
  }

  void _updateLocalizedReminderNotificationTexts() {
    final l10n = AppLocalizations.of(context);

    _dependencies.reminderNotificationTexts.update(
      taskReminderBody: l10n.taskReminderNotificationBody,
      standaloneReminderBody: l10n.standaloneReminderNotificationBody,
      habitReminderBody: l10n.habitReminderNotificationBody,
      dailyReviewTitle: l10n.dailyReviewReminderNotificationTitle,
      dailyReviewBody: l10n.dailyReviewReminderNotificationBody,
      testNotificationTitle: l10n.notificationTestTitle,
      testNotificationBody: l10n.notificationTestBody,
      reminderChannelName: l10n.notificationReminderChannelName,
      reminderChannelDescription: l10n.notificationReminderChannelDescription,
      testChannelName: l10n.notificationTestChannelName,
      testChannelDescription: l10n.notificationTestChannelDescription,
    );
  }

  Future<void> _resyncRemindersAfterLocaleChange() async {
    if (!_store.isInitialized) {
      return;
    }

    try {
      await _taskReminderLifecycleService.syncTaskReminders(_store.tasks);
    } catch (_) {
      // Reminder localization resync must not block the app.
    }

    try {
      await _standaloneReminderResyncService.syncStandaloneReminders();
    } catch (_) {
      // Standalone reminder localization resync must not block the app.
    }

    try {
      await _habitReminderResyncService.syncHabitReminders();
    } catch (_) {
      // Habit reminder localization resync must not block the app.
    }

    try {
      await _dailyReviewReminderScheduler.syncDailyReviewReminder();
    } catch (_) {
      // Daily review reminder localization resync must not block the app.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentLocale = Localizations.localeOf(context);
    final previousLocale = _lastReminderTextsLocale;

    _updateLocalizedReminderNotificationTexts();

    if (previousLocale != null && previousLocale != currentLocale) {
      unawaited(_resyncRemindersAfterLocaleChange());
    }

    _lastReminderTextsLocale = currentLocale;
  }

  @override
  void initState() {
    super.initState();

    _dependencies = AppDependencies.create();
    _store = _dependencies.store;
    _habitStore = _dependencies.habitStore;
    _taskReminderLifecycleService = _dependencies.taskReminderLifecycleService;
    _standaloneReminderResyncService =
        _dependencies.standaloneReminderResyncService;
    _dailyReviewReminderScheduler = _dependencies.dailyReviewReminderScheduler;
    _habitReminderResyncService = _dependencies.habitReminderResyncService;
    _backupFlowActions = BackupFlowActions(
      backupFileExportService: _dependencies.backupFileExportService,
      backupFileStorage: _dependencies.backupFileStorage,
      backupRestoreService: _dependencies.backupRestoreService,
      store: _store,
      habitStore: _habitStore,
      taskReminderLifecycleService: _taskReminderLifecycleService,
      isMounted: () => mounted,
      onBackupStatusChanged: _updateLastBackupAt,
      standaloneReminderStore: _dependencies.standaloneReminderStore,
      standaloneReminderResyncService: _standaloneReminderResyncService,
      habitReminderResyncService: _habitReminderResyncService,
      dailyReviewReminderScheduler: _dailyReviewReminderScheduler,
      dailyReviewReminderSettingsStore:
          _dependencies.dailyReviewReminderSettingsStore,
    );

    unawaited(_backupFlowActions.loadBackupStatus());

    _habitReportLoader = HabitReportLoader(habitStore: _habitStore);

    _goalDialogActions = GoalDialogActions(store: _store);
    _taskDialogActions = TaskDialogActions(store: _store);
    _recurringRuleDialogActions = RecurringRuleDialogActions(store: _store);

    _navigationActions = AppNavigationActions(
      store: _store,
      taskDialogActions: _taskDialogActions,
      recurringRuleDialogActions: _recurringRuleDialogActions,
      habitReportLoader: _habitReportLoader,
      standaloneReminderStore: _dependencies.standaloneReminderStore,
      dailyReviewReminderSettingsStore:
          _dependencies.dailyReviewReminderSettingsStore,
      bodyWeightTrackingService: _dependencies.bodyWeightTrackingService,
      bodyMeasurementTrackingService:
          _dependencies.bodyMeasurementTrackingService,
    );

    _store.addListener(_onStoreChanged);
    _habitStore.addListener(_onStoreChanged);

    unawaited(_initializeStoreAndReminders());
    unawaited(_habitStore.initialize());
  }

  @override
  void dispose() {
    _dailyReviewReminderResyncDebounce?.cancel();

    _store.removeListener(_onStoreChanged);
    _habitStore.removeListener(_onStoreChanged);

    unawaited(_dependencies.dispose());

    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
    _scheduleDailyReviewReminderResync();
  }

  void _scheduleDailyReviewReminderResync() {
    _dailyReviewReminderResyncDebounce?.cancel();
    _dailyReviewReminderResyncDebounce = Timer(
      const Duration(milliseconds: 750),
      () {
        if (!mounted) {
          return;
        }

        unawaited(_syncDailyReviewReminderAfterStateChange());
      },
    );
  }

  Future<void> _syncDailyReviewReminderAfterStateChange() async {
    try {
      await _dailyReviewReminderScheduler.syncDailyReviewReminder();
    } catch (_) {
      // Daily review reminder sync must not block app state updates.
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  MainTabBuilder _buildMainTabBuilder() {
    return MainTabBuilder(
      store: _store,
      habitStore: _habitStore,
      bodyWeightTrackingService: _dependencies.bodyWeightTrackingService,
      bodyMeasurementTrackingService:
          _dependencies.bodyMeasurementTrackingService,
      goalDialogActions: _goalDialogActions,
      taskDialogActions: _taskDialogActions,
      recurringRuleDialogActions: _recurringRuleDialogActions,
      navigationActions: _navigationActions,
      selectedLanguage: widget.selectedLanguage,
      onLanguageChanged: widget.onLanguageChanged,
      onCreateBackup: () {
        return _backupFlowActions.createBackupFile(context);
      },
      onExportBackup: () {
        return _backupFlowActions.exportBackupFile(context);
      },
      onRestoreLatestBackup: () {
        return _backupFlowActions.restoreLatestBackupFile(context);
      },
      onRestoreExternalBackup: () {
        return _backupFlowActions.restoreExternalBackupFile(context);
      },
      lastBackupAt: _lastBackupAt,
      onOpenHabits: () {
        _onDestinationSelected(3);
      },
      onOpenStandaloneReminders: () {
        _navigationActions.openStandaloneReminders(context);
      },
      onOpenDailyReviewReminderSettings: () {
        _navigationActions.openDailyReviewReminderSettings(context);
      },
      onShowTestNotification: _showTestNotification,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainTabBuilder = _buildMainTabBuilder();
    final screens = mainTabBuilder.buildScreens(context);
    final isAppInitialized = _store.isInitialized && _habitStore.isInitialized;

    final l10n = AppLocalizations.of(context);
    final titles = [
      l10n.todayTab,
      l10n.goalsTab,
      l10n.calendarTab,
      l10n.habitsTab,
      l10n.moreTab,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
      body: isAppInitialized
          ? screens[_selectedIndex]
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.todayTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: l10n.goalsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.calendarTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.track_changes_outlined),
            selectedIcon: const Icon(Icons.track_changes),
            label: l10n.habitsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more),
            label: l10n.moreTab,
          ),
        ],
      ),
    );
  }
}
