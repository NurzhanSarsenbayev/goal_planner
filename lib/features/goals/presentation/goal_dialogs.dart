import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import 'widgets/delete_goal_dialog.dart';
import 'widgets/goal_dialog.dart';

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

Future<bool> showDeleteGoalDialog(
  BuildContext context, {
  required Goal goal,
  required int milestoneCount,
  required int taskCount,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return DeleteGoalDialog(
        goalTitle: goal.title,
        milestoneCount: milestoneCount,
        taskCount: taskCount,
      );
    },
  );

  return result ?? false;
}
