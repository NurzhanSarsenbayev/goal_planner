import '../../../models/planner_task.dart';
import 'local_notification_service.dart';
import 'task_reminder_resync_service.dart';

class TaskReminderLifecycleService {
  const TaskReminderLifecycleService({
    required LocalNotificationService notifications,
    required TaskReminderResyncService taskReminderResyncService,
  }) : _notifications = notifications,
       _taskReminderResyncService = taskReminderResyncService;

  final LocalNotificationService _notifications;
  final TaskReminderResyncService _taskReminderResyncService;

  Future<void> initializeAndSyncTaskReminders(
    Iterable<PlannerTask> tasks,
  ) async {
    await initializeTaskReminderNotifications();
    await _taskReminderResyncService.syncTaskReminders(tasks);
  }

  Future<void> syncAfterTaskSetReplacement({
    required Iterable<PlannerTask> previousTasks,
    required Iterable<PlannerTask> currentTasks,
  }) async {
    await initializeTaskReminderNotifications();

    await _taskReminderResyncService.syncAfterTaskSetReplacement(
      previousTasks: previousTasks,
      currentTasks: currentTasks,
    );
  }

  Future<void> initializeTaskReminderNotifications() async {
    await _notifications.initialize();
    await _notifications.requestTaskReminderPermissions();
  }

  Future<void> initializeNotifications() {
    return _notifications.initialize();
  }

  Future<bool> requestNotificationPermission() {
    return _notifications.requestNotificationPermission();
  }

  Future<void> showTestNotification() {
    return _notifications.showTestNotification();
  }
}
