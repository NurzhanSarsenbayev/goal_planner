import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../features/goals/presentation/screens/goal_details_screen.dart';
import '../../features/tasks/presentation/screens/all_tasks_screen.dart';
import '../../features/recurring/presentation/screens/recurring_tasks_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/reminders/standalone/presentation/screens/standalone_reminders_screen.dart';
import '../../state/planner_store.dart';
import '../../features/recurring/presentation/recurring_rule_dialog_actions.dart';
import '../../features/tasks/presentation/task_dialog_actions.dart';
import '../../features/reports/application/habit_report_loader.dart';
import '../../features/reminders/standalone/application/standalone_reminder_store.dart';
import '../../features/reminders/daily_review/application/daily_review_reminder_settings_store.dart';
import '../../features/reminders/daily_review/presentation/screens/daily_review_reminder_settings_screen.dart';
import '../../features/body_tracking/application/body_weight_tracking_service.dart';
import '../../features/body_tracking/presentation/screens/body_weight_progress_screen.dart';
import '../../features/body_tracking/application/body_measurement_tracking_service.dart';
import '../../features/body_tracking/application/body_profile_tracking_service.dart';

class AppNavigationActions {
  const AppNavigationActions({
    required PlannerStore store,
    required TaskDialogActions taskDialogActions,
    required RecurringRuleDialogActions recurringRuleDialogActions,
    required HabitReportLoader habitReportLoader,
    required StandaloneReminderStore standaloneReminderStore,
    required DailyReviewReminderSettingsStore dailyReviewReminderSettingsStore,
    required BodyWeightTrackingService bodyWeightTrackingService,
    required BodyMeasurementTrackingService bodyMeasurementTrackingService,
    required BodyProfileTrackingService bodyProfileTrackingService,
  }) : _store = store,
       _taskDialogActions = taskDialogActions,
       _habitReportLoader = habitReportLoader,
       _standaloneReminderStore = standaloneReminderStore,
       _dailyReviewReminderSettingsStore = dailyReviewReminderSettingsStore,
       _recurringRuleDialogActions = recurringRuleDialogActions,
       _bodyWeightTrackingService = bodyWeightTrackingService,
       _bodyMeasurementTrackingService = bodyMeasurementTrackingService,
       _bodyProfileTrackingService = bodyProfileTrackingService;

  final PlannerStore _store;
  final HabitReportLoader _habitReportLoader;
  final StandaloneReminderStore _standaloneReminderStore;
  final DailyReviewReminderSettingsStore _dailyReviewReminderSettingsStore;
  final TaskDialogActions _taskDialogActions;
  final RecurringRuleDialogActions _recurringRuleDialogActions;
  final BodyWeightTrackingService _bodyWeightTrackingService;
  final BodyMeasurementTrackingService _bodyMeasurementTrackingService;
  final BodyProfileTrackingService _bodyProfileTrackingService;

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
                onUpdateTaskReminder: _store.updateTaskReminder,
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

  void openBodyWeightProgress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return BodyWeightProgressScreen(
            service: _bodyWeightTrackingService,
            measurementService: _bodyMeasurementTrackingService,
            profileService: _bodyProfileTrackingService,
          );
        },
      ),
    );
  }

  void openStandaloneReminders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return StandaloneRemindersScreen(
            reminderStore: _standaloneReminderStore,
          );
        },
      ),
    );
  }

  void openDailyReviewReminderSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DailyReviewReminderSettingsScreen(
            settingsStore: _dailyReviewReminderSettingsStore,
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
                onUpdateTaskReminder: _store.updateTaskReminder,
                onCompleteTaskOnDate: _store.completeTaskOnDate,
                onAddDirectRecurringTask: () {
                  _recurringRuleDialogActions.showAddDialog(
                    context,
                    goalId: currentGoal.id,
                  );
                },
                onAddRecurringTaskToMilestone: (milestoneId) {
                  _recurringRuleDialogActions.showAddDialog(
                    context,
                    goalId: currentGoal.id,
                    milestoneId: milestoneId,
                  );
                },
                onRecurringRuleActiveChanged: (rule, isActive) {
                  _store.setRecurringTaskRuleActive(
                    ruleId: rule.id,
                    isActive: isActive,
                  );
                },
                onEditRecurringRule: (rule) {
                  _recurringRuleDialogActions.showEditDialog(context, rule);
                },
                onDeleteRecurringRule: (rule) {
                  _store.deleteRecurringTaskRule(rule.id);
                },
                recurringRules: _store.recurringRules,
              );
            },
          );
        },
      ),
    );
  }
}
