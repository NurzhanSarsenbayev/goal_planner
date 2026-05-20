import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'settings/app_language.dart';
import '../l10n/app_localizations.dart';
import '../features/backup/application/planner_backup_file_export_service.dart';
import '../features/backup/application/planner_backup_file_storage.dart';
import '../features/backup/application/planner_backup_restore_service.dart';
import '../features/recurring/presentation/recurring_rule_dialog_actions.dart';
import '../features/goals/presentation/goal_dialog_actions.dart';
import '../features/tasks/presentation/task_dialog_actions.dart';
import '../features/reminders/application/local_notification_service.dart';
import '../features/reminders/application/task_reminder_resync_service.dart';
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
  late final PlannerBackupFileExportService _backupFileExportService;
  late final PlannerBackupFileStorage _backupFileStorage;
  late final PlannerBackupRestoreService _backupRestoreService;
  DateTime? _lastBackupAt;
  late final LocalNotificationService _localNotificationService;
  late final TaskReminderResyncService _taskReminderResyncService;

  int _selectedIndex = 0;

  Future<void> _exportBackupFile() async {
    try {
      final file = await _backupFileExportService.createBackupFile();
      final latestBackup = await _backupFileStorage.readBackup(file);

      if (!mounted) {
        return;
      }

      setState(() {
        _lastBackupAt = latestBackup.exportedAt;
      });

      final l10n = AppLocalizations.of(context);

      final result = await SharePlus.instance.share(
        ShareParams(
          title: l10n.backupExportShareTitle,
          subject: l10n.backupExportShareTitle,
          text: l10n.backupExportShareText,
          files: [XFile(file.path)],
        ),
      );

      if (!mounted) {
        return;
      }

      if (result.status == ShareResultStatus.dismissed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupExportDismissedMessage)),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportSuccessMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportFailureMessage)));
    }
  }

  Future<void> _createBackupFile() async {
    try {
      final file = await _backupFileExportService.createBackupFile();

      final latestBackup = await _backupFileStorage.readBackup(file);

      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      setState(() {
        _lastBackupAt = latestBackup.exportedAt;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupCreateSuccessMessage(file.path))),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupCreateFailureMessage)));
    }
  }

  Future<void> _restoreLatestBackupFile() async {
    try {
      final latestBackupFile = await _backupFileStorage.findLatestBackupFile();

      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      if (latestBackupFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupRestoreNoLocalBackupMessage)),
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context);

          return AlertDialog(
            title: Text(l10n.backupRestoreConfirmTitle),
            content: Text(l10n.backupRestoreConfirmMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(l10n.backupRestoreConfirmAction),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmed != true) {
        return;
      }

      final result = await _backupRestoreService.restoreFromFile(
        latestBackupFile,
      );

      await _store.reload();
      await _habitStore.reload();

      if (!mounted) {
        return;
      }

      setState(() {
        _lastBackupAt = result.exportedAt;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupRestoreSuccessMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupRestoreFailureMessage)));
    }
  }

  Future<void> _restoreExternalBackupFile() async {
    try {
      const backupFileType = XTypeGroup(
        label: 'Goal Planner backup',
        extensions: ['json'],
        mimeTypes: ['application/json'],
      );

      final pickedFile = await openFile(acceptedTypeGroups: [backupFileType]);

      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupRestorePickCancelledMessage)),
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context);

          return AlertDialog(
            title: Text(l10n.backupRestoreConfirmTitle),
            content: Text(l10n.backupRestoreExternalConfirmMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(l10n.backupRestoreConfirmAction),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmed != true) {
        return;
      }

      final result = await _backupRestoreService.restoreFromFile(
        File(pickedFile.path),
      );

      await _store.reload();
      await _habitStore.reload();

      if (!mounted) {
        return;
      }

      setState(() {
        _lastBackupAt = result.exportedAt;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupRestoreSuccessMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupRestoreFailureMessage)));
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      await _localNotificationService.initialize();
      await _localNotificationService.requestTaskReminderPermissions();
    } catch (_) {
      // Notification setup must not block app startup.
    }
  }

  Future<void> _initializeStoreAndReminders() async {
    await _store.initialize();

    try {
      await _initializeNotifications();
      await _taskReminderResyncService.syncTaskReminders(_store.tasks);
    } catch (_) {
      // Reminder sync must not block app startup.
    }
  }

  Future<void> _showTestNotification() async {
    try {
      await _localNotificationService.initialize();

      final granted = await _localNotificationService
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

      await _localNotificationService.showTestNotification();

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

  @override
  void initState() {
    super.initState();

    _dependencies = AppDependencies.create();
    _store = _dependencies.store;
    _habitStore = _dependencies.habitStore;
    _backupFileExportService = _dependencies.backupFileExportService;
    _backupFileStorage = _dependencies.backupFileStorage;
    _backupRestoreService = _dependencies.backupRestoreService;
    _localNotificationService = _dependencies.localNotificationService;
    _taskReminderResyncService = _dependencies.taskReminderResyncService;

    unawaited(_loadBackupStatus());

    _habitReportLoader = HabitReportLoader(habitStore: _habitStore);

    _goalDialogActions = GoalDialogActions(store: _store);
    _taskDialogActions = TaskDialogActions(store: _store);
    _recurringRuleDialogActions = RecurringRuleDialogActions(store: _store);

    _navigationActions = AppNavigationActions(
      store: _store,
      taskDialogActions: _taskDialogActions,
      recurringRuleDialogActions: _recurringRuleDialogActions,
      habitReportLoader: _habitReportLoader,
    );

    _store.addListener(_onStoreChanged);
    _habitStore.addListener(_onStoreChanged);

    unawaited(_initializeStoreAndReminders());
    unawaited(_habitStore.initialize());
  }

  Future<void> _loadBackupStatus() async {
    try {
      final latestBackup = await _backupFileStorage.readLatestBackup();

      if (!mounted) {
        return;
      }

      setState(() {
        _lastBackupAt = latestBackup?.exportedAt;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _lastBackupAt = null;
      });
    }
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _habitStore.removeListener(_onStoreChanged);

    unawaited(_dependencies.dispose());

    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
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
      goalDialogActions: _goalDialogActions,
      taskDialogActions: _taskDialogActions,
      recurringRuleDialogActions: _recurringRuleDialogActions,
      navigationActions: _navigationActions,
      selectedLanguage: widget.selectedLanguage,
      onLanguageChanged: widget.onLanguageChanged,
      onCreateBackup: _createBackupFile,
      onExportBackup: _exportBackupFile,
      onRestoreLatestBackup: _restoreLatestBackupFile,
      onRestoreExternalBackup: _restoreExternalBackupFile,
      lastBackupAt: _lastBackupAt,
      onOpenHabits: () {
        _onDestinationSelected(3);
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
