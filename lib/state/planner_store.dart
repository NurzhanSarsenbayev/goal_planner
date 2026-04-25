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

  void updateGoal({
    required String goalId,
    required String title,
    required String description,
  }) {
    Goal? updatedGoal;

    _goals = _goals.map((goal) {
      if (goal.id != goalId) {
        return goal;
      }

      updatedGoal = Goal(
        id: goal.id,
        title: title,
        description: description,
        status: goal.status,
        createdAt: goal.createdAt,
      );

      return updatedGoal!;
    }).toList();

    notifyListeners();

    if (updatedGoal != null) {
      _persist(_repository.saveGoal(updatedGoal!));
    }
  }

  void addMilestone(Milestone milestone) {
    _milestones = [..._milestones, milestone];
    notifyListeners();

    _persist(_repository.saveMilestone(milestone));
  }

  void updateMilestone({
    required String milestoneId,
    required String title,
    required String description,
  }) {
    Milestone? updatedMilestone;

    _milestones = _milestones.map((milestone) {
      if (milestone.id != milestoneId) {
        return milestone;
      }

      updatedMilestone = Milestone(
        id: milestone.id,
        goalId: milestone.goalId,
        title: title,
        description: description,
        createdAt: milestone.createdAt,
      );

      return updatedMilestone!;
    }).toList();

    notifyListeners();

    if (updatedMilestone != null) {
      _persist(_repository.saveMilestone(updatedMilestone!));
    }
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

    _persist(_repository.deleteMilestoneAndMoveTasksToDirect(milestoneId));
  }

  void deleteMilestoneWithTasks(String milestoneId) {
    _milestones = _milestones
        .where((milestone) => milestone.id != milestoneId)
        .toList();

    _tasks = _tasks
        .where((task) => task.milestoneId != milestoneId)
        .toList();

    notifyListeners();

    _persist(_repository.deleteMilestoneWithTasks(milestoneId));
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

  void updateTask({
    required String taskId,
    required String title,
    required String description,
  }) {
    PlannerTask? updatedTask;

    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = task.copyWith(
        title: title,
        description: description,
      );

      return updatedTask!;
    }).toList();

    notifyListeners();

    if (updatedTask != null) {
      _persist(_repository.saveTask(updatedTask!));
    }
  }

  void addTaskForToday({
    required String title,
    required String description,
    String? goalId,
    String? milestoneId,
  }) {
    final now = DateTime.now();

    final task = PlannerTask(
      id: 'task_${now.microsecondsSinceEpoch}',
      title: title,
      description: description,
      goalId: goalId,
      milestoneId: milestoneId,
      scheduledDate: DateTime(now.year, now.month, now.day),
      createdAt: now,
    );

    _tasks = [..._tasks, task];
    notifyListeners();

    _persist(_repository.saveTask(task));
  }

  void attachTaskToGoal({
    required String taskId,
    required String goalId,
    String? milestoneId,
  }) {
    PlannerTask? updatedTask;

    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = milestoneId == null
          ? task.assignToGoal(goalId)
          : task.assignToGoalMilestone(
        goalId: goalId,
        milestoneId: milestoneId,
      );

      return updatedTask!;
    }).toList();

    notifyListeners();

    if (updatedTask != null) {
      _persist(_repository.saveTask(updatedTask!));
    }
  }

  void detachTaskFromGoal(String taskId) {
    PlannerTask? updatedTask;

    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = task.detachFromGoal();
      return updatedTask!;
    }).toList();

    notifyListeners();

    if (updatedTask != null) {
      _persist(_repository.saveTask(updatedTask!));
    }
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

  void moveTaskToDirectGoal(String taskId) {
    PlannerTask? updatedTask;

    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = task.moveToDirectGoal();
      return updatedTask!;
    }).toList();

    notifyListeners();

    if (updatedTask != null) {
      _persist(_repository.saveTask(updatedTask!));
    }
  }

  void assignTaskToMilestone({
    required String taskId,
    required String milestoneId,
  }) {
    PlannerTask? updatedTask;

    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = task.assignToMilestone(milestoneId);
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