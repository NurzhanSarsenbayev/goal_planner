import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/recurring/application/recurring_occurrence_store_coordinator.dart';
import 'package:goal_planner/features/recurring/application/recurring_task_repository.dart';
import 'package:goal_planner/features/reminders/application/task_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/application/task_reminder_application_service.dart';
import 'package:goal_planner/features/tasks/application/task_repository.dart';
import 'package:goal_planner/features/tasks/application/task_store_coordinator.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_exception.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('TaskStoreCoordinator reminders', () {
    test('syncs reminder after saving regular task', () async {
      final taskRepository = FakeTaskRepository();
      final notifications = FakeTaskReminderNotificationClient();
      final coordinator = _createCoordinator(
        taskRepository: taskRepository,
        notifications: notifications,
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      final mutation = coordinator.addTask(
        tasks: const [],
        recurringExceptions: const [],
        task: task,
      );

      expect(mutation, isNotNull);

      await mutation!.persistOperation();

      final expectedNotificationId = taskReminderNotificationId(task.id);

      expect(taskRepository.savedTasks, [task]);
      expect(taskRepository.deletedTaskIds, isEmpty);
      expect(notifications.canceledIds, [expectedNotificationId]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.id,
        expectedNotificationId,
      );
      expect(notifications.scheduledReminders.single.title, 'Plan day');
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 20, 9, 15),
      );
    });

    test('passes reminder minutes when creating task for date', () async {
      final taskRepository = FakeTaskRepository();
      final notifications = FakeTaskReminderNotificationClient();
      final coordinator = _createCoordinator(
        taskRepository: taskRepository,
        notifications: notifications,
      );

      final mutation = coordinator.addTaskForDate(
        tasks: const [],
        recurringExceptions: const [],
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
      );

      expect(mutation, isNotNull);

      await mutation!.persistOperation();

      expect(taskRepository.savedTasks, hasLength(1));
      expect(taskRepository.savedTasks.single.reminderMinutesBefore, 15);
      expect(notifications.scheduledReminders, hasLength(1));
    });

    test('cancels reminder after deleting regular task', () async {
      final taskRepository = FakeTaskRepository();
      final notifications = FakeTaskReminderNotificationClient();
      final coordinator = _createCoordinator(
        taskRepository: taskRepository,
        notifications: notifications,
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      final mutation = coordinator.deleteTask(
        tasks: [task],
        recurringExceptions: const [],
        taskId: task.id,
      );

      expect(mutation, isNotNull);

      await mutation!.persistOperation();

      expect(taskRepository.savedTasks, isEmpty);
      expect(taskRepository.deletedTaskIds, [task.id]);
      expect(notifications.canceledIds, [taskReminderNotificationId(task.id)]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('syncs reminder after updating task reminder', () async {
      final taskRepository = FakeTaskRepository();
      final notifications = FakeTaskReminderNotificationClient();
      final coordinator = _createCoordinator(
        taskRepository: taskRepository,
        notifications: notifications,
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        createdAt: DateTime(2026, 5, 20),
      );

      final mutation = coordinator.updateTaskReminder(
        tasks: [task],
        recurringExceptions: const [],
        taskId: task.id,
        reminderMinutesBefore: 15,
      );

      expect(mutation, isNotNull);

      await mutation!.persistOperation();

      final expectedNotificationId = taskReminderNotificationId(task.id);

      expect(taskRepository.savedTasks, hasLength(1));
      expect(taskRepository.savedTasks.single.reminderMinutesBefore, 15);
      expect(notifications.canceledIds, [expectedNotificationId]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 20, 9, 15),
      );
    });

    test('cancels reminder after clearing task reminder', () async {
      final taskRepository = FakeTaskRepository();
      final notifications = FakeTaskReminderNotificationClient();
      final coordinator = _createCoordinator(
        taskRepository: taskRepository,
        notifications: notifications,
      );

      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      final mutation = coordinator.updateTaskReminder(
        tasks: [task],
        recurringExceptions: const [],
        taskId: task.id,
        reminderMinutesBefore: null,
      );

      expect(mutation, isNotNull);

      await mutation!.persistOperation();

      expect(taskRepository.savedTasks, hasLength(1));
      expect(taskRepository.savedTasks.single.reminderMinutesBefore, isNull);
      expect(notifications.canceledIds, [taskReminderNotificationId(task.id)]);
      expect(notifications.scheduledReminders, isEmpty);
    });
  });
}

TaskStoreCoordinator _createCoordinator({
  required FakeTaskRepository taskRepository,
  required FakeTaskReminderNotificationClient notifications,
}) {
  return TaskStoreCoordinator(
    taskRepository: taskRepository,
    recurringOccurrenceStoreCoordinator: RecurringOccurrenceStoreCoordinator(
      recurringTaskRepository: FakeRecurringTaskRepository(),
    ),
    taskReminderApplicationService: TaskReminderApplicationService(
      taskReminderScheduler: TaskReminderScheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 20, 8),
      ),
    ),
  );
}

class FakeTaskRepository implements TaskRepository {
  final List<PlannerTask> savedTasks = [];
  final List<PlannerTask> updatedTasks = [];
  final List<String> deletedTaskIds = [];

  @override
  Future<List<PlannerTask>> loadTasks() async {
    return const [];
  }

  @override
  Future<void> saveTask(PlannerTask task) async {
    savedTasks.add(task);
  }

  @override
  Future<void> updateTask(PlannerTask task) async {
    updatedTasks.add(task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    deletedTaskIds.add(taskId);
  }
}

class FakeTaskReminderNotificationClient
    implements TaskReminderNotificationClient {
  final List<int> canceledIds = [];
  final List<ScheduledTaskReminderCall> scheduledReminders = [];

  @override
  Future<void> cancelTaskReminder(int id) async {
    canceledIds.add(id);
  }

  @override
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    scheduledReminders.add(
      ScheduledTaskReminderCall(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        payload: payload,
      ),
    );
  }
}

class ScheduledTaskReminderCall {
  const ScheduledTaskReminderCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? payload;
}

class FakeRecurringTaskRepository implements RecurringTaskRepository {
  @override
  Future<List<RecurringTaskRule>> loadRecurringTaskRules() async {
    return const [];
  }

  @override
  Future<List<RecurringTaskException>> loadRecurringTaskExceptions() async {
    return const [];
  }

  @override
  Future<void> saveGeneratedOccurrences(
    List<PlannerTask> generatedTasks,
  ) async {}

  @override
  Future<void> saveRecurringTaskRuleWithOccurrences({
    required RecurringTaskRule rule,
    required List<PlannerTask> generatedTasks,
  }) async {}

  @override
  Future<void> deactivateRecurringTaskRuleAndDeleteUnfinishedOccurrences(
    RecurringTaskRule rule,
  ) async {}

  @override
  Future<void> deleteRecurringTaskRuleAndCleanSeries(String ruleId) async {}

  @override
  Future<void> updateRecurringTaskRuleAndReplaceUnfinishedOccurrences({
    required RecurringTaskRule rule,
    required List<PlannerTask> generatedTasks,
  }) async {}

  @override
  Future<void> deleteTaskWithRecurringException({
    required String taskId,
    required RecurringTaskException exception,
  }) async {}

  @override
  Future<void> updateTaskWithRecurringException({
    required PlannerTask task,
    required RecurringTaskException exception,
  }) async {}
}
