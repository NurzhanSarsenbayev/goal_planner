import 'package:flutter/material.dart';

import '../settings/app_language.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/today/presentation/screens/today_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import 'screens/more_screen.dart';
import '../../state/planner_store.dart';
import '../../features/goals/presentation/goal_dialog_actions.dart';
import '../../features/recurring/presentation/recurring_rule_dialog_actions.dart';
import '../../features/tasks/presentation/task_dialog_actions.dart';
import '../../features/habits/application/habit_store.dart';
import '../../features/habits/presentation/screens/habits_screen.dart';
import 'app_navigation_actions.dart';

class MainTabBuilder {
  const MainTabBuilder({
    required PlannerStore store,
    required HabitStore habitStore,
    required Future<void> Function() onCreateBackup,
    required GoalDialogActions goalDialogActions,
    required TaskDialogActions taskDialogActions,
    required RecurringRuleDialogActions recurringRuleDialogActions,
    required AppNavigationActions navigationActions,
    required AppLanguage selectedLanguage,
    required ValueChanged<AppLanguage> onLanguageChanged,
    required VoidCallback onOpenHabits,
  }) : _store = store,
       _habitStore = habitStore,
       _onCreateBackup = onCreateBackup,
       _onOpenHabits = onOpenHabits,
       _goalDialogActions = goalDialogActions,
       _taskDialogActions = taskDialogActions,
       _recurringRuleDialogActions = recurringRuleDialogActions,
       _navigationActions = navigationActions,
       _selectedLanguage = selectedLanguage,
       _onLanguageChanged = onLanguageChanged;

  final PlannerStore _store;
  final HabitStore _habitStore;
  final Future<void> Function() _onCreateBackup;
  final GoalDialogActions _goalDialogActions;
  final TaskDialogActions _taskDialogActions;
  final RecurringRuleDialogActions _recurringRuleDialogActions;
  final AppNavigationActions _navigationActions;
  final AppLanguage _selectedLanguage;
  final ValueChanged<AppLanguage> _onLanguageChanged;
  final VoidCallback _onOpenHabits;

  List<Widget> buildScreens(BuildContext context) {
    return [
      TodayScreen(
        goals: _store.goals,
        tasks: _store.tasks,
        habitSummary: _habitStore.todaySummary,
        onOpenHabits: _onOpenHabits,
        onToggleTaskCompleted: _store.toggleTaskCompleted,
        onCompleteTaskOnDate: _store.completeTaskOnDate,
        onEditTask: (task) {
          _taskDialogActions.showEditDialog(context, task);
        },
        onAttachTaskToGoal: (task) {
          _taskDialogActions.showAttachToGoalDialog(context, task);
        },
        onDetachTaskFromGoal: _store.detachTaskFromGoal,
        onRemoveTaskFromToday: _store.unscheduleTask,
        onScheduleTaskForDate: _store.scheduleTaskForDate,
        onDeleteTask: _store.deleteTask,
        onAddTask: () {
          _taskDialogActions.showAddForTodayDialog(context);
        },
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
        onScheduleTaskForDate: _store.scheduleTaskForDate,
        onRemoveTaskFromSchedule: _store.unscheduleTask,
        onDeleteTask: _store.deleteTask,
        onAddTaskForDate: (date) {
          _taskDialogActions.showAddForDateDialog(context, date);
        },
        onEnsureRecurringTasksForMonth:
            _store.ensureRecurringTaskOccurrencesForMonth,
        onAddRecurringTaskForDate: (date) {
          _recurringRuleDialogActions.showAddDialog(context, startDate: date);
        },
      ),
      HabitsScreen(habitStore: _habitStore),
      MoreScreen(
        selectedLanguage: _selectedLanguage,
        onLanguageChanged: _onLanguageChanged,
        onCreateBackup: _onCreateBackup,
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
  }
}
