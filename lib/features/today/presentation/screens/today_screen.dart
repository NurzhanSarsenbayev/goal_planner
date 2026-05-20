import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../../tasks/presentation/task_date_dialogs.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../habits/application/habit_today_summary.dart';
import '../../application/today_task_view_builder.dart';
import '../widgets/today_empty_panel.dart';
import '../widgets/today_summary_card.dart';
import '../widgets/today_task_section.dart';
import '../widgets/today_habits_summary_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.habitSummary,
    required this.onOpenHabits,
    required this.onToggleTaskCompleted,
    required this.onCompleteTaskOnDate,
    required this.onEditTask,
    required this.onAttachTaskToGoal,
    required this.onDetachTaskFromGoal,
    required this.onDeleteTask,
    required this.onAddTask,
    required this.onRemoveTaskFromToday,
    required this.onScheduleTaskForDate,
    required this.onScheduleTaskForDateAndTime,
    required this.onAddRecurringTask,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final HabitTodaySummary habitSummary;
  final VoidCallback onOpenHabits;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function({required String taskId, required DateTime completedAt})
  onCompleteTaskOnDate;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onRemoveTaskFromToday;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function({
    required String taskId,
    required DateTime scheduledDate,
    required int? scheduledTimeMinutes,
  })
  onScheduleTaskForDateAndTime;
  final void Function(PlannerTask task) onAttachTaskToGoal;
  final void Function(String taskId) onDetachTaskFromGoal;
  final void Function(String taskId) onDeleteTask;
  final VoidCallback onAddTask;
  final VoidCallback onAddRecurringTask;
  final TodayTaskViewBuilder _viewBuilder = const TodayTaskViewBuilder();

  Future<void> _showScheduleTaskDatePicker(
    BuildContext context,
    PlannerTask task,
  ) async {
    final selectedDate = await showScheduleTaskDatePicker(
      context,
      initialDate: task.scheduledDate,
    );

    if (selectedDate == null) {
      return;
    }

    onScheduleTaskForDate(taskId: task.id, scheduledDate: selectedDate);
  }

  Future<void> _showScheduleTaskTimePicker(
    BuildContext context,
    PlannerTask task,
  ) async {
    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null) {
      return;
    }

    final selectedTime = await showScheduleTaskTimePicker(
      context,
      initialTimeMinutes: task.scheduledTimeMinutes,
    );

    if (selectedTime == null) {
      return;
    }

    onScheduleTaskForDateAndTime(
      taskId: task.id,
      scheduledDate: scheduledDate,
      scheduledTimeMinutes: selectedTime,
    );
  }

  void _clearScheduledTaskTime(PlannerTask task) {
    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null) {
      return;
    }

    onScheduleTaskForDateAndTime(
      taskId: task.id,
      scheduledDate: scheduledDate,
      scheduledTimeMinutes: null,
    );
  }

  Future<void> _showAddActionSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final selectedAction = await showModalBottomSheet<_TodayAddAction>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.todayOneTimeTaskTitle),
                subtitle: Text(l10n.todayOneTimeTaskSubtitle),
                onTap: () {
                  Navigator.of(context).pop(_TodayAddAction.oneTimeTask);
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: Text(l10n.todayRecurringTaskTitle),
                subtitle: Text(l10n.todayRecurringTaskSubtitle),
                onTap: () {
                  Navigator.of(context).pop(_TodayAddAction.recurringTask);
                },
              ),
            ],
          ),
        );
      },
    );

    switch (selectedAction) {
      case _TodayAddAction.oneTimeTask:
        onAddTask();
      case _TodayAddAction.recurringTask:
        onAddRecurringTask();
      case null:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = _viewBuilder.build(goals: goals, tasks: tasks);
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            TodaySummaryCard(view: view),
            const SizedBox(height: 16),
            TodayHabitsSummaryCard(
              summary: habitSummary,
              onOpenHabits: onOpenHabits,
            ),
            if (habitSummary.hasHabits) const SizedBox(height: 16),
            if (view.isEmpty)
              TodayEmptyPanel(
                onPlanToday: () {
                  _showAddActionSheet(context);
                },
              )
            else ...[
              if (view.overdueTasks.isNotEmpty) ...[
                TodayTaskSection(
                  title: l10n.todayOverdueSection,
                  icon: Icons.warning_amber_outlined,
                  tasks: view.overdueTasks,
                  itemBuilder: (task) {
                    return _buildTaskCard(context, view, task);
                  },
                ),
                const SizedBox(height: 24),
              ],
              TodayTaskSection(
                title: l10n.todayTodoSection,
                icon: Icons.radio_button_unchecked,
                tasks: view.pendingTodayTasks,
                emptyText: l10n.todayNoTasksLeft,
                itemBuilder: (task) {
                  return _buildTaskCard(context, view, task);
                },
              ),
              if (view.doneTodayTasks.isNotEmpty) ...[
                const SizedBox(height: 24),
                TodayTaskSection(
                  title: l10n.todayDoneSection,
                  icon: Icons.check_circle_outline,
                  tasks: view.doneTodayTasks,
                  itemBuilder: (task) {
                    return _buildTaskCard(context, view, task);
                  },
                ),
              ],
            ],
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              _showAddActionSheet(context);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.todayAddTaskButton),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TodayTaskView view,
    PlannerTask task,
  ) {
    final goal = view.findGoalById(task.goalId);
    final isStandaloneTask = task.goalId == null;
    final isGoalLinkedTask = task.goalId != null;
    final canEditScheduleTime =
        task.scheduledDate != null && task.recurringRuleId == null;

    return TaskCard(
      key: ValueKey(task.id),
      task: task,
      goal: goal,
      onToggleCompleted: () {
        handleTaskCompletionWithDateFlow(
          context,
          task: task,
          onToggleTaskCompleted: onToggleTaskCompleted,
          onCompleteTaskOnDate: onCompleteTaskOnDate,
        );
      },
      onEdit: () => onEditTask(task),
      onAttachToGoal: isStandaloneTask ? () => onAttachTaskToGoal(task) : null,
      onDetachFromGoal: isGoalLinkedTask
          ? () => onDetachTaskFromGoal(task.id)
          : null,
      onRemoveFromToday: task.isScheduledForToday
          ? () => onRemoveTaskFromToday(task.id)
          : null,
      onUnschedule: view.isOverdue(task)
          ? () => onRemoveTaskFromToday(task.id)
          : null,
      onScheduleDate: () {
        _showScheduleTaskDatePicker(context, task);
      },
      onScheduleTime: canEditScheduleTime
          ? () {
              _showScheduleTaskTimePicker(context, task);
            }
          : null,
      onClearScheduledTime:
          canEditScheduleTime && task.scheduledTimeMinutes != null
          ? () {
              _clearScheduledTaskTime(task);
            }
          : null,
      onDelete: () => onDeleteTask(task.id),
    );
  }
}

enum _TodayAddAction { oneTimeTask, recurringTask }
