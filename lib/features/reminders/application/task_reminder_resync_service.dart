import '../../../models/planner_task.dart';
import 'task_reminder_scheduler.dart';

class TaskReminderResyncService {
  const TaskReminderResyncService({
    required TaskReminderScheduler taskReminderScheduler,
  }) : _taskReminderScheduler = taskReminderScheduler;

  final TaskReminderScheduler _taskReminderScheduler;

  Future<void> syncTaskReminders(Iterable<PlannerTask> tasks) async {
    for (final task in tasks) {
      await _taskReminderScheduler.syncTaskReminder(task);
    }
  }
}
