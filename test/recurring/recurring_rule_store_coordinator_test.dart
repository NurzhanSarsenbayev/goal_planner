import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/recurring/application/recurring_rule_store_coordinator.dart';
import 'package:goal_planner/features/recurring/application/recurring_task_repository.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_client.dart';
import 'package:goal_planner/features/reminders/task/application/task_reminder_resync_service.dart';
import 'package:goal_planner/features/reminders/task/application/task_reminder_scheduler.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_exception.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('RecurringRuleStoreCoordinator reminders', () {
    test(
      'syncs reminders after replacing unfinished occurrences on rule update',
      () async {
        final repository = _FakeRecurringTaskRepository();
        final notifications = _FakeReminderNotificationClient();
        final coordinator = _createCoordinator(
          repository: repository,
          notifications: notifications,
        );

        final oldRule = _weeklyRule(
          id: 'rule_1',
          weekdays: [DateTime.monday],
          scheduledTimeMinutes: 9 * 60,
          reminderMinutesBefore: 15,
        );

        final oldOccurrence = PlannerTask(
          id: 'old_occurrence',
          title: 'Workout',
          description: '',
          recurringRuleId: oldRule.id,
          scheduledDate: DateTime(2026, 5, 25),
          scheduledTimeMinutes: 9 * 60,
          reminderMinutesBefore: 15,
          createdAt: DateTime(2026, 5, 25),
        );

        final updatedRule = oldRule.copyWith(
          weekdays: [DateTime.tuesday],
          scheduledTimeMinutes: 10 * 60,
          reminderMinutesBefore: 30,
        );

        final mutation = coordinator.updateRule(
          updatedRule: updatedRule,
          rules: [oldRule],
          exceptions: const [],
          tasks: [oldOccurrence],
          today: DateTime(2026, 5, 25),
        );

        expect(mutation, isNotNull);

        await mutation!.persistOperation();

        expect(
          notifications.canceledIds,
          contains(taskReminderNotificationId(oldOccurrence.id)),
        );
        expect(notifications.scheduledReminders, isNotEmpty);
        expect(
          notifications.scheduledReminders.map((call) => call.scheduledAt),
          contains(DateTime(2026, 5, 26, 9, 30)),
        );
      },
    );
  });
}

RecurringRuleStoreCoordinator _createCoordinator({
  required _FakeRecurringTaskRepository repository,
  required _FakeReminderNotificationClient notifications,
}) {
  final scheduler = TaskReminderScheduler(
    notifications: notifications,
    now: () => DateTime(2026, 5, 25, 8),
  );

  return RecurringRuleStoreCoordinator(
    recurringTaskRepository: repository,
    taskReminderResyncService: TaskReminderResyncService(
      taskReminderScheduler: scheduler,
    ),
  );
}

RecurringTaskRule _weeklyRule({
  required String id,
  required List<int> weekdays,
  int? scheduledTimeMinutes,
  int? reminderMinutesBefore,
}) {
  return RecurringTaskRule(
    id: id,
    title: 'Workout',
    description: '',
    recurrenceType: RecurrenceType.weekly,
    weekdays: weekdays,
    monthDay: null,
    startDate: DateTime(2026, 5, 25),
    scheduledTimeMinutes: scheduledTimeMinutes,
    reminderMinutesBefore: reminderMinutesBefore,
    createdAt: DateTime(2026, 5, 20),
  );
}

class _FakeRecurringTaskRepository implements RecurringTaskRepository {
  final updatedRules = <RecurringTaskRule>[];
  final generatedTasks = <PlannerTask>[];

  @override
  Future<List<RecurringTaskRule>> loadRecurringTaskRules() async => const [];

  @override
  Future<List<RecurringTaskException>> loadRecurringTaskExceptions() async =>
      const [];

  @override
  Future<void> saveGeneratedOccurrences(
    List<PlannerTask> generatedTasks,
  ) async {
    this.generatedTasks.addAll(generatedTasks);
  }

  @override
  Future<void> saveRecurringTaskRuleWithOccurrences({
    required RecurringTaskRule rule,
    required List<PlannerTask> generatedTasks,
  }) async {
    updatedRules.add(rule);
    this.generatedTasks.addAll(generatedTasks);
  }

  @override
  Future<void> updateRecurringTaskRuleAndReplaceUnfinishedOccurrences({
    required RecurringTaskRule rule,
    required List<PlannerTask> generatedTasks,
  }) async {
    updatedRules.add(rule);
    this.generatedTasks.addAll(generatedTasks);
  }

  @override
  Future<void> deactivateRecurringTaskRuleAndDeleteUnfinishedOccurrences(
    RecurringTaskRule rule,
  ) async {
    updatedRules.add(rule);
  }

  @override
  Future<void> deleteRecurringTaskRuleAndCleanSeries(String ruleId) async {}

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

class _FakeReminderNotificationClient implements ReminderNotificationClient {
  final canceledIds = <int>[];
  final scheduledReminders = <_ScheduledReminderCall>[];

  @override
  Future<void> cancelReminder(int id) async {
    canceledIds.add(id);
  }

  @override
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
    ReminderRepeat repeat = ReminderRepeat.none,
  }) async {
    scheduledReminders.add(
      _ScheduledReminderCall(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        payload: payload,
      ),
    );
  }
}

class _ScheduledReminderCall {
  const _ScheduledReminderCall({
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
