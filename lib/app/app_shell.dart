import 'dart:async';

import 'package:flutter/material.dart';

import 'actions/recurring_rule_dialog_actions.dart';
import 'actions/goal_dialog_actions.dart';
import 'actions/task_dialog_actions.dart';
import 'composition/app_dependencies.dart';
import 'navigation/app_navigation_actions.dart';
import '../screens/calendar_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/more_screen.dart';
import '../screens/today_screen.dart';
import '../state/planner_store.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final AppDependencies _dependencies;
  late final PlannerStore _store;
  late final GoalDialogActions _goalDialogActions;
  late final TaskDialogActions _taskDialogActions;
  late final RecurringRuleDialogActions _recurringRuleDialogActions;
  late final AppNavigationActions _navigationActions;

  int _selectedIndex = 0;

  static const List<String> _titles = ['Today', 'Goals', 'Calendar', 'More'];

  @override
  void initState() {
    super.initState();

    _dependencies = AppDependencies.create();
    _store = _dependencies.store;

    _goalDialogActions = GoalDialogActions(store: _store);
    _taskDialogActions = TaskDialogActions(store: _store);
    _recurringRuleDialogActions = RecurringRuleDialogActions(store: _store);

    _navigationActions = AppNavigationActions(
      store: _store,
      taskDialogActions: _taskDialogActions,
      recurringRuleDialogActions: _recurringRuleDialogActions,
    );

    _store.addListener(_onStoreChanged);
    unawaited(_store.initialize());
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
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

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        goals: _store.goals,
        tasks: _store.tasks,
        onToggleTaskCompleted: _store.toggleTaskCompleted,
        onCompleteTaskOnDate: _store.completeTaskOnDate,
        onEditTask: (task) {
          _taskDialogActions.showEditDialog(context, task);
        },
        onAttachTaskToGoal: (task) {
          _taskDialogActions.showAttachToGoalDialog(context, task);
        },
        onAddTask: () {
          _taskDialogActions.showAddForTodayDialog(context);
        },
        onDetachTaskFromGoal: _store.detachTaskFromGoal,
        onRemoveTaskFromToday: _store.unscheduleTask,
        onScheduleTaskForDate: _store.scheduleTaskForDate,
        onDeleteTask: _store.deleteTask,
        onAddRecurringTask: () {
          _recurringRuleDialogActions.showAddDialog(context);
        },
      ),
      GoalsScreen(
        goals: _store.goals,
        tasks: _store.tasks,
        onGoalSelected: (goal) {
          _navigationActions.openGoalDetails(context, goal);
        },
        onEditGoal: (goal) {
          _goalDialogActions.showEditDialog(context, goal);
        },
        onDeleteGoal: (goal) {
          _goalDialogActions.showDeleteDialog(context, goal);
        },
        onAddGoal: () {
          _goalDialogActions.showAddDialog(context);
        },
      ),
      CalendarScreen(
        goals: _store.goals,
        tasks: _store.tasks,
        onToggleTaskCompleted: _store.toggleTaskCompleted,
        onCompleteTaskOnDate: _store.completeTaskOnDate,
        onEditTask: (task) {
          _taskDialogActions.showEditDialog(context, task);
        },
        onAddTaskForDate: (date) {
          _taskDialogActions.showAddForDateDialog(context, date);
        },
        onScheduleTaskForDate: _store.scheduleTaskForDate,
        onRemoveTaskFromSchedule: _store.unscheduleTask,
        onDeleteTask: _store.deleteTask,
        onEnsureRecurringTasksForMonth:
            _store.ensureRecurringTaskOccurrencesForMonth,
        onAddRecurringTaskForDate: (date) {
          _recurringRuleDialogActions.showAddDialog(context, startDate: date);
        },
      ),
      MoreScreen(
        onOpenAllTasks: () {
          _navigationActions.openAllTasks(context);
        },
        onOpenReports: () {
          _navigationActions.openReports(context);
        },
        onOpenRecurringTasks: () {
          _navigationActions.openRecurringTasks(context);
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _store.isInitialized
          ? screens[_selectedIndex]
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
