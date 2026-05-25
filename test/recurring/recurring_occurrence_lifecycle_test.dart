import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_exception.dart';
import 'package:goal_planner/features/recurring/domain/recurring_occurrence_lifecycle.dart';

void main() {
  group('RecurringOccurrenceLifecycle', () {
    final lifecycle = RecurringOccurrenceLifecycle();
    final now = DateTime(2026, 5, 1, 12, 30);
    final occurrenceDate = DateTime(2026, 4, 27, 18, 45);

    test('deletes occurrence and creates exception for its scheduled date', () {
      final occurrence = _recurringOccurrence(
        id: 'task-1',
        ruleId: 'rule-1',
        scheduledDate: occurrenceDate,
      );

      final otherTask = _regularTask(id: 'task-2');

      final result = lifecycle.deleteOccurrence(
        task: occurrence,
        tasks: [occurrence, otherTask],
        exceptions: [],
        now: now,
      );

      expect(result.tasks, [otherTask]);
      expect(result.taskIdToDelete, occurrence.id);
      expect(result.taskToPersist, isNull);

      final exception = result.exceptionToPersist;

      expect(exception, isNotNull);
      expect(exception!.id, 'recurring_exception_rule-1_20260427');
      expect(exception.ruleId, 'rule-1');
      expect(exception.date, DateTime(2026, 4, 27));
      expect(exception.createdAt, now);
      expect(result.exceptions, [exception]);
    });

    test('does not duplicate existing exception when deleting occurrence', () {
      final occurrence = _recurringOccurrence(
        id: 'task-1',
        ruleId: 'rule-1',
        scheduledDate: occurrenceDate,
      );

      final existingException = RecurringTaskException(
        id: 'existing-exception',
        ruleId: 'rule-1',
        date: occurrenceDate,
        createdAt: DateTime(2026, 4, 30),
      );

      final result = lifecycle.deleteOccurrence(
        task: occurrence,
        tasks: [occurrence],
        exceptions: [existingException],
        now: now,
      );

      expect(result.tasks, isEmpty);
      expect(result.exceptions, [existingException]);
      expect(
        result.exceptionToPersist!.id,
        'recurring_exception_rule-1_20260427',
      );
    });

    test(
      'reschedules occurrence, detaches it from rule, and creates exception',
      () {
        final occurrence = _recurringOccurrence(
          id: 'task-1',
          ruleId: 'rule-1',
          scheduledDate: occurrenceDate,
        );

        final newDate = DateTime(2026, 4, 29, 21, 10);

        final result = lifecycle.rescheduleOccurrence(
          task: occurrence,
          scheduledDate: newDate,
          tasks: [occurrence],
          exceptions: [],
          now: now,
        );

        final updatedTask = result.taskToPersist;

        expect(updatedTask, isNotNull);
        expect(updatedTask!.id, occurrence.id);
        expect(updatedTask.scheduledDate, DateTime(2026, 4, 29));
        expect(updatedTask.recurringRuleId, isNull);
        expect(result.tasks, [updatedTask]);

        final exception = result.exceptionToPersist;

        expect(exception, isNotNull);
        expect(exception!.id, 'recurring_exception_rule-1_20260427');
        expect(exception.date, DateTime(2026, 4, 27));
        expect(result.exceptions, [exception]);
      },
    );

    test(
      'updates occurrence time, detaches it from rule, and creates exception',
      () {
        final occurrence = _recurringOccurrence(
          id: 'task-1',
          ruleId: 'rule-1',
          scheduledDate: occurrenceDate,
          scheduledTimeMinutes: 9 * 60,
          reminderMinutesBefore: 15,
        );

        final result = lifecycle.scheduleOccurrenceForDateAndTime(
          task: occurrence,
          scheduledDate: occurrenceDate,
          scheduledTimeMinutes: 10 * 60,
          tasks: [occurrence],
          exceptions: [],
          now: now,
        );

        final updatedTask = result.taskToPersist;

        expect(updatedTask, isNotNull);
        expect(updatedTask!.id, occurrence.id);
        expect(updatedTask.scheduledDate, DateTime(2026, 4, 27));
        expect(updatedTask.scheduledTimeMinutes, 10 * 60);
        expect(updatedTask.reminderMinutesBefore, 15);
        expect(updatedTask.recurringRuleId, isNull);

        final exception = result.exceptionToPersist;

        expect(exception, isNotNull);
        expect(exception!.id, 'recurring_exception_rule-1_20260427');
        expect(exception.date, DateTime(2026, 4, 27));
        expect(result.exceptions, [exception]);
      },
    );

    test(
      'clears occurrence time and reminder when overriding time with null',
      () {
        final occurrence = _recurringOccurrence(
          id: 'task-1',
          ruleId: 'rule-1',
          scheduledDate: occurrenceDate,
          scheduledTimeMinutes: 9 * 60,
          reminderMinutesBefore: 15,
        );

        final result = lifecycle.scheduleOccurrenceForDateAndTime(
          task: occurrence,
          scheduledDate: occurrenceDate,
          scheduledTimeMinutes: null,
          tasks: [occurrence],
          exceptions: [],
          now: now,
        );

        final updatedTask = result.taskToPersist;

        expect(updatedTask, isNotNull);
        expect(updatedTask!.scheduledDate, DateTime(2026, 4, 27));
        expect(updatedTask.scheduledTimeMinutes, isNull);
        expect(updatedTask.reminderMinutesBefore, isNull);
        expect(updatedTask.recurringRuleId, isNull);
        expect(result.exceptionToPersist, isNotNull);
      },
    );

    test('does nothing when rescheduling to the same date', () {
      final occurrence = _recurringOccurrence(
        id: 'task-1',
        ruleId: 'rule-1',
        scheduledDate: occurrenceDate,
      );

      final result = lifecycle.rescheduleOccurrence(
        task: occurrence,
        scheduledDate: DateTime(2026, 4, 27, 23, 59),
        tasks: [occurrence],
        exceptions: [],
        now: now,
      );

      expect(result.tasks, [occurrence]);
      expect(result.exceptions, isEmpty);
      expect(result.taskToPersist, isNull);
      expect(result.exceptionToPersist, isNull);
    });

    test(
      'unschedules occurrence, detaches it from rule, and creates exception',
      () {
        final occurrence = _recurringOccurrence(
          id: 'task-1',
          ruleId: 'rule-1',
          scheduledDate: occurrenceDate,
        );

        final result = lifecycle.unscheduleOccurrence(
          task: occurrence,
          tasks: [occurrence],
          exceptions: [],
          now: now,
        );

        final updatedTask = result.taskToPersist;

        expect(updatedTask, isNotNull);
        expect(updatedTask!.id, occurrence.id);
        expect(updatedTask.scheduledDate, isNull);
        expect(updatedTask.recurringRuleId, isNull);
        expect(result.tasks, [updatedTask]);

        final exception = result.exceptionToPersist;

        expect(exception, isNotNull);
        expect(exception!.id, 'recurring_exception_rule-1_20260427');
        expect(exception.date, DateTime(2026, 4, 27));
        expect(result.exceptions, [exception]);
      },
    );

    test(
      'updates occurrence reminder, detaches it from rule, and creates exception',
      () {
        final occurrence = _recurringOccurrence(
          id: 'task-1',
          ruleId: 'rule-1',
          scheduledDate: occurrenceDate,
          scheduledTimeMinutes: 9 * 60,
          reminderMinutesBefore: 15,
        );

        final result = lifecycle.updateOccurrenceReminder(
          task: occurrence,
          reminderMinutesBefore: null,
          tasks: [occurrence],
          exceptions: [],
          now: now,
        );

        final updatedTask = result.taskToPersist;

        expect(updatedTask, isNotNull);
        expect(updatedTask!.id, occurrence.id);
        expect(updatedTask.reminderMinutesBefore, isNull);
        expect(updatedTask.recurringRuleId, isNull);

        final exception = result.exceptionToPersist;

        expect(exception, isNotNull);
        expect(exception!.id, 'recurring_exception_rule-1_20260427');
        expect(exception.date, DateTime(2026, 4, 27));
      },
    );

    test('does nothing for task without recurring rule id', () {
      final task = _regularTask(id: 'task-1');

      final result = lifecycle.deleteOccurrence(
        task: task,
        tasks: [task],
        exceptions: [],
        now: now,
      );

      expect(result.tasks, [task]);
      expect(result.exceptions, isEmpty);
      expect(result.taskIdToDelete, isNull);
      expect(result.taskToPersist, isNull);
      expect(result.exceptionToPersist, isNull);
    });
  });
}

PlannerTask _recurringOccurrence({
  required String id,
  required String ruleId,
  required DateTime scheduledDate,
  int? scheduledTimeMinutes,
  int? reminderMinutesBefore,
}) {
  return PlannerTask(
    id: id,
    title: 'Workout',
    description: '',
    recurringRuleId: ruleId,
    scheduledDate: scheduledDate,
    createdAt: DateTime(2026, 4, 1),
    scheduledTimeMinutes: scheduledTimeMinutes,
    reminderMinutesBefore: reminderMinutesBefore,
  );
}

PlannerTask _regularTask({required String id}) {
  return PlannerTask(
    id: id,
    title: 'One-off task',
    description: '',
    createdAt: DateTime(2026, 4, 1),
  );
}
