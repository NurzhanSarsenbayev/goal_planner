import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';

class PlannerStore extends ChangeNotifier {
  PlannerStore()
      : _goals = List.of(sampleGoals),
        _milestones = List.of(sampleMilestones),
        _tasks = List.of(sampleTasks);

  List<Goal> _goals;
  List<Milestone> _milestones;
  List<PlannerTask> _tasks;

  List<Goal> get goals => List.unmodifiable(_goals);
  List<Milestone> get milestones => List.unmodifiable(_milestones);
  List<PlannerTask> get tasks => List.unmodifiable(_tasks);

  void addGoal({
    required String title,
    required String description,
  }) {
    final now = DateTime.now();

    final goal = Goal(
      id: 'goal_${now.microsecondsSinceEpoch}',
      title: title,
      description: description,
      status: GoalStatus.active,
      createdAt: now,
    );

    _goals = [..._goals, goal];
    notifyListeners();
  }

  void addMilestone({
    required String goalId,
    required String title,
    required String description,
  }) {
    final now = DateTime.now();

    final milestone = Milestone(
      id: 'milestone_${now.microsecondsSinceEpoch}',
      goalId: goalId,
      title: title,
      description: description,
      createdAt: now,
    );

    _milestones = [..._milestones, milestone];
    notifyListeners();
  }

  void addTask(PlannerTask task) {
    _tasks = [..._tasks, task];
    notifyListeners();
  }

  void toggleTaskCompleted(String taskId) {
    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      return task.toggleCompleted();
    }).toList();

    notifyListeners();
  }

  void scheduleTaskForToday(String taskId) {
    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      return task.scheduledToday();
    }).toList();

    notifyListeners();
  }
}