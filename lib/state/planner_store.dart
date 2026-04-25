import 'package:flutter/foundation.dart';

import '../data/repositories/planner_repository.dart';
import '../data/sample_data.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';

class PlannerStore extends ChangeNotifier {
  PlannerStore(this._repository);

  final PlannerRepository _repository;

  List<Goal> _goals = [];
  List<Milestone> _milestones = [];
  List<PlannerTask> _tasks = [];
  bool _isInitialized = false;

  List<Goal> get goals => List.unmodifiable(_goals);
  List<Milestone> get milestones => List.unmodifiable(_milestones);
  List<PlannerTask> get tasks => List.unmodifiable(_tasks);
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    await _loadFromDatabase();

    if (_goals.isEmpty && _milestones.isEmpty && _tasks.isEmpty) {
      await _seedInitialData();
      await _loadFromDatabase();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFromDatabase() async {
    _goals = await _repository.loadGoals();
    _milestones = await _repository.loadMilestones();
    _tasks = await _repository.loadTasks();
  }

  Future<void> _seedInitialData() async {
    for (final goal in sampleGoals) {
      await _repository.saveGoal(goal);
    }

    for (final milestone in sampleMilestones) {
      await _repository.saveMilestone(milestone);
    }

    for (final task in sampleTasks) {
      await _repository.saveTask(task);
    }
  }

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

    _persist(_repository.saveGoal(goal));
  }

  void addMilestone(Milestone milestone) {
    _milestones = [..._milestones, milestone];
    notifyListeners();

    _persist(_repository.saveMilestone(milestone));
  }

  void addTask(PlannerTask task) {
    _tasks = [..._tasks, task];
    notifyListeners();

    _persist(_repository.saveTask(task));
  }

  void deleteTask(String taskId) {
    _tasks = _tasks.where((task) => task.id != taskId).toList();
    notifyListeners();

    _persist(_repository.deleteTask(taskId));
  }

  void addStandaloneTaskForToday({
    required String title,
    required String description,
  }) {
    final now = DateTime.now();

    final task = PlannerTask(
      id: 'task_${now.microsecondsSinceEpoch}',
      title: title,
      description: description,
      scheduledDate: DateTime(now.year, now.month, now.day),
      createdAt: now,
    );

    _tasks = [..._tasks, task];
    notifyListeners();

    _persist(_repository.saveTask(task));
  }

  void toggleTaskCompleted(String taskId) {
    PlannerTask? updatedTask;

    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = task.toggleCompleted();
      return updatedTask!;
    }).toList();

    notifyListeners();

    if (updatedTask != null) {
      _persist(_repository.saveTask(updatedTask!));
    }
  }

  void scheduleTaskForToday(String taskId) {
    PlannerTask? updatedTask;

    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = task.scheduledToday();
      return updatedTask!;
    }).toList();

    notifyListeners();

    if (updatedTask != null) {
      _persist(_repository.saveTask(updatedTask!));
    }
  }

  void _persist(Future<void> operation) {
    operation.catchError((Object error, StackTrace stackTrace) {
      debugPrint('Persistence error: $error');
      debugPrintStack(stackTrace: stackTrace);
    });
  }
}