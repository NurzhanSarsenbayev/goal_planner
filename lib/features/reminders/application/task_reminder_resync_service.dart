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

  Future<void> syncAfterTaskSetReplacement({
    required Iterable<PlannerTask> previousTasks,
    required Iterable<PlannerTask> currentTasks,
  }) async {
    final currentTaskIds = currentTasks.map((task) => task.id).toSet();

    for (final previousTask in previousTasks) {
      if (!currentTaskIds.contains(previousTask.id)) {
        await _taskReminderScheduler.cancelTaskReminder(previousTask.id);
      }
    }

    await syncTaskReminders(currentTasks);
  }
}
