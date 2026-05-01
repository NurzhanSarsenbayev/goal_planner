import 'package:flutter/foundation.dart';

import '../features/goals/application/goal_repository.dart';
import '../features/goals/application/goal_application_service.dart';
import '../features/milestones/application/milestone_repository.dart';
import '../features/milestones/application/milestone_application_service.dart';
import '../features/tasks/application/task_application_service.dart';
import '../features/tasks/application/task_repository.dart';
import '../features/recurring/application/recurring_task_application_service.dart';
import '../features/recurring/application/recurring_task_repository.dart';
import '../features/planner/application/planner_cleanup_repository.dart';
import 'planner_seed_service.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../models/recurring_task_exception.dart';
import '../models/recurring_task_rule.dart';
import '../shared/planner_dates.dart';

class PlannerStore extends ChangeNotifier {
  PlannerStore(
    PlannerCleanupRepository cleanupRepository,
    GoalRepository goalRepository,
    MilestoneRepository milestoneRepository,
    TaskRepository taskRepository,
    RecurringTaskRepository recurringTaskRepository,
  ) : _cleanupRepository = cleanupRepository,
      _goalRepository = goalRepository,
      _milestoneRepository = milestoneRepository,
      _taskRepository = taskRepository,
      _recurringTaskRepository = recurringTaskRepository,
      _seedService = PlannerSeedService(
        goalRepository: goalRepository,
        milestoneRepository: milestoneRepository,
        taskRepository: taskRepository,
      );

  final PlannerCleanupRepository _cleanupRepository;
  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;
  final RecurringTaskRepository _recurringTaskRepository;
  final PlannerSeedService _seedService;

  final TaskApplicationService _taskApplicationService =
      const TaskApplicationService();
  final GoalApplicationService _goalApplicationService =
      const GoalApplicationService();
  final MilestoneApplicationService _milestoneApplicationService =
      const MilestoneApplicationService();
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
    _goals = await _goalRepository.loadGoals();
    _milestones = await _milestoneRepository.loadMilestones();
    _tasks = await _taskRepository.loadTasks();
    _recurringRules = await _recurringTaskRepository.loadRecurringTaskRules();
    _recurringExceptions = await _recurringTaskRepository
        .loadRecurringTaskExceptions();
  }

  void addGoal({required String title, required String description}) {
    final result = _goalApplicationService.createGoal(
      goals: _goals,
      title: title,
      description: description,
    );

    _applyGoalMutationResult(result);
  }

  void updateGoal({
    required String goalId,
    required String title,
    required String description,
  }) {
    final result = _goalApplicationService.updateGoalDetails(
      goals: _goals,
      goalId: goalId,
      title: title,
      description: description,
    );

    _applyGoalMutationResult(result);
  }

  void deleteGoalWithRelatedData(String goalId) {
    final result = _goalApplicationService.deleteGoalWithRelatedData(
      goalId: goalId,
      goals: _goals,
      milestones: _milestones,
      tasks: _tasks,
      recurringRules: _recurringRules,
      recurringExceptions: _recurringExceptions,
    );

    _goals = result.goals;
    _milestones = result.milestones;
    _tasks = result.tasks;
    _recurringRules = result.recurringRules;
    _recurringExceptions = result.recurringExceptions;

    notifyListeners();

    _persist(
      _cleanupRepository.deleteGoalWithRelatedData(result.goalIdToDelete),
    );
  }

  void addMilestone(Milestone milestone) {
    final result = _milestoneApplicationService.addMilestone(
      milestones: _milestones,
      milestone: milestone,
    );

    _applyMilestoneMutationResult(result);
  }

  void updateMilestone({
    required String milestoneId,
    required String title,
    required String description,
  }) {
    final result = _milestoneApplicationService.updateMilestoneDetails(
      milestones: _milestones,
      milestoneId: milestoneId,
      title: title,
      description: description,
    );

    _applyMilestoneMutationResult(result);
  }

  void deleteMilestoneAndMoveTasksToDirect(String milestoneId) {
    final result = _milestoneApplicationService
        .deleteMilestoneAndMoveTasksToDirect(
          milestoneId: milestoneId,
          milestones: _milestones,
          tasks: _tasks,
          recurringRules: _recurringRules,
        );

    _milestones = result.milestones;
    _tasks = result.tasks;
    _recurringRules = result.recurringRules;

    notifyListeners();

    _persist(
      _cleanupRepository.deleteMilestoneAndMoveTasksToDirect(
        result.milestoneIdToDelete,
      ),
    );
  }

  void deleteMilestoneWithTasks(String milestoneId) {
    final result = _milestoneApplicationService.deleteMilestoneWithTasks(
      milestoneId: milestoneId,
      milestones: _milestones,
      tasks: _tasks,
      recurringRules: _recurringRules,
      recurringExceptions: _recurringExceptions,
    );

    _milestones = result.milestones;
    _tasks = result.tasks;
    _recurringRules = result.recurringRules;
    _recurringExceptions = result.recurringExceptions;

    notifyListeners();

    _persist(
      _cleanupRepository.deleteMilestoneWithTasks(result.milestoneIdToDelete),
    );
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
      _recurringTaskRepository.saveRecurringTaskRuleWithOccurrences(
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

    _persist(
      _recurringTaskRepository.deleteRecurringTaskRuleAndCleanSeries(
        ruleIdToDelete,
      ),
    );
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
      _recurringTaskRepository
          .updateRecurringTaskRuleAndReplaceUnfinishedOccurrences(
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
    final result = _recurringTaskApplicationService.deleteOccurrence(
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
      _recurringTaskRepository.deleteTaskWithRecurringException(
        taskId: taskIdToDelete,
        exception: exceptionToPersist,
      ),
    );
  }

  void _rescheduleRecurringOccurrence({
    required PlannerTask task,
    required DateTime scheduledDate,
  }) {
    final result = _recurringTaskApplicationService.rescheduleOccurrence(
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
      _recurringTaskRepository.updateTaskWithRecurringException(
        task: taskToPersist,
        exception: exceptionToPersist,
      ),
    );
  }

  void _unscheduleRecurringOccurrence(PlannerTask task) {
    final result = _recurringTaskApplicationService.unscheduleOccurrence(
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
      _recurringTaskRepository.updateTaskWithRecurringException(
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
      _recurringTaskRepository
          .deactivateRecurringTaskRuleAndDeleteUnfinishedOccurrences(
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
      _recurringTaskRepository.saveRecurringTaskRuleWithOccurrences(
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

    await _recurringTaskRepository.saveGeneratedOccurrences(generatedTasks);
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

    _persist(_recurringTaskRepository.saveGeneratedOccurrences(generatedTasks));
  }

  void _persist(Future<void> operation) {
    operation.catchError((Object error, StackTrace stackTrace) {
      debugPrint('Persistence error: $error');
      debugPrintStack(stackTrace: stackTrace);
    });
  }

  void _applyGoalMutationResult(GoalMutationResult result) {
    if (!result.hasChange) {
      return;
    }

    _goals = result.goals;
    notifyListeners();

    final goalToPersist = result.goalToPersist;
    if (goalToPersist != null) {
      _persist(_goalRepository.saveGoal(goalToPersist));
    }
  }

  void _applyMilestoneMutationResult(MilestoneMutationResult result) {
    if (!result.hasChange) {
      return;
    }

    _milestones = result.milestones;
    notifyListeners();

    final milestoneToPersist = result.milestoneToPersist;
    if (milestoneToPersist != null) {
      _persist(_milestoneRepository.saveMilestone(milestoneToPersist));
    }
  }

  void _applyTaskMutationResult(TaskMutationResult result) {
    if (!result.hasChange) {
      return;
    }

    _tasks = result.tasks;
    notifyListeners();

    final taskToPersist = result.taskToPersist;
    if (taskToPersist != null) {
      _persist(_taskRepository.saveTask(taskToPersist));
    }

    final taskIdToDelete = result.taskIdToDelete;
    if (taskIdToDelete != null) {
      _persist(_taskRepository.deleteTask(taskIdToDelete));
    }
  }
}
