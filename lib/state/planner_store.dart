import 'package:flutter/foundation.dart';

import '../data/repositories/planner_repository.dart';
import 'planner_seed_service.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../models/recurring_task_exception.dart';
import '../models/recurring_task_rule.dart';
import '../recurring/recurring_task_generator.dart';
import '../shared/planner_dates.dart';

class PlannerStore extends ChangeNotifier {
  PlannerStore(this._repository)
    : _seedService = PlannerSeedService(_repository);

  final PlannerRepository _repository;
  final PlannerSeedService _seedService;

  List<Goal> _goals = [];
  List<Milestone> _milestones = [];
  List<PlannerTask> _tasks = [];
  List<RecurringTaskRule> _recurringRules = [];
  List<RecurringTaskException> _recurringExceptions = [];
  bool _isInitialized = false;

  List<Goal> get goals => List.unmodifiable(_goals);
  List<Milestone> get milestones => List.unmodifiable(_milestones);
  List<PlannerTask> get tasks => List.unmodifiable(_tasks);
  List<RecurringTaskRule> get recurringRules =>
      List.unmodifiable(_recurringRules);

  List<RecurringTaskException> get recurringExceptions =>
      List.unmodifiable(_recurringExceptions);
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    await _loadFromDatabase();

    if (_goals.isEmpty && _milestones.isEmpty && _tasks.isEmpty) {
      await _seedService.seedInitialData();
      await _loadFromDatabase();
    }

    await _ensureUpcomingRecurringTaskOccurrences();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFromDatabase() async {
    _goals = await _repository.loadGoals();
    _milestones = await _repository.loadMilestones();
    _tasks = await _repository.loadTasks();
    _recurringRules = await _repository.loadRecurringTaskRules();
    _recurringExceptions = await _repository.loadRecurringTaskExceptions();
  }

  void addGoal({required String title, required String description}) {
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
      (goal) => goal.copyWith(title: title, description: description),
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
      (milestone) => milestone.copyWith(title: title, description: description),
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
    addTaskForDate(
      title: title,
      description: description,
      scheduledDate: todayDate(),
      goalId: goalId,
      milestoneId: milestoneId,
    );
  }

  void addTaskForDate({
    required String title,
    required String description,
    required DateTime scheduledDate,
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
      scheduledDate: dateOnly(scheduledDate),
      createdAt: now,
    );

    addTask(task);
  }

  void addRecurringTaskRule(RecurringTaskRule rule) {
    _recurringRules = [..._recurringRules, rule];

    final generatedTasks = generateUpcomingRecurringTaskOccurrences(
      rules: _recurringRules,
      exceptions: _recurringExceptions,
      existingTasks: _tasks,
      today: todayDate(),
    );

    _tasks = [..._tasks, ...generatedTasks];

    notifyListeners();

    _persist(
      Future.wait([
        _repository.saveRecurringTaskRule(rule),
        ...generatedTasks.map(_repository.saveTask),
      ]).then((_) {}),
    );
  }

  void deleteTask(String taskId) {
    final taskToDelete = _findTaskById(taskId);

    if (taskToDelete == null) {
      return;
    }

    if (_isRecurringOccurrence(taskToDelete)) {
      _deleteRecurringOccurrence(taskToDelete);
      return;
    }

    _deleteRegularTask(taskId);
  }

  PlannerTask? _findTaskById(String taskId) {
    for (final task in _tasks) {
      if (task.id == taskId) {
        return task;
      }
    }

    return null;
  }

  bool _isRecurringOccurrence(PlannerTask task) {
    return task.recurringRuleId != null && task.scheduledDate != null;
  }

  void _deleteRegularTask(String taskId) {
    _tasks = _tasks.where((task) => task.id != taskId).toList();
    notifyListeners();

    _persist(_repository.deleteTask(taskId));
  }

  void _deleteRecurringOccurrence(PlannerTask task) {
    final recurringRuleId = task.recurringRuleId;
    final scheduledDate = task.scheduledDate;

    if (recurringRuleId == null || scheduledDate == null) {
      _deleteRegularTask(task.id);
      return;
    }

    final exception = RecurringTaskException(
      id: recurringTaskExceptionId(
        ruleId: recurringRuleId,
        date: scheduledDate,
      ),
      ruleId: recurringRuleId,
      date: scheduledDate,
      createdAt: DateTime.now(),
    );

    final exceptionAlreadyExists = _recurringExceptions.any(
      (existingException) => existingException.matches(
        ruleId: recurringRuleId,
        date: scheduledDate,
      ),
    );

    _tasks = _tasks
        .where((existingTask) => existingTask.id != task.id)
        .toList();

    if (!exceptionAlreadyExists) {
      _recurringExceptions = [..._recurringExceptions, exception];
    }

    notifyListeners();

    _persist(
      _repository.deleteTaskWithRecurringException(
        taskId: task.id,
        exception: exception,
      ),
    );
  }

  void updateTask({
    required String taskId,
    required String title,
    required String description,
  }) {
    _updateTaskById(
      taskId,
      (task) => task.copyWith(title: title, description: description),
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
    _updateTaskById(taskId, (task) => task.detachFromGoal());
  }

  void toggleTaskCompleted(String taskId) {
    _updateTaskById(taskId, (task) => task.toggleCompleted());
  }

  void completeTaskOnDate({
    required String taskId,
    required DateTime completedAt,
  }) {
    _updateTaskById(taskId, (task) => task.completedOn(completedAt));
  }

  void scheduleTaskForToday(String taskId) {
    _updateTaskById(taskId, (task) => task.scheduledToday());
  }

  void scheduleTaskForDate({
    required String taskId,
    required DateTime scheduledDate,
  }) {
    _updateTaskById(taskId, (task) => task.scheduleForDate(scheduledDate));
  }

  void unscheduleTask(String taskId) {
    _updateTaskById(taskId, (task) => task.unschedule());
  }

  void moveTaskToDirectGoal(String taskId) {
    _updateTaskById(taskId, (task) => task.moveToDirectGoal());
  }

  void assignTaskToMilestone({
    required String taskId,
    required String milestoneId,
  }) {
    _updateTaskById(taskId, (task) => task.assignToMilestone(milestoneId));
  }

  Future<void> _ensureUpcomingRecurringTaskOccurrences() async {
    final generatedTasks = generateUpcomingRecurringTaskOccurrences(
      rules: _recurringRules,
      exceptions: _recurringExceptions,
      existingTasks: _tasks,
      today: todayDate(),
    );

    if (generatedTasks.isEmpty) {
      return;
    }

    _tasks = [..._tasks, ...generatedTasks];

    await Future.wait(generatedTasks.map(_repository.saveTask));
  }

  void ensureRecurringTaskOccurrencesForMonth(DateTime visibleMonth) {
    final monthStart = DateTime(visibleMonth.year, visibleMonth.month);
    final monthEnd = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);

    final generatedTasks = generateRecurringTaskOccurrences(
      rules: _recurringRules,
      exceptions: _recurringExceptions,
      existingTasks: _tasks,
      startDate: monthStart,
      endDate: monthEnd,
    );

    if (generatedTasks.isEmpty) {
      return;
    }

    _tasks = [..._tasks, ...generatedTasks];

    notifyListeners();

    _persist(
      Future.wait(generatedTasks.map(_repository.saveTask)).then((_) {}),
    );
  }

  void _updateGoalById(String goalId, Goal Function(Goal goal) update) {
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
