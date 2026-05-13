import 'dart:async';

import 'package:flutter/material.dart';

import 'settings/app_language.dart';
import '../l10n/app_localizations.dart';
import '../features/backup/application/planner_backup_file_export_service.dart';
import '../features/backup/application/planner_backup_file_storage.dart';
import '../features/recurring/presentation/recurring_rule_dialog_actions.dart';
import '../features/goals/presentation/goal_dialog_actions.dart';
import '../features/tasks/presentation/task_dialog_actions.dart';
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
  DateTime? _lastBackupAt;

  int _selectedIndex = 0;

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

  @override
  void initState() {
    super.initState();

    _dependencies = AppDependencies.create();
    _store = _dependencies.store;
    _habitStore = _dependencies.habitStore;
    _backupFileExportService = _dependencies.backupFileExportService;
    _backupFileStorage = _dependencies.backupFileStorage;

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

    unawaited(_store.initialize());
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
      lastBackupAt: _lastBackupAt,
      onOpenHabits: () {
        _onDestinationSelected(3);
      },
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
