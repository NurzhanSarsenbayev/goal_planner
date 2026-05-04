import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import 'recurring_task_application_service.dart';
import 'recurring_task_repository.dart';

class RecurringOccurrenceStoreMutation {
  const RecurringOccurrenceStoreMutation({
    required this.tasks,
    required this.exceptions,
    required this.persistOperation,
  });

  final List<PlannerTask> tasks;
  final List<RecurringTaskException> exceptions;
  final Future<void> Function() persistOperation;
}

class RecurringOccurrenceStoreCoordinator {
  RecurringOccurrenceStoreCoordinator({
    required RecurringTaskRepository recurringTaskRepository,
    RecurringTaskApplicationService? recurringTaskApplicationService,
  }) : _recurringTaskRepository = recurringTaskRepository,
       _recurringTaskApplicationService =
           recurringTaskApplicationService ?? RecurringTaskApplicationService();

  final RecurringTaskRepository _recurringTaskRepository;
  final RecurringTaskApplicationService _recurringTaskApplicationService;

  RecurringOccurrenceStoreMutation? deleteOccurrence({
    required PlannerTask task,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final result = _recurringTaskApplicationService.deleteOccurrence(
      task: task,
      tasks: tasks,
      exceptions: exceptions,
      now: now,
    );

    final taskIdToDelete = result.taskIdToDelete;
    final exceptionToPersist = result.exceptionToPersist;

    if (taskIdToDelete == null || exceptionToPersist == null) {
      return null;
    }

    return RecurringOccurrenceStoreMutation(
      tasks: result.tasks,
      exceptions: result.exceptions,
      persistOperation: () =>
          _recurringTaskRepository.deleteTaskWithRecurringException(
            taskId: taskIdToDelete,
            exception: exceptionToPersist,
          ),
    );
  }

  RecurringOccurrenceStoreMutation? rescheduleOccurrence({
    required PlannerTask task,
    required DateTime scheduledDate,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final result = _recurringTaskApplicationService.rescheduleOccurrence(
      task: task,
      scheduledDate: scheduledDate,
      tasks: tasks,
      exceptions: exceptions,
      now: now,
    );

    final taskToPersist = result.taskToPersist;
    final exceptionToPersist = result.exceptionToPersist;

    if (taskToPersist == null || exceptionToPersist == null) {
      return null;
    }

    return RecurringOccurrenceStoreMutation(
      tasks: result.tasks,
      exceptions: result.exceptions,
      persistOperation: () =>
          _recurringTaskRepository.updateTaskWithRecurringException(
            task: taskToPersist,
            exception: exceptionToPersist,
          ),
    );
  }

  RecurringOccurrenceStoreMutation? unscheduleOccurrence({
    required PlannerTask task,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final result = _recurringTaskApplicationService.unscheduleOccurrence(
      task: task,
      tasks: tasks,
      exceptions: exceptions,
      now: now,
    );

    final taskToPersist = result.taskToPersist;
    final exceptionToPersist = result.exceptionToPersist;

    if (taskToPersist == null || exceptionToPersist == null) {
      return null;
    }

    return RecurringOccurrenceStoreMutation(
      tasks: result.tasks,
      exceptions: result.exceptions,
      persistOperation: () =>
          _recurringTaskRepository.updateTaskWithRecurringException(
            task: taskToPersist,
            exception: exceptionToPersist,
          ),
    );
  }
}
