import '../../../models/recurring_task_exception.dart';
import '../../recurring/application/recurring_occurrence_store_coordinator.dart';
import '../../reminders/task/application/task_reminder_application_service.dart';
import 'task_application_service.dart';
import 'task_repository.dart';
import 'task_store_mutation.dart';

class TaskStoreMutationFactory {
  const TaskStoreMutationFactory({
    required TaskRepository taskRepository,
    TaskReminderApplicationService? taskReminderApplicationService,
  }) : _taskRepository = taskRepository,
       _taskReminderApplicationService = taskReminderApplicationService;

  final TaskRepository _taskRepository;
  final TaskReminderApplicationService? _taskReminderApplicationService;

  TaskStoreMutation? regularTaskMutation(
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
          await _taskReminderApplicationService?.syncAfterTaskSaved(
            taskToPersist,
          );
        }

        if (taskIdToDelete != null) {
          await _taskRepository.deleteTask(taskIdToDelete);
          await _taskReminderApplicationService?.cancelAfterTaskDeleted(
            taskIdToDelete,
          );
        }
      },
    );
  }

  TaskStoreMutation? recurringOccurrenceMutation(
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
}
