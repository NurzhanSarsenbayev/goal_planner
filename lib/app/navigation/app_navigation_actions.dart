import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../features/goals/presentation/screens/goal_details_screen.dart';
import '../../features/tasks/presentation/screens/all_tasks_screen.dart';
import '../../features/recurring/presentation/screens/recurring_tasks_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../state/planner_store.dart';
import '../../features/recurring/presentation/recurring_rule_dialog_actions.dart';
import '../../features/tasks/presentation/task_dialog_actions.dart';
import '../../features/reports/application/habit_report_loader.dart';

class AppNavigationActions {
  const AppNavigationActions({
    required PlannerStore store,
    required TaskDialogActions taskDialogActions,
    required RecurringRuleDialogActions recurringRuleDialogActions,
    required HabitReportLoader habitReportLoader,
  }) : _store = store,
       _taskDialogActions = taskDialogActions,
       _habitReportLoader = habitReportLoader,
       _recurringRuleDialogActions = recurringRuleDialogActions;

  final PlannerStore _store;
  final HabitReportLoader _habitReportLoader;
  final TaskDialogActions _taskDialogActions;
  final RecurringRuleDialogActions _recurringRuleDialogActions;

  void openAllTasks(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AnimatedBuilder(
            animation: _store,
            builder: (context, _) {
              return AllTasksScreen(
                goals: _store.goals,
                milestones: _store.milestones,
                tasks: _store.tasks,
                recurringRules: _store.recurringRules,
                onToggleTaskCompleted: _store.toggleTaskCompleted,
                onTaskUpdated: _store.updateTask,
                onTaskAttachedToGoal: _store.attachTaskToGoal,
                onTaskDetachedFromGoal: _store.detachTaskFromGoal,
                onDeleteTask: _store.deleteTask,
                onScheduleTaskForToday: _store.scheduleTaskForToday,
                onScheduleTaskForDate: _store.scheduleTaskForDate,
                onCompleteTaskOnDate: _store.completeTaskOnDate,
              );
            },
          );
        },
      ),
    );
  }

  void openReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AnimatedBuilder(
            animation: _store,
            builder: (context, _) {
              return ReportsScreen(
                goals: _store.goals,
                tasks: _store.tasks,
                habitReportLoader: _habitReportLoader,
                onToggleTaskCompleted: _store.toggleTaskCompleted,
                onEditTask: (task) {
                  _taskDialogActions.showEditDialog(context, task);
                },
                onDeleteTask: _store.deleteTask,
              );
            },
          );
        },
      ),
    );
  }

  void openRecurringTasks(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AnimatedBuilder(
            animation: _store,
            builder: (context, _) {
              return RecurringTasksScreen(
                rules: _store.recurringRules,
                onAddRule: () {
                  _recurringRuleDialogActions.showAddDialog(context);
                },
                onEditRule: (rule) {
                  _recurringRuleDialogActions.showEditDialog(context, rule);
                },
                onRuleActiveChanged: (rule, isActive) {
                  _store.setRecurringTaskRuleActive(
                    ruleId: rule.id,
                    isActive: isActive,
                  );
                },
                onDeleteRule: (rule) {
                  _store.deleteRecurringTaskRule(rule.id);
                },
              );
            },
          );
        },
      ),
    );
  }

  void openGoalDetails(BuildContext context, Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AnimatedBuilder(
            animation: _store,
            builder: (context, _) {
              final currentGoal = _store.goals.firstWhere(
                (item) => item.id == goal.id,
                orElse: () => goal,
              );

              return GoalDetailsScreen(
                goal: currentGoal,
                milestones: _store.milestones,
                tasks: _store.tasks,
                onToggleTaskCompleted: _store.toggleTaskCompleted,
                onDeleteTask: _store.deleteTask,
                onTaskCreated: _store.addTask,
                onTaskUpdated: _store.updateTask,
                onTaskMovedToDirectGoal: _store.moveTaskToDirectGoal,
                onTaskAssignedToMilestone: _store.assignTaskToMilestone,
                onMilestoneCreated: _store.addMilestone,
                onMilestoneUpdated: _store.updateMilestone,
                onMilestoneDeletedAndTasksMovedToDirect:
                    _store.deleteMilestoneAndMoveTasksToDirect,
                onMilestoneDeletedWithTasks: _store.deleteMilestoneWithTasks,
                onScheduleTaskForToday: _store.scheduleTaskForToday,
                onScheduleTaskForDate: _store.scheduleTaskForDate,
                onCompleteTaskOnDate: _store.completeTaskOnDate,
                recurringRules: _store.recurringRules,
              );
            },
          );
        },
      ),
    );
  }
}
