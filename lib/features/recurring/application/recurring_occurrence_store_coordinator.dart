import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import '../../reminders/task/application/task_reminder_resync_service.dart';
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
    TaskReminderResyncService? taskReminderResyncService,
  }) : _recurringTaskRepository = recurringTaskRepository,
       _recurringTaskApplicationService =
           recurringTaskApplicationService ?? RecurringTaskApplicationService(),
       _taskReminderResyncService = taskReminderResyncService;

  final RecurringTaskRepository _recurringTaskRepository;
  final RecurringTaskApplicationService _recurringTaskApplicationService;
  final TaskReminderResyncService? _taskReminderResyncService;

  RecurringOccurrenceStoreMutation? ensureOccurrencesForMonth({
    required DateTime visibleMonth,
    required List<RecurringTaskRule> rules,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
  }) {
    final monthStart = DateTime(visibleMonth.year, visibleMonth.month);
    final monthEnd = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);

    final generatedTasks = _recurringTaskApplicationService
        .generateOccurrencesForRange(
          rules: rules,
          exceptions: exceptions,
          existingTasks: tasks,
          startDate: monthStart,
          endDate: monthEnd,
        );

    if (generatedTasks.isEmpty) {
      return null;
    }

    return RecurringOccurrenceStoreMutation(
      tasks: [...tasks, ...generatedTasks],
      exceptions: exceptions,
      persistOperation: () async {
        await _recurringTaskRepository.saveGeneratedOccurrences(generatedTasks);
        await _taskReminderResyncService?.syncTaskReminders(generatedTasks);
      },
    );
  }

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
      persistOperation: () async {
        await _recurringTaskRepository.deleteTaskWithRecurringException(
          taskId: taskIdToDelete,
          exception: exceptionToPersist,
        );

        await _syncTaskRemindersAfterTaskSetReplacement(
          previousTasks: tasks,
          currentTasks: result.tasks,
        );
      },
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
      persistOperation: () async {
        await _recurringTaskRepository.updateTaskWithRecurringException(
          task: taskToPersist,
          exception: exceptionToPersist,
        );

        await _syncTaskRemindersAfterTaskSetReplacement(
          previousTasks: tasks,
          currentTasks: result.tasks,
        );
      },
    );
  }

  RecurringOccurrenceStoreMutation? scheduleOccurrenceForDateAndTime({
    required PlannerTask task,
    required DateTime scheduledDate,
    required int? scheduledTimeMinutes,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final result = _recurringTaskApplicationService
        .scheduleOccurrenceForDateAndTime(
          task: task,
          scheduledDate: scheduledDate,
          scheduledTimeMinutes: scheduledTimeMinutes,
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
      persistOperation: () async {
        await _recurringTaskRepository.updateTaskWithRecurringException(
          task: taskToPersist,
          exception: exceptionToPersist,
        );

        await _syncTaskRemindersAfterTaskSetReplacement(
          previousTasks: tasks,
          currentTasks: result.tasks,
        );
      },
    );
  }

  RecurringOccurrenceStoreMutation? updateOccurrenceReminder({
    required PlannerTask task,
    required int? reminderMinutesBefore,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final result = _recurringTaskApplicationService.updateOccurrenceReminder(
      task: task,
      reminderMinutesBefore: reminderMinutesBefore,
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
      persistOperation: () async {
        await _recurringTaskRepository.updateTaskWithRecurringException(
          task: taskToPersist,
          exception: exceptionToPersist,
        );

        await _syncTaskRemindersAfterTaskSetReplacement(
          previousTasks: tasks,
          currentTasks: result.tasks,
        );
      },
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
      persistOperation: () async {
        await _recurringTaskRepository.updateTaskWithRecurringException(
          task: taskToPersist,
          exception: exceptionToPersist,
        );

        await _syncTaskRemindersAfterTaskSetReplacement(
          previousTasks: tasks,
          currentTasks: result.tasks,
        );
      },
    );
  }

  Future<void> _syncTaskRemindersAfterTaskSetReplacement({
    required Iterable<PlannerTask> previousTasks,
    required Iterable<PlannerTask> currentTasks,
  }) async {
    await _taskReminderResyncService?.syncAfterTaskSetReplacement(
      previousTasks: previousTasks,
      currentTasks: currentTasks,
    );
  }
}
