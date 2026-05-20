import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../recurring/application/recurring_occurrence_store_coordinator.dart';
import 'task_application_service.dart';
import 'task_repository.dart';

class TaskStoreMutation {
  const TaskStoreMutation({
    required this.tasks,
    required this.recurringExceptions,
    required this.persistOperation,
  });

  final List<PlannerTask> tasks;
  final List<RecurringTaskException> recurringExceptions;
  final Future<void> Function() persistOperation;
}

class TaskStoreCoordinator {
  TaskStoreCoordinator({
    required TaskRepository taskRepository,
    required RecurringOccurrenceStoreCoordinator
    recurringOccurrenceStoreCoordinator,
    TaskApplicationService? taskApplicationService,
  }) : _taskRepository = taskRepository,
       _recurringOccurrenceStoreCoordinator =
           recurringOccurrenceStoreCoordinator,
       _taskApplicationService =
           taskApplicationService ?? const TaskApplicationService();

  final TaskRepository _taskRepository;
  final RecurringOccurrenceStoreCoordinator
  _recurringOccurrenceStoreCoordinator;
  final TaskApplicationService _taskApplicationService;

  TaskStoreMutation? addTask({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required PlannerTask task,
  }) {
    final result = _taskApplicationService.addTask(tasks: tasks, task: task);

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? addTaskForDate({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String title,
    required String description,
    required DateTime scheduledDate,
    int? scheduledTimeMinutes,
    String? goalId,
    String? milestoneId,
  }) {
    final task = _taskApplicationService.createTask(
      title: title,
      description: description,
      goalId: goalId,
      milestoneId: milestoneId,
      scheduledDate: scheduledDate,
      scheduledTimeMinutes: scheduledTimeMinutes,
    );

    return addTask(
      tasks: tasks,
      recurringExceptions: recurringExceptions,
      task: task,
    );
  }

  TaskStoreMutation? deleteTask({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
    DateTime? now,
  }) {
    final taskToDelete = _findTaskById(tasks: tasks, taskId: taskId);

    if (taskToDelete == null) {
      return null;
    }

    if (_isRecurringOccurrence(taskToDelete)) {
      return _recurringOccurrenceMutation(
        _recurringOccurrenceStoreCoordinator.deleteOccurrence(
          task: taskToDelete,
          tasks: tasks,
          exceptions: recurringExceptions,
          now: now ?? DateTime.now(),
        ),
      );
    }

    final result = _taskApplicationService.deleteTask(
      tasks: tasks,
      taskId: taskId,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? updateTask({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
    required String title,
    required String description,
  }) {
    final result = _taskApplicationService.updateTaskDetails(
      tasks: tasks,
      taskId: taskId,
      title: title,
      description: description,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? attachTaskToGoal({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
    required String goalId,
    String? milestoneId,
  }) {
    final result = _taskApplicationService.attachTaskToGoal(
      tasks: tasks,
      taskId: taskId,
      goalId: goalId,
      milestoneId: milestoneId,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? detachTaskFromGoal({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
  }) {
    final result = _taskApplicationService.detachTaskFromGoal(
      tasks: tasks,
      taskId: taskId,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? toggleTaskCompleted({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
  }) {
    final result = _taskApplicationService.toggleTaskCompleted(
      tasks: tasks,
      taskId: taskId,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? completeTaskOnDate({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
    required DateTime completedAt,
  }) {
    final result = _taskApplicationService.completeTaskOnDate(
      tasks: tasks,
      taskId: taskId,
      completedAt: completedAt,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? scheduleTaskForDate({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
    required DateTime scheduledDate,
    DateTime? now,
  }) {
    final taskToUpdate = _findTaskById(tasks: tasks, taskId: taskId);

    if (taskToUpdate == null) {
      return null;
    }

    if (_isRecurringOccurrence(taskToUpdate)) {
      return _recurringOccurrenceMutation(
        _recurringOccurrenceStoreCoordinator.rescheduleOccurrence(
          task: taskToUpdate,
          scheduledDate: scheduledDate,
          tasks: tasks,
          exceptions: recurringExceptions,
          now: now ?? DateTime.now(),
        ),
      );
    }
    final result = _taskApplicationService.scheduleTaskForDate(
      tasks: tasks,
      taskId: taskId,
      scheduledDate: scheduledDate,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? scheduleTaskForDateAndTime({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
    required DateTime scheduledDate,
    required int? scheduledTimeMinutes,
  }) {
    final taskToUpdate = _findTaskById(tasks: tasks, taskId: taskId);

    if (taskToUpdate == null) {
      return null;
    }

    if (_isRecurringOccurrence(taskToUpdate)) {
      return null;
    }

    final result = _taskApplicationService.scheduleTaskForDateAndTime(
      tasks: tasks,
      taskId: taskId,
      scheduledDate: scheduledDate,
      scheduledTimeMinutes: scheduledTimeMinutes,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? unscheduleTask({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
    DateTime? now,
  }) {
    final taskToUpdate = _findTaskById(tasks: tasks, taskId: taskId);

    if (taskToUpdate == null) {
      return null;
    }

    if (_isRecurringOccurrence(taskToUpdate)) {
      return _recurringOccurrenceMutation(
        _recurringOccurrenceStoreCoordinator.unscheduleOccurrence(
          task: taskToUpdate,
          tasks: tasks,
          exceptions: recurringExceptions,
          now: now ?? DateTime.now(),
        ),
      );
    }

    final result = _taskApplicationService.unscheduleTask(
      tasks: tasks,
      taskId: taskId,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? moveTaskToDirectGoal({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
  }) {
    final result = _taskApplicationService.moveTaskToDirectGoal(
      tasks: tasks,
      taskId: taskId,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? assignTaskToMilestone({
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> recurringExceptions,
    required String taskId,
    required String milestoneId,
  }) {
    final result = _taskApplicationService.assignTaskToMilestone(
      tasks: tasks,
      taskId: taskId,
      milestoneId: milestoneId,
    );

    return _regularTaskMutation(
      result,
      recurringExceptions: recurringExceptions,
    );
  }

  TaskStoreMutation? _regularTaskMutation(
    TaskMutationResult result, {
    required List<RecurringTaskException> recurringExceptions,
  }) {
    if (!result.hasChange) {
      return null;
    }

    final taskToPersist = result.taskToPersist;
    final taskIdToDelete = result.taskIdToDelete;

    return TaskStoreMutation(
      tasks: result.tasks,
      recurringExceptions: recurringExceptions,
      persistOperation: () async {
        if (taskToPersist != null) {
          await _taskRepository.saveTask(taskToPersist);
        }

        if (taskIdToDelete != null) {
          await _taskRepository.deleteTask(taskIdToDelete);
        }
      },
    );
  }

  TaskStoreMutation? _recurringOccurrenceMutation(
    RecurringOccurrenceStoreMutation? mutation,
  ) {
    if (mutation == null) {
      return null;
    }

    return TaskStoreMutation(
      tasks: mutation.tasks,
      recurringExceptions: mutation.exceptions,
      persistOperation: mutation.persistOperation,
    );
  }

  PlannerTask? _findTaskById({
    required List<PlannerTask> tasks,
    required String taskId,
  }) {
    for (final task in tasks) {
      if (task.id == taskId) {
        return task;
      }
    }

    return null;
  }

  bool _isRecurringOccurrence(PlannerTask task) {
    return task.recurringRuleId != null && task.scheduledDate != null;
  }
}
