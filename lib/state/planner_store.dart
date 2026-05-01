import 'package:flutter/foundation.dart';

import '../data/repositories/planner_repository.dart';
import '../features/tasks/application/task_application_service.dart';
import '../features/recurring/application/recurring_task_application_service.dart';
import 'planner_seed_service.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../models/recurring_task_exception.dart';
import '../models/recurring_task_rule.dart';
import '../recurring/recurring_occurrence_lifecycle.dart';
import '../shared/planner_dates.dart';

class PlannerStore extends ChangeNotifier {
  PlannerStore(this._repository)
    : _seedService = PlannerSeedService(_repository);

  final PlannerRepository _repository;
  final PlannerSeedService _seedService;
  final TaskApplicationService _taskApplicationService =
      const TaskApplicationService();

  final RecurringOccurrenceLifecycle _recurringOccurrenceLifecycle =
      RecurringOccurrenceLifecycle();
  final RecurringTaskApplicationService _recurringTaskApplicationService =
      RecurringTaskApplicationService();

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
    final deletedRecurringRuleIds = _recurringRules
        .where((rule) => rule.goalId == goalId)
        .map((rule) => rule.id)
        .toSet();

    _goals = _goals.where((goal) => goal.id != goalId).toList();

    _milestones = _milestones
        .where((milestone) => milestone.goalId != goalId)
        .toList();

    _tasks = _tasks.where((task) => task.goalId != goalId).toList();

    _recurringRules = _recurringRules
        .where((rule) => rule.goalId != goalId)
        .toList();

    _recurringExceptions = _recurringExceptions.where((exception) {
      return !deletedRecurringRuleIds.contains(exception.ruleId);
    }).toList();

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

    _recurringRules = _recurringRules.map((rule) {
      if (rule.milestoneId != milestoneId) {
        return rule;
      }

      return rule.copyWith(milestoneId: null);
    }).toList();

    notifyListeners();

    _persist(_repository.deleteMilestoneAndMoveTasksToDirect(milestoneId));
  }

  void deleteMilestoneWithTasks(String milestoneId) {
    final deletedRecurringRuleIds = _recurringRules
        .where((rule) => rule.milestoneId == milestoneId)
        .map((rule) => rule.id)
        .toSet();

    _milestones = _milestones
        .where((milestone) => milestone.id != milestoneId)
        .toList();

    _tasks = _tasks.where((task) => task.milestoneId != milestoneId).toList();

    _recurringRules = _recurringRules
        .where((rule) => rule.milestoneId != milestoneId)
        .toList();

    _recurringExceptions = _recurringExceptions.where((exception) {
      return !deletedRecurringRuleIds.contains(exception.ruleId);
    }).toList();

    notifyListeners();

    _persist(_repository.deleteMilestoneWithTasks(milestoneId));
  }

  void addTask(PlannerTask task) {
    final result = _taskApplicationService.addTask(tasks: _tasks, task: task);

    _applyTaskMutationResult(result);
  }

  void addTaskForDate({
    required String title,
    required String description,
    required DateTime scheduledDate,
    String? goalId,
    String? milestoneId,
  }) {
    final task = _taskApplicationService.createTask(
      title: title,
      description: description,
      goalId: goalId,
      milestoneId: milestoneId,
      scheduledDate: scheduledDate,
    );

    addTask(task);
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

  void addRecurringTaskRule(RecurringTaskRule rule) {
    final result = _recurringTaskApplicationService.addRule(
      rule: rule,
      rules: _recurringRules,
      exceptions: _recurringExceptions,
      tasks: _tasks,
      today: todayDate(),
    );

    final ruleToPersist = result.ruleToPersist;

    if (ruleToPersist == null) {
      return;
    }

    _recurringRules = result.rules;
    _tasks = result.tasks;
    _recurringExceptions = result.exceptions;

    notifyListeners();

    _persist(
      _repository.saveRecurringTaskRuleWithOccurrences(
        rule: ruleToPersist,
        generatedTasks: result.generatedTasks,
      ),
    );
  }

  void setRecurringTaskRuleActive({
    required String ruleId,
    required bool isActive,
  }) {
    if (isActive) {
      _activateRecurringTaskRule(ruleId);
      return;
    }

    _deactivateRecurringTaskRule(ruleId);
  }

  void deleteRecurringTaskRule(String ruleId) {
    final result = _recurringTaskApplicationService.deleteRule(
      ruleId: ruleId,
      rules: _recurringRules,
      tasks: _tasks,
      exceptions: _recurringExceptions,
    );

    final ruleIdToDelete = result.ruleIdToDelete;

    if (ruleIdToDelete == null) {
      return;
    }

    _recurringRules = result.rules;
    _tasks = result.tasks;
    _recurringExceptions = result.exceptions;

    notifyListeners();

    _persist(_repository.deleteRecurringTaskRuleAndCleanSeries(ruleIdToDelete));
  }

  void updateRecurringTaskRule(RecurringTaskRule updatedRule) {
    final result = _recurringTaskApplicationService.updateRule(
      updatedRule: updatedRule,
      rules: _recurringRules,
      tasks: _tasks,
      exceptions: _recurringExceptions,
      today: todayDate(),
    );

    final ruleToPersist = result.ruleToPersist;

    if (ruleToPersist == null) {
      return;
    }

    _recurringRules = result.rules;
    _tasks = result.tasks;
    _recurringExceptions = result.exceptions;

    notifyListeners();

    _persist(
      _repository.updateRecurringTaskRuleAndReplaceUnfinishedOccurrences(
        rule: ruleToPersist,
        generatedTasks: result.generatedTasks,
      ),
    );
  }

  void _deleteRegularTask(String taskId) {
    final result = _taskApplicationService.deleteTask(
      tasks: _tasks,
      taskId: taskId,
    );

    _applyTaskMutationResult(result);
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

  void _deleteRecurringOccurrence(PlannerTask task) {
    final result = _recurringOccurrenceLifecycle.deleteOccurrence(
      task: task,
      tasks: _tasks,
      exceptions: _recurringExceptions,
      now: DateTime.now(),
    );

    final taskIdToDelete = result.taskIdToDelete;
    final exceptionToPersist = result.exceptionToPersist;

    if (taskIdToDelete == null || exceptionToPersist == null) {
      return;
    }

    _tasks = result.tasks;
    _recurringExceptions = result.exceptions;

    notifyListeners();

    _persist(
      _repository.deleteTaskWithRecurringException(
        taskId: taskIdToDelete,
        exception: exceptionToPersist,
      ),
    );
  }

  void _rescheduleRecurringOccurrence({
    required PlannerTask task,
    required DateTime scheduledDate,
  }) {
    final result = _recurringOccurrenceLifecycle.rescheduleOccurrence(
      task: task,
      scheduledDate: scheduledDate,
      tasks: _tasks,
      exceptions: _recurringExceptions,
      now: DateTime.now(),
    );

    final taskToPersist = result.taskToPersist;
    final exceptionToPersist = result.exceptionToPersist;

    if (taskToPersist == null || exceptionToPersist == null) {
      return;
    }

    _tasks = result.tasks;
    _recurringExceptions = result.exceptions;

    notifyListeners();

    _persist(
      _repository.updateTaskWithRecurringException(
        task: taskToPersist,
        exception: exceptionToPersist,
      ),
    );
  }

  void _unscheduleRecurringOccurrence(PlannerTask task) {
    final result = _recurringOccurrenceLifecycle.unscheduleOccurrence(
      task: task,
      tasks: _tasks,
      exceptions: _recurringExceptions,
      now: DateTime.now(),
    );

    final taskToPersist = result.taskToPersist;
    final exceptionToPersist = result.exceptionToPersist;

    if (taskToPersist == null || exceptionToPersist == null) {
      return;
    }

    _tasks = result.tasks;
    _recurringExceptions = result.exceptions;

    notifyListeners();

    _persist(
      _repository.updateTaskWithRecurringException(
        task: taskToPersist,
        exception: exceptionToPersist,
      ),
    );
  }

  void _deactivateRecurringTaskRule(String ruleId) {
    final result = _recurringTaskApplicationService.deactivateRule(
      ruleId: ruleId,
      rules: _recurringRules,
      tasks: _tasks,
      exceptions: _recurringExceptions,
    );

    final ruleToPersist = result.ruleToPersist;

    if (ruleToPersist == null) {
      return;
    }

    _recurringRules = result.rules;
    _tasks = result.tasks;
    _recurringExceptions = result.exceptions;

    notifyListeners();

    _persist(
      _repository.deactivateRecurringTaskRuleAndDeleteUnfinishedOccurrences(
        ruleToPersist,
      ),
    );
  }

  void _activateRecurringTaskRule(String ruleId) {
    final result = _recurringTaskApplicationService.activateRule(
      ruleId: ruleId,
      rules: _recurringRules,
      tasks: _tasks,
      exceptions: _recurringExceptions,
      today: todayDate(),
    );

    final ruleToPersist = result.ruleToPersist;

    if (ruleToPersist == null) {
      return;
    }

    _recurringRules = result.rules;
    _tasks = result.tasks;
    _recurringExceptions = result.exceptions;

    notifyListeners();

    _persist(
      _repository.saveRecurringTaskRuleWithOccurrences(
        rule: ruleToPersist,
        generatedTasks: result.generatedTasks,
      ),
    );
  }

  void updateTask({
    required String taskId,
    required String title,
    required String description,
  }) {
    final result = _taskApplicationService.updateTaskDetails(
      tasks: _tasks,
      taskId: taskId,
      title: title,
      description: description,
    );

    _applyTaskMutationResult(result);
  }

  void attachTaskToGoal({
    required String taskId,
    required String goalId,
    String? milestoneId,
  }) {
    final result = _taskApplicationService.attachTaskToGoal(
      tasks: _tasks,
      taskId: taskId,
      goalId: goalId,
      milestoneId: milestoneId,
    );

    _applyTaskMutationResult(result);
  }

  void detachTaskFromGoal(String taskId) {
    final result = _taskApplicationService.detachTaskFromGoal(
      tasks: _tasks,
      taskId: taskId,
    );

    _applyTaskMutationResult(result);
  }

  void toggleTaskCompleted(String taskId) {
    final result = _taskApplicationService.toggleTaskCompleted(
      tasks: _tasks,
      taskId: taskId,
    );

    _applyTaskMutationResult(result);
  }

  void completeTaskOnDate({
    required String taskId,
    required DateTime completedAt,
  }) {
    final result = _taskApplicationService.completeTaskOnDate(
      tasks: _tasks,
      taskId: taskId,
      completedAt: completedAt,
    );

    _applyTaskMutationResult(result);
  }

  void scheduleTaskForToday(String taskId) {
    scheduleTaskForDate(taskId: taskId, scheduledDate: todayDate());
  }

  void scheduleTaskForDate({
    required String taskId,
    required DateTime scheduledDate,
  }) {
    final taskToUpdate = _findTaskById(taskId);

    if (taskToUpdate == null) {
      return;
    }

    if (_isRecurringOccurrence(taskToUpdate)) {
      _rescheduleRecurringOccurrence(
        task: taskToUpdate,
        scheduledDate: scheduledDate,
      );
      return;
    }

    final result = _taskApplicationService.scheduleTaskForDate(
      tasks: _tasks,
      taskId: taskId,
      scheduledDate: scheduledDate,
    );

    _applyTaskMutationResult(result);
  }

  void unscheduleTask(String taskId) {
    final taskToUpdate = _findTaskById(taskId);

    if (taskToUpdate == null) {
      return;
    }

    if (_isRecurringOccurrence(taskToUpdate)) {
      _unscheduleRecurringOccurrence(taskToUpdate);
      return;
    }

    final result = _taskApplicationService.unscheduleTask(
      tasks: _tasks,
      taskId: taskId,
    );

    _applyTaskMutationResult(result);
  }

  void moveTaskToDirectGoal(String taskId) {
    final result = _taskApplicationService.moveTaskToDirectGoal(
      tasks: _tasks,
      taskId: taskId,
    );

    _applyTaskMutationResult(result);
  }

  void assignTaskToMilestone({
    required String taskId,
    required String milestoneId,
  }) {
    final result = _taskApplicationService.assignTaskToMilestone(
      tasks: _tasks,
      taskId: taskId,
      milestoneId: milestoneId,
    );

    _applyTaskMutationResult(result);
  }

  Future<void> _ensureUpcomingRecurringTaskOccurrences() async {
    final generatedTasks = _recurringTaskApplicationService
        .generateUpcomingOccurrences(
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

    final generatedTasks = _recurringTaskApplicationService
        .generateOccurrencesForRange(
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

  void _persist(Future<void> operation) {
    operation.catchError((Object error, StackTrace stackTrace) {
      debugPrint('Persistence error: $error');
      debugPrintStack(stackTrace: stackTrace);
    });
  }

  void _applyTaskMutationResult(TaskMutationResult result) {
    if (!result.hasChange) {
      return;
    }

    _tasks = result.tasks;
    notifyListeners();

    final taskToPersist = result.taskToPersist;
    if (taskToPersist != null) {
      _persist(_repository.saveTask(taskToPersist));
    }

    final taskIdToDelete = result.taskIdToDelete;
    if (taskIdToDelete != null) {
      _persist(_repository.deleteTask(taskIdToDelete));
    }
  }
}
