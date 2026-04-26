import 'package:flutter/foundation.dart';

import '../data/repositories/planner_repository.dart';
import 'planner_seed_service.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';

class PlannerStore extends ChangeNotifier {
  PlannerStore(this._repository)
      : _seedService = PlannerSeedService(_repository);

  final PlannerRepository _repository;
  final PlannerSeedService _seedService;

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
      await _seedService.seedInitialData();
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
    _updateGoalById(
      goalId,
          (goal) => goal.copyWith(
        title: title,
        description: description,
      ),
    );
  }

  void deleteGoalWithRelatedData(String goalId) {
    _goals = _goals.where((goal) => goal.id != goalId).toList();

    _milestones = _milestones
        .where((milestone) => milestone.goalId != goalId)
        .toList();

    _tasks = _tasks.where((task) => task.goalId != goalId).toList();

    notifyListeners();

    _persist(_repository.deleteGoalWithRelatedData(goalId));
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
    _updateMilestoneById(
      milestoneId,
          (milestone) => milestone.copyWith(
        title: title,
        description: description,
      ),
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

    _persist(_repository.deleteMilestoneAndMoveTasksToDirect(milestoneId));
  }

  void deleteMilestoneWithTasks(String milestoneId) {
    _milestones = _milestones
        .where((milestone) => milestone.id != milestoneId)
        .toList();

    _tasks = _tasks.where((task) => task.milestoneId != milestoneId).toList();

    notifyListeners();

    _persist(_repository.deleteMilestoneWithTasks(milestoneId));
  }

  void addTask(PlannerTask task) {
    _tasks = [..._tasks, task];
    notifyListeners();

    _persist(_repository.saveTask(task));
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

    addTask(task);
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
    _updateTaskById(
      taskId,
          (task) => task.copyWith(
        title: title,
        description: description,
      ),
    );
  }

  void attachTaskToGoal({
    required String taskId,
    required String goalId,
    String? milestoneId,
  }) {
    _updateTaskById(
      taskId,
          (task) => milestoneId == null
          ? task.assignToGoal(goalId)
          : task.assignToGoalMilestone(
        goalId: goalId,
        milestoneId: milestoneId,
      ),
    );
  }

  void detachTaskFromGoal(String taskId) {
    _updateTaskById(
      taskId,
          (task) => task.detachFromGoal(),
    );
  }

  void toggleTaskCompleted(String taskId) {
    _updateTaskById(
      taskId,
          (task) => task.toggleCompleted(),
    );
  }

  void scheduleTaskForToday(String taskId) {
    _updateTaskById(
      taskId,
          (task) => task.scheduledToday(),
    );
  }

  void scheduleTaskForDate({
    required String taskId,
    required DateTime scheduledDate,
  }) {
    _updateTaskById(
      taskId,
          (task) => task.scheduleForDate(scheduledDate),
    );
  }

  void removeTaskFromToday(String taskId) {
    _updateTaskById(
      taskId,
          (task) => task.unschedule(),
    );
  }

  void moveTaskToDirectGoal(String taskId) {
    _updateTaskById(
      taskId,
          (task) => task.moveToDirectGoal(),
    );
  }

  void assignTaskToMilestone({
    required String taskId,
    required String milestoneId,
  }) {
    _updateTaskById(
      taskId,
          (task) => task.assignToMilestone(milestoneId),
    );
  }

  void _updateGoalById(
      String goalId,
      Goal Function(Goal goal) update,
      ) {
    Goal? updatedGoal;

    _goals = _goals.map((goal) {
      if (goal.id != goalId) {
        return goal;
      }

      updatedGoal = update(goal);
      return updatedGoal!;
    }).toList();

    notifyListeners();

    if (updatedGoal != null) {
      _persist(_repository.saveGoal(updatedGoal!));
    }
  }

  void _updateMilestoneById(
      String milestoneId,
      Milestone Function(Milestone milestone) update,
      ) {
    Milestone? updatedMilestone;

    _milestones = _milestones.map((milestone) {
      if (milestone.id != milestoneId) {
        return milestone;
      }

      updatedMilestone = update(milestone);
      return updatedMilestone!;
    }).toList();

    notifyListeners();

    if (updatedMilestone != null) {
      _persist(_repository.saveMilestone(updatedMilestone!));
    }
  }

  void _updateTaskById(
      String taskId,
      PlannerTask Function(PlannerTask task) update,
      ) {
    PlannerTask? updatedTask;

    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = update(task);
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