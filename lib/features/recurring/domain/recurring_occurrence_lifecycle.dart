import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../shared/planner_dates.dart';

class RecurringOccurrenceLifecycleResult {
  const RecurringOccurrenceLifecycleResult({
    required this.tasks,
    required this.exceptions,
    this.taskToPersist,
    this.exceptionToPersist,
    this.taskIdToDelete,
  });

  final List<PlannerTask> tasks;
  final List<RecurringTaskException> exceptions;
  final PlannerTask? taskToPersist;
  final RecurringTaskException? exceptionToPersist;
  final String? taskIdToDelete;
}

class RecurringOccurrenceLifecycle {
  RecurringOccurrenceLifecycleResult deleteOccurrence({
    required PlannerTask task,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final recurringRuleId = task.recurringRuleId;
    final scheduledDate = task.scheduledDate;

    if (recurringRuleId == null || scheduledDate == null) {
      return RecurringOccurrenceLifecycleResult(
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final exception = _createException(
      ruleId: recurringRuleId,
      date: scheduledDate,
      now: now,
    );

    return RecurringOccurrenceLifecycleResult(
      tasks: _removeTaskById(tasks: tasks, taskId: task.id),
      exceptions: _addExceptionIfMissing(
        exceptions: exceptions,
        exception: exception,
      ),
      exceptionToPersist: exception,
      taskIdToDelete: task.id,
    );
  }

  RecurringOccurrenceLifecycleResult rescheduleOccurrence({
    required PlannerTask task,
    required DateTime scheduledDate,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final recurringRuleId = task.recurringRuleId;
    final oldScheduledDate = task.scheduledDate;

    if (recurringRuleId == null || oldScheduledDate == null) {
      return RecurringOccurrenceLifecycleResult(
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final normalizedOldDate = dateOnly(oldScheduledDate);
    final normalizedNewDate = dateOnly(scheduledDate);

    if (normalizedOldDate == normalizedNewDate) {
      return RecurringOccurrenceLifecycleResult(
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final exception = _createException(
      ruleId: recurringRuleId,
      date: normalizedOldDate,
      now: now,
    );

    final updatedTask = task
        .scheduleForDate(normalizedNewDate)
        .copyWith(recurringRuleId: null);

    return RecurringOccurrenceLifecycleResult(
      tasks: _replaceTask(tasks: tasks, updatedTask: updatedTask),
      exceptions: _addExceptionIfMissing(
        exceptions: exceptions,
        exception: exception,
      ),
      taskToPersist: updatedTask,
      exceptionToPersist: exception,
    );
  }

  RecurringOccurrenceLifecycleResult scheduleOccurrenceForDateAndTime({
    required PlannerTask task,
    required DateTime scheduledDate,
    required int? scheduledTimeMinutes,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final recurringRuleId = task.recurringRuleId;
    final oldScheduledDate = task.scheduledDate;

    if (recurringRuleId == null || oldScheduledDate == null) {
      return RecurringOccurrenceLifecycleResult(
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final normalizedOldDate = dateOnly(oldScheduledDate);
    final normalizedNewDate = dateOnly(scheduledDate);

    if (normalizedOldDate == normalizedNewDate &&
        task.scheduledTimeMinutes == scheduledTimeMinutes) {
      return RecurringOccurrenceLifecycleResult(
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final exception = _createException(
      ruleId: recurringRuleId,
      date: normalizedOldDate,
      now: now,
    );

    final updatedTask = task
        .scheduleForDateAndTime(
          date: normalizedNewDate,
          timeMinutes: scheduledTimeMinutes,
        )
        .copyWith(recurringRuleId: null);

    return RecurringOccurrenceLifecycleResult(
      tasks: _replaceTask(tasks: tasks, updatedTask: updatedTask),
      exceptions: _addExceptionIfMissing(
        exceptions: exceptions,
        exception: exception,
      ),
      taskToPersist: updatedTask,
      exceptionToPersist: exception,
    );
  }

  RecurringOccurrenceLifecycleResult updateOccurrenceReminder({
    required PlannerTask task,
    required int? reminderMinutesBefore,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final recurringRuleId = task.recurringRuleId;
    final scheduledDate = task.scheduledDate;

    if (recurringRuleId == null || scheduledDate == null) {
      return RecurringOccurrenceLifecycleResult(
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    if (task.reminderMinutesBefore == reminderMinutesBefore) {
      return RecurringOccurrenceLifecycleResult(
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final exception = _createException(
      ruleId: recurringRuleId,
      date: scheduledDate,
      now: now,
    );

    final updatedTask = task
        .setReminder(reminderMinutesBefore)
        .copyWith(recurringRuleId: null);

    return RecurringOccurrenceLifecycleResult(
      tasks: _replaceTask(tasks: tasks, updatedTask: updatedTask),
      exceptions: _addExceptionIfMissing(
        exceptions: exceptions,
        exception: exception,
      ),
      taskToPersist: updatedTask,
      exceptionToPersist: exception,
    );
  }

  RecurringOccurrenceLifecycleResult unscheduleOccurrence({
    required PlannerTask task,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    final recurringRuleId = task.recurringRuleId;
    final scheduledDate = task.scheduledDate;

    if (recurringRuleId == null || scheduledDate == null) {
      return RecurringOccurrenceLifecycleResult(
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final exception = _createException(
      ruleId: recurringRuleId,
      date: scheduledDate,
      now: now,
    );

    final updatedTask = task.unschedule().copyWith(recurringRuleId: null);

    return RecurringOccurrenceLifecycleResult(
      tasks: _replaceTask(tasks: tasks, updatedTask: updatedTask),
      exceptions: _addExceptionIfMissing(
        exceptions: exceptions,
        exception: exception,
      ),
      taskToPersist: updatedTask,
      exceptionToPersist: exception,
    );
  }

  RecurringTaskException _createException({
    required String ruleId,
    required DateTime date,
    required DateTime now,
  }) {
    return RecurringTaskException(
      id: recurringTaskExceptionId(ruleId: ruleId, date: date),
      ruleId: ruleId,
      date: date,
      createdAt: now,
    );
  }

  List<RecurringTaskException> _addExceptionIfMissing({
    required List<RecurringTaskException> exceptions,
    required RecurringTaskException exception,
  }) {
    final alreadyExists = exceptions.any(
      (existingException) => existingException.matches(
        ruleId: exception.ruleId,
        date: exception.date,
      ),
    );

    if (alreadyExists) {
      return exceptions;
    }

    return [...exceptions, exception];
  }

  List<PlannerTask> _removeTaskById({
    required List<PlannerTask> tasks,
    required String taskId,
  }) {
    return tasks.where((task) => task.id != taskId).toList();
  }

  List<PlannerTask> _replaceTask({
    required List<PlannerTask> tasks,
    required PlannerTask updatedTask,
  }) {
    return tasks.map((task) {
      if (task.id != updatedTask.id) {
        return task;
      }

      return updatedTask;
    }).toList();
  }
}
