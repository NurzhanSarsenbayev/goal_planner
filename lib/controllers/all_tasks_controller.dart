import 'package:flutter/foundation.dart';

import '../models/planner_task.dart';

class AllTasksController extends ChangeNotifier {
  AllTasksController({
    required List<PlannerTask> tasks,
    required this.onToggleTaskCompleted,
    required this.onTaskUpdated,
    required this.onTaskAttachedToGoal,
    required this.onTaskDetachedFromGoal,
    required this.onDeleteTask,
  }) : _tasks = List.of(tasks);

  final void Function(String taskId) onToggleTaskCompleted;

  final void Function({
  required String taskId,
  required String title,
  required String description,
  }) onTaskUpdated;

  final void Function({
  required String taskId,
  required String goalId,
  String? milestoneId,
  }) onTaskAttachedToGoal;

  final void Function(String taskId) onTaskDetachedFromGoal;
  final void Function(String taskId) onDeleteTask;

  List<PlannerTask> _tasks;

  List<PlannerTask> get tasks => List.unmodifiable(_tasks);

  void toggleTaskCompleted(String taskId) {
    _updateTaskLocally(
      taskId,
          (task) => task.toggleCompleted(),
    );

    onToggleTaskCompleted(taskId);
  }

  void deleteTask(String taskId) {
    _tasks = _tasks.where((task) => task.id != taskId).toList();
    notifyListeners();

    onDeleteTask(taskId);
  }

  void updateTask({
    required String taskId,
    required String title,
    required String description,
  }) {
    _updateTaskLocally(
      taskId,
          (task) => task.copyWith(
        title: title,
        description: description,
      ),
    );

    onTaskUpdated(
      taskId: taskId,
      title: title,
      description: description,
    );
  }

  void attachTaskToGoal({
    required String taskId,
    required String goalId,
    String? milestoneId,
  }) {
    _updateTaskLocally(
      taskId,
          (task) {
        if (milestoneId == null) {
          return task.assignToGoal(goalId);
        }

        return task.assignToGoalMilestone(
          goalId: goalId,
          milestoneId: milestoneId,
        );
      },
    );

    onTaskAttachedToGoal(
      taskId: taskId,
      goalId: goalId,
      milestoneId: milestoneId,
    );
  }

  void detachTaskFromGoal(String taskId) {
    _updateTaskLocally(
      taskId,
          (task) => task.detachFromGoal(),
    );

    onTaskDetachedFromGoal(taskId);
  }

  void _updateTaskLocally(
      String taskId,
      PlannerTask Function(PlannerTask task) update,
      ) {
    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      return update(task);
    }).toList();

    notifyListeners();
  }
}q