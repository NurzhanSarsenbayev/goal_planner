import 'package:flutter/material.dart';

import 'task_dialogs.dart';
import '../../../models/planner_task.dart';
import '../../../state/planner_store.dart';

class TaskDialogActions {
  const TaskDialogActions({required PlannerStore store}) : _store = store;

  final PlannerStore _store;

  Future<void> showAddForTodayDialog(BuildContext context) async {
    final result = await showAddTaskWithPlacementDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
    );

    if (result == null) {
      return;
    }

    _store.addTaskForToday(
      title: result.title,
      description: result.description,
      scheduledTimeMinutes: result.scheduledTimeMinutes,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
    );
  }

  Future<void> showAddForDateDialog(
    BuildContext context,
    DateTime scheduledDate,
  ) async {
    final result = await showAddTaskWithPlacementDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
    );

    if (result == null) {
      return;
    }

    _store.addTaskForDate(
      title: result.title,
      description: result.description,
      scheduledDate: scheduledDate,
      scheduledTimeMinutes: result.scheduledTimeMinutes,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
    );
  }

  Future<void> showAttachToGoalDialog(
    BuildContext context,
    PlannerTask task,
  ) async {
    final result = await showTaskPlacementDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
    );

    if (result == null) {
      return;
    }

    _store.attachTaskToGoal(
      taskId: task.id,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
    );
  }

  Future<void> showEditDialog(BuildContext context, PlannerTask task) async {
    final result = await showEditTaskDialog(context, task: task);

    if (result == null) {
      return;
    }

    _store.updateTask(
      taskId: task.id,
      title: result.title,
      description: result.description,
    );
  }
}
