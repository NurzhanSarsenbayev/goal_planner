import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_placement_dialog.dart';
import '../widgets/today_task_dialog.dart';

Future<GoalDraft?> showAddGoalDialog(BuildContext context) {
  return showDialog<GoalDraft>(
    context: context,
    builder: (context) {
      return const GoalDialog();
    },
  );
}

Future<GoalDraft?> showEditGoalDialog(
    BuildContext context, {
      required Goal goal,
    }) {
  return showDialog<GoalDraft>(
    context: context,
    builder: (context) {
      return GoalDialog(
        initialTitle: goal.title,
        initialDescription: goal.description,
        title: 'Edit goal',
        submitLabel: 'Save',
      );
    },
  );
}

Future<TaskDraft?> showEditTaskDialog(
    BuildContext context, {
      required PlannerTask task,
    }) {
  return showDialog<TaskDraft>(
    context: context,
    builder: (context) {
      return TaskDialog(
        initialTitle: task.title,
        initialDescription: task.description,
        title: 'Edit task',
        submitLabel: 'Save',
      );
    },
  );
}

Future<TodayTaskDraft?> showAddTodayTaskDialog(
    BuildContext context, {
      required List<Goal> goals,
      required List<Milestone> milestones,
    }) {
  return showDialog<TodayTaskDraft>(
    context: context,
    builder: (context) {
      return TodayTaskDialog(
        goals: goals,
        milestones: milestones,
      );
    },
  );
}

Future<TaskPlacementDraft?> showTaskPlacementDialog(
    BuildContext context, {
      required List<Goal> goals,
      required List<Milestone> milestones,
    }) {
  return showDialog<TaskPlacementDraft>(
    context: context,
    builder: (context) {
      return TaskPlacementDialog(
        goals: goals,
        milestones: milestones,
      );
    },
  );
}