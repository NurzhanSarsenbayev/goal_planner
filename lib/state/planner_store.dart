import 'package:flutter/foundation.dart';

import '../features/goals/application/goal_store_coordinator.dart';
import '../features/milestones/application/milestone_store_coordinator.dart';
import '../features/tasks/application/task_store_coordinator.dart';
import '../features/planner/application/planner_initialization_service.dart';
import '../features/planner/application/planner_persistence_runner.dart';
import '../features/recurring/application/recurring_rule_store_coordinator.dart';
import '../features/recurring/application/recurring_occurrence_store_coordinator.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../models/recurring_task_exception.dart';
import '../models/recurring_task_rule.dart';
import '../shared/planner_dates.dart';

class PlannerStore extends ChangeNotifier {
  PlannerStore({
    required GoalStoreCoordinator goalStoreCoordinator,
    required MilestoneStoreCoordinator milestoneStoreCoordinator,
    required TaskStoreCoordinator taskStoreCoordinator,
    required PlannerInitializationService initializationService,
    required RecurringRuleStoreCoordinator recurringRuleStoreCoordinator,
    required RecurringOccurrenceStoreCoordinator
    recurringOccurrenceStoreCoordinator,
  }) : _goalStoreCoordinator = goalStoreCoordinator,
       _milestoneStoreCoordinator = milestoneStoreCoordinator,
       _taskStoreCoordinator = taskStoreCoordinator,
       _initializationService = initializationService,
       _recurringRuleStoreCoordinator = recurringRuleStoreCoordinator,
       _recurringOccurrenceStoreCoordinator =
           recurringOccurrenceStoreCoordinator;

  final GoalStoreCoordinator _goalStoreCoordinator;
  final MilestoneStoreCoordinator _milestoneStoreCoordinator;
  final TaskStoreCoordinator _taskStoreCoordinator;
  final PlannerInitializationService _initializationService;
  final PlannerPersistenceRunner _persistenceRunner =
      const PlannerPersistenceRunner();
  final RecurringRuleStoreCoordinator _recurringRuleStoreCoordinator;
  final RecurringOccurrenceStoreCoordinator
  _recurringOccurrenceStoreCoordinator;

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
    await reload();
  }

  Future<void> reload() async {
    final initialState = await _initializationService.initialize();

    _goals = initialState.goals;
    _milestones = initialState.milestones;
    _tasks = initialState.tasks;
    _recurringRules = initialState.recurringRules;
    _recurringExceptions = initialState.recurringExceptions;

    _isInitialized = true;
    notifyListeners();
  }

  void addGoal({required String title, required String description}) {
    final mutation = _goalStoreCoordinator.createGoal(
      goals: _goals,
      milestones: _milestones,
      tasks: _tasks,
      recurringRules: _recurringRules,
      recurringExceptions: _recurringExceptions,
      title: title,
      description: description,
    );

    _applyGoalStoreMutation(mutation);
  }

  void updateGoal({
    required String goalId,
    required String title,
    required String description,
  }) {
    final mutation = _goalStoreCoordinator.updateGoal(
      goals: _goals,
      milestones: _milestones,
      tasks: _tasks,
      recurringRules: _recurringRules,
      recurringExceptions: _recurringExceptions,
      goalId: goalId,
      title: title,
      description: description,
    );

    _applyGoalStoreMutation(mutation);
  }

  void deleteGoalWithRelatedData(String goalId) {
    final mutation = _goalStoreCoordinator.deleteGoalWithRelatedData(
      goalId: goalId,
      goals: _goals,
      milestones: _milestones,
      tasks: _tasks,
      recurringRules: _recurringRules,
      recurringExceptions: _recurringExceptions,
    );

    _applyGoalStoreMutation(mutation);
  }

  void addMilestone(Milestone milestone) {
    final mutation = _milestoneStoreCoordinator.addMilestone(
      milestones: _milestones,
      tasks: _tasks,
      recurringRules: _recurringRules,
      recurringExceptions: _recurringExceptions,
      milestone: milestone,
    );

    _applyMilestoneStoreMutation(mutation);
  }

  void updateMilestone({
    required String milestoneId,
    required String title,
    required String description,
  }) {
    final mutation = _milestoneStoreCoordinator.updateMilestone(
      milestones: _milestones,
      tasks: _tasks,
      recurringRules: _recurringRules,
      recurringExceptions: _recurringExceptions,
      milestoneId: milestoneId,
      title: title,
      description: description,
    );

    _applyMilestoneStoreMutation(mutation);
  }

  void deleteMilestoneAndMoveTasksToDirect(String milestoneId) {
    final mutation = _milestoneStoreCoordinator
        .deleteMilestoneAndMoveTasksToDirect(
          milestoneId: milestoneId,
          milestones: _milestones,
          tasks: _tasks,
          recurringRules: _recurringRules,
          recurringExceptions: _recurringExceptions,
        );

    _applyMilestoneStoreMutation(mutation);
  }

  void deleteMilestoneWithTasks(String milestoneId) {
    final mutation = _milestoneStoreCoordinator.deleteMilestoneWithTasks(
      milestoneId: milestoneId,
      milestones: _milestones,
      tasks: _tasks,
      recurringRules: _recurringRules,
      recurringExceptions: _recurringExceptions,
    );

    _applyMilestoneStoreMutation(mutation);
  }

  void addTask(PlannerTask task) {
    final mutation = _taskStoreCoordinator.addTask(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      task: task,
    );

    _applyTaskStoreMutation(mutation);
  }

  void addTaskForDate({
    required String title,
    required String description,
    required DateTime scheduledDate,
    String? goalId,
    String? milestoneId,
  }) {
    final mutation = _taskStoreCoordinator.addTaskForDate(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      goalId: goalId,
      milestoneId: milestoneId,
    );

    _applyTaskStoreMutation(mutation);
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
    final mutation = _recurringRuleStoreCoordinator.addRule(
      rule: rule,
      rules: _recurringRules,
      exceptions: _recurringExceptions,
      tasks: _tasks,
      today: todayDate(),
    );

    _applyRecurringRuleStoreMutation(mutation);
  }

  void setRecurringTaskRuleActive({
    required String ruleId,
    required bool isActive,
  }) {
    final mutation = isActive
        ? _recurringRuleStoreCoordinator.activateRule(
            ruleId: ruleId,
            rules: _recurringRules,
            exceptions: _recurringExceptions,
            tasks: _tasks,
            today: todayDate(),
          )
        : _recurringRuleStoreCoordinator.deactivateRule(
            ruleId: ruleId,
            rules: _recurringRules,
            exceptions: _recurringExceptions,
            tasks: _tasks,
          );

    _applyRecurringRuleStoreMutation(mutation);
  }

  void deleteRecurringTaskRule(String ruleId) {
    final mutation = _recurringRuleStoreCoordinator.deleteRule(
      ruleId: ruleId,
      rules: _recurringRules,
      exceptions: _recurringExceptions,
      tasks: _tasks,
    );

    _applyRecurringRuleStoreMutation(mutation);
  }

  void updateRecurringTaskRule(RecurringTaskRule updatedRule) {
    final mutation = _recurringRuleStoreCoordinator.updateRule(
      updatedRule: updatedRule,
      rules: _recurringRules,
      exceptions: _recurringExceptions,
      tasks: _tasks,
      today: todayDate(),
    );

    _applyRecurringRuleStoreMutation(mutation);
  }

  void deleteTask(String taskId) {
    final mutation = _taskStoreCoordinator.deleteTask(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
    );

    _applyTaskStoreMutation(mutation);
  }

  void updateTask({
    required String taskId,
    required String title,
    required String description,
  }) {
    final mutation = _taskStoreCoordinator.updateTask(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
      title: title,
      description: description,
    );

    _applyTaskStoreMutation(mutation);
  }

  void attachTaskToGoal({
    required String taskId,
    required String goalId,
    String? milestoneId,
  }) {
    final mutation = _taskStoreCoordinator.attachTaskToGoal(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
      goalId: goalId,
      milestoneId: milestoneId,
    );

    _applyTaskStoreMutation(mutation);
  }

  void detachTaskFromGoal(String taskId) {
    final mutation = _taskStoreCoordinator.detachTaskFromGoal(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
    );

    _applyTaskStoreMutation(mutation);
  }

  void toggleTaskCompleted(String taskId) {
    final mutation = _taskStoreCoordinator.toggleTaskCompleted(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
    );

    _applyTaskStoreMutation(mutation);
  }

  void completeTaskOnDate({
    required String taskId,
    required DateTime completedAt,
  }) {
    final mutation = _taskStoreCoordinator.completeTaskOnDate(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
      completedAt: completedAt,
    );

    _applyTaskStoreMutation(mutation);
  }

  void scheduleTaskForToday(String taskId) {
    scheduleTaskForDate(taskId: taskId, scheduledDate: todayDate());
  }

  void scheduleTaskForDate({
    required String taskId,
    required DateTime scheduledDate,
  }) {
    final mutation = _taskStoreCoordinator.scheduleTaskForDate(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
      scheduledDate: scheduledDate,
    );

    _applyTaskStoreMutation(mutation);
  }

  void unscheduleTask(String taskId) {
    final mutation = _taskStoreCoordinator.unscheduleTask(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
    );

    _applyTaskStoreMutation(mutation);
  }

  void moveTaskToDirectGoal(String taskId) {
    final mutation = _taskStoreCoordinator.moveTaskToDirectGoal(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
    );

    _applyTaskStoreMutation(mutation);
  }

  void assignTaskToMilestone({
    required String taskId,
    required String milestoneId,
  }) {
    final mutation = _taskStoreCoordinator.assignTaskToMilestone(
      tasks: _tasks,
      recurringExceptions: _recurringExceptions,
      taskId: taskId,
      milestoneId: milestoneId,
    );

    _applyTaskStoreMutation(mutation);
  }

  void ensureRecurringTaskOccurrencesForMonth(DateTime visibleMonth) {
    final mutation = _recurringOccurrenceStoreCoordinator
        .ensureOccurrencesForMonth(
          visibleMonth: visibleMonth,
          rules: _recurringRules,
          tasks: _tasks,
          exceptions: _recurringExceptions,
        );

    _applyRecurringOccurrenceStoreMutation(mutation);
  }

  void _applyGoalStoreMutation(GoalStoreMutation? mutation) {
    if (mutation == null) {
      return;
    }

    _goals = mutation.goals;
    _milestones = mutation.milestones;
    _tasks = mutation.tasks;
    _recurringRules = mutation.recurringRules;
    _recurringExceptions = mutation.recurringExceptions;

    notifyListeners();

    _persistenceRunner.run(mutation.persistOperation);
  }

  void _applyMilestoneStoreMutation(MilestoneStoreMutation? mutation) {
    if (mutation == null) {
      return;
    }

    _milestones = mutation.milestones;
    _tasks = mutation.tasks;
    _recurringRules = mutation.recurringRules;
    _recurringExceptions = mutation.recurringExceptions;

    notifyListeners();

    _persistenceRunner.run(mutation.persistOperation);
  }

  void _applyTaskStoreMutation(TaskStoreMutation? mutation) {
    if (mutation == null) {
      return;
    }

    _tasks = mutation.tasks;
    _recurringExceptions = mutation.recurringExceptions;

    notifyListeners();

    _persistenceRunner.run(mutation.persistOperation);
  }

  void _applyRecurringRuleStoreMutation(RecurringRuleStoreMutation? mutation) {
    if (mutation == null) {
      return;
    }

    _recurringRules = mutation.rules;
    _tasks = mutation.tasks;
    _recurringExceptions = mutation.exceptions;

    notifyListeners();

    _persistenceRunner.run(mutation.persistOperation);
  }

  void _applyRecurringOccurrenceStoreMutation(
    RecurringOccurrenceStoreMutation? mutation,
  ) {
    if (mutation == null) {
      return;
    }

    _tasks = mutation.tasks;
    _recurringExceptions = mutation.exceptions;

    notifyListeners();

    _persistenceRunner.run(mutation.persistOperation);
  }
}
