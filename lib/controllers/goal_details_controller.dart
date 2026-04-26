import 'package:flutter/foundation.dart';

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';

class GoalDetailsController extends ChangeNotifier {
  GoalDetailsController({
    required this.goal,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
    required this.onToggleTaskCompleted,
    required this.onTaskCreated,
    required this.onDeleteTask,
    required this.onTaskUpdated,
    required this.onTaskMovedToDirectGoal,
    required this.onTaskAssignedToMilestone,
    required this.onMilestoneCreated,
    required this.onMilestoneUpdated,
    required this.onMilestoneDeletedAndTasksMovedToDirect,
    required this.onMilestoneDeletedWithTasks,
    required this.onScheduleTaskForToday,
    required this.onScheduleTaskForDate,
  }) : _milestones = List.of(milestones),
       _tasks = List.of(tasks);

  final Goal goal;

  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onTaskCreated;
  final void Function(String taskId) onDeleteTask;

  final void Function({
    required String taskId,
    required String title,
    required String description,
  })
  onTaskUpdated;

  final void Function(String taskId) onTaskMovedToDirectGoal;

  final void Function({required String taskId, required String milestoneId})
  onTaskAssignedToMilestone;

  final void Function(Milestone milestone) onMilestoneCreated;

  final void Function({
    required String milestoneId,
    required String title,
    required String description,
  })
  onMilestoneUpdated;

  final void Function(String milestoneId)
  onMilestoneDeletedAndTasksMovedToDirect;
  final void Function(String milestoneId) onMilestoneDeletedWithTasks;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;

  List<Milestone> _milestones;
  List<PlannerTask> _tasks;

  List<PlannerTask> get goalTasks {
    return _tasks.where((task) => task.goalId == goal.id).toList();
  }

  List<Milestone> get goalMilestones {
    return _milestones
        .where((milestone) => milestone.goalId == goal.id)
        .toList();
  }

  List<PlannerTask> get directGoalTasks {
    final milestoneIds = goalMilestones
        .map((milestone) => milestone.id)
        .toSet();

    return goalTasks
        .where(
          (task) =>
              task.milestoneId == null ||
              !milestoneIds.contains(task.milestoneId),
        )
        .toList();
  }

  int get completedTasks {
    return goalTasks.where((task) => task.isCompleted).length;
  }

  List<PlannerTask> tasksForMilestone(String milestoneId) {
    return _tasks.where((task) => task.milestoneId == milestoneId).toList();
  }

  void toggleTaskCompleted(String taskId) {
    _updateTaskLocally(taskId, (task) => task.toggleCompleted());

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
      (task) => task.copyWith(title: title, description: description),
    );

    onTaskUpdated(taskId: taskId, title: title, description: description);
  }

  void scheduleTaskForToday(String taskId) {
    _updateTaskLocally(taskId, (task) => task.scheduledToday());

    onScheduleTaskForToday(taskId);
  }

  void scheduleTaskForDate({
    required String taskId,
    required DateTime scheduledDate,
  }) {
    _updateTaskLocally(taskId, (task) => task.scheduleForDate(scheduledDate));

    onScheduleTaskForDate(taskId: taskId, scheduledDate: scheduledDate);
  }

  void createTask({
    required String title,
    required String description,
    String? milestoneId,
  }) {
    final now = DateTime.now();

    final task = PlannerTask(
      id: 'task_${now.microsecondsSinceEpoch}',
      goalId: goal.id,
      milestoneId: milestoneId,
      title: title,
      description: description,
      createdAt: now,
    );

    _tasks = [..._tasks, task];
    notifyListeners();

    onTaskCreated(task);
  }

  void moveTaskToDirectGoal(String taskId) {
    _updateTaskLocally(taskId, (task) => task.moveToDirectGoal());

    onTaskMovedToDirectGoal(taskId);
  }

  void assignTaskToMilestone({
    required String taskId,
    required String milestoneId,
  }) {
    _updateTaskLocally(taskId, (task) => task.assignToMilestone(milestoneId));

    onTaskAssignedToMilestone(taskId: taskId, milestoneId: milestoneId);
  }

  void createMilestone({required String title, required String description}) {
    final now = DateTime.now();

    final milestone = Milestone(
      id: 'milestone_${now.microsecondsSinceEpoch}',
      goalId: goal.id,
      title: title,
      description: description,
      createdAt: now,
    );

    _milestones = [..._milestones, milestone];
    notifyListeners();

    onMilestoneCreated(milestone);
  }

  void updateMilestone({
    required String milestoneId,
    required String title,
    required String description,
  }) {
    _milestones = _milestones.map((milestone) {
      if (milestone.id != milestoneId) {
        return milestone;
      }

      return milestone.copyWith(title: title, description: description);
    }).toList();

    notifyListeners();

    onMilestoneUpdated(
      milestoneId: milestoneId,
      title: title,
      description: description,
    );
  }

  void deleteMilestoneAndMoveTasksToDirect(String milestoneId) {
    _milestones = _milestones
        .where((milestone) => milestone.id != milestoneId)
        .toList();

    _tasks = _tasks.map((task) {
      if (task.milestoneId != milestoneId) {
        return task;
      }

      return task.moveToDirectGoal();
    }).toList();

    notifyListeners();

    onMilestoneDeletedAndTasksMovedToDirect(milestoneId);
  }

  void deleteMilestoneWithTasks(String milestoneId) {
    _milestones = _milestones
        .where((milestone) => milestone.id != milestoneId)
        .toList();

    _tasks = _tasks.where((task) => task.milestoneId != milestoneId).toList();

    notifyListeners();

    onMilestoneDeletedWithTasks(milestoneId);
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
}
