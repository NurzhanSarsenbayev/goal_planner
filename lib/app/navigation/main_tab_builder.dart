import 'package:flutter/material.dart';

import '../../screens/calendar_screen.dart';
import '../../screens/goals_screen.dart';
import '../../screens/more_screen.dart';
import '../../screens/today_screen.dart';
import '../../state/planner_store.dart';
import '../actions/goal_dialog_actions.dart';
import '../actions/recurring_rule_dialog_actions.dart';
import '../actions/task_dialog_actions.dart';
import 'app_navigation_actions.dart';

class MainTabBuilder {
  const MainTabBuilder({
    required PlannerStore store,
    required GoalDialogActions goalDialogActions,
    required TaskDialogActions taskDialogActions,
    required RecurringRuleDialogActions recurringRuleDialogActions,
    required AppNavigationActions navigationActions,
  }) : _store = store,
       _goalDialogActions = goalDialogActions,
       _taskDialogActions = taskDialogActions,
       _recurringRuleDialogActions = recurringRuleDialogActions,
       _navigationActions = navigationActions;

  final PlannerStore _store;
  final GoalDialogActions _goalDialogActions;
  final TaskDialogActions _taskDialogActions;
  final RecurringRuleDialogActions _recurringRuleDialogActions;
  final AppNavigationActions _navigationActions;

  List<Widget> buildScreens(BuildContext context) {
    return [
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
  }
}
