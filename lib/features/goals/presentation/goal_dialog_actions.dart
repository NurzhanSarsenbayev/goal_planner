import 'package:flutter/material.dart';

import '../../../app/app_dialogs.dart';
import '../../../models/goal.dart';
import '../../../state/planner_store.dart';

class GoalDialogActions {
  const GoalDialogActions({required PlannerStore store}) : _store = store;

  final PlannerStore _store;

  Future<void> showAddDialog(BuildContext context) async {
    final result = await showAddGoalDialog(context);

    if (result == null) {
      return;
    }

    _store.addGoal(title: result.title, description: result.description);
  }

  Future<void> showEditDialog(BuildContext context, Goal goal) async {
    final result = await showEditGoalDialog(context, goal: goal);

    if (result == null) {
      return;
    }

    _store.updateGoal(
      goalId: goal.id,
      title: result.title,
      description: result.description,
    );
  }

  Future<void> showDeleteDialog(BuildContext context, Goal goal) async {
    final milestoneCount = _store.milestones
        .where((milestone) => milestone.goalId == goal.id)
        .length;

    final taskCount = _store.tasks
        .where((task) => task.goalId == goal.id)
        .length;

    final shouldDelete = await showDeleteGoalDialog(
      context,
      goal: goal,
      milestoneCount: milestoneCount,
      taskCount: taskCount,
    );

    if (!shouldDelete) {
      return;
    }

    _store.deleteGoalWithRelatedData(goal.id);
  }
}
