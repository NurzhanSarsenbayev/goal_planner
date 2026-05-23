import '../../../../models/planner_task.dart';
import 'task_reminder_scheduler.dart';

class TaskReminderApplicationService {
  const TaskReminderApplicationService({
    required TaskReminderScheduler taskReminderScheduler,
  }) : _taskReminderScheduler = taskReminderScheduler;

  final TaskReminderScheduler _taskReminderScheduler;

  Future<void> syncAfterTaskSaved(PlannerTask task) {
    return _taskReminderScheduler.syncTaskReminder(task);
  }

  Future<void> cancelAfterTaskDeleted(String taskId) {
    return _taskReminderScheduler.cancelTaskReminder(taskId);
  }
}
