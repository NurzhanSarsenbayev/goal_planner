import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/backup/application/planner_backup_validator.dart';
import 'package:goal_planner/features/backup/domain/planner_backup.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/models/goal.dart';
import 'package:goal_planner/models/milestone.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_exception.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('PlannerBackupValidator', () {
    const validator = PlannerBackupValidator();

    test('accepts valid backup data', () {
      final result = validator.validateData(_validBackupData());

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('throws when invalid result is requested to throw', () {
      final result = validator.validateData(const PlannerBackupData.empty());

      expect(result.isValid, isTrue);
      expect(result.throwIfInvalid, returnsNormally);
    });

    test('reports duplicate ids', () {
      final now = DateTime(2026, 5, 13);

      final result = validator.validateData(
        PlannerBackupData(
          goals: [
            Goal(
              id: 'goal-1',
              title: 'Goal 1',
              description: '',
              status: GoalStatus.active,
              createdAt: now,
            ),
            Goal(
              id: 'goal-1',
              title: 'Goal 2',
              description: '',
              status: GoalStatus.active,
              createdAt: now,
            ),
          ],
          milestones: const [],
          tasks: const [],
          recurringRules: const [],
          recurringExceptions: const [],
          habits: const [],
          habitEntries: const [],
        ),
      );

      expect(result.isValid, isFalse);
      expect(_errorCodes(result), contains('duplicate_id'));
      expect(result.errors.single.message, contains('goals'));
    });

    test('reports broken references', () {
      final now = DateTime(2026, 5, 13);

      final result = validator.validateData(
        PlannerBackupData(
          goals: const [],
          milestones: [
            Milestone(
              id: 'milestone-1',
              goalId: 'missing-goal',
              title: 'Milestone',
              description: '',
              createdAt: now,
            ),
          ],
          tasks: [
            PlannerTask(
              id: 'task-1',
              goalId: 'missing-goal',
              milestoneId: 'missing-milestone',
              recurringRuleId: 'missing-rule',
              title: 'Task',
              description: '',
              createdAt: now,
            ),
          ],
          recurringRules: [
            RecurringTaskRule(
              id: 'rule-1',
              goalId: 'missing-goal',
              milestoneId: 'missing-milestone',
              title: 'Recurring',
              description: '',
              recurrenceType: RecurrenceType.weekly,
              weekdays: const [DateTime.monday],
              monthDay: null,
              startDate: now,
              createdAt: now,
            ),
          ],
          recurringExceptions: [
            RecurringTaskException(
              id: 'exception-1',
              ruleId: 'missing-rule',
              date: now,
              createdAt: now,
            ),
          ],
          habits: const [],
          habitEntries: [
            HabitEntry(
              id: 'habit-entry-1',
              habitId: 'missing-habit',
              date: now,
              status: HabitEntryStatus.done,
              completedCount: 1,
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
      );

      expect(result.isValid, isFalse);
      expect(
        _errorCodes(result),
        containsAll([
          'milestone_missing_goal',
          'task_missing_goal',
          'task_missing_milestone',
          'task_missing_recurring_rule',
          'recurring_rule_missing_goal',
          'recurring_rule_missing_milestone',
          'recurring_exception_missing_rule',
          'habit_entry_missing_habit',
        ]),
      );
    });

    test('reports milestone and goal mismatches', () {
      final now = DateTime(2026, 5, 13);

      final result = validator.validateData(
        PlannerBackupData(
          goals: [
            Goal(
              id: 'goal-1',
              title: 'Goal 1',
              description: '',
              status: GoalStatus.active,
              createdAt: now,
            ),
            Goal(
              id: 'goal-2',
              title: 'Goal 2',
              description: '',
              status: GoalStatus.active,
              createdAt: now,
            ),
          ],
          milestones: [
            Milestone(
              id: 'milestone-1',
              goalId: 'goal-1',
              title: 'Milestone',
              description: '',
              createdAt: now,
            ),
          ],
          tasks: [
            PlannerTask(
              id: 'task-1',
              goalId: 'goal-2',
              milestoneId: 'milestone-1',
              title: 'Task',
              description: '',
              createdAt: now,
            ),
          ],
          recurringRules: [
            RecurringTaskRule(
              id: 'rule-1',
              goalId: 'goal-2',
              milestoneId: 'milestone-1',
              title: 'Recurring',
              description: '',
              recurrenceType: RecurrenceType.weekly,
              weekdays: const [DateTime.monday],
              monthDay: null,
              startDate: now,
              createdAt: now,
            ),
          ],
          recurringExceptions: const [],
          habits: const [],
          habitEntries: const [],
        ),
      );

      expect(result.isValid, isFalse);
      expect(
        _errorCodes(result),
        containsAll([
          'task_milestone_goal_mismatch',
          'recurring_rule_milestone_goal_mismatch',
        ]),
      );
    });

    test('reports invalid recurring schedules', () {
      final now = DateTime(2026, 5, 13);

      final result = validator.validateData(
        PlannerBackupData(
          goals: const [],
          milestones: const [],
          tasks: const [],
          recurringRules: [
            RecurringTaskRule(
              id: 'weekly-empty',
              title: 'Weekly empty',
              description: '',
              recurrenceType: RecurrenceType.weekly,
              weekdays: const [],
              monthDay: null,
              startDate: now,
              createdAt: now,
            ),
            RecurringTaskRule(
              id: 'weekly-invalid',
              title: 'Weekly invalid',
              description: '',
              recurrenceType: RecurrenceType.weekly,
              weekdays: const [0, DateTime.monday, DateTime.monday, 8],
              monthDay: null,
              startDate: now,
              createdAt: now,
            ),
            RecurringTaskRule(
              id: 'monthly-empty',
              title: 'Monthly empty',
              description: '',
              recurrenceType: RecurrenceType.monthly,
              weekdays: const [],
              monthDay: null,
              startDate: now,
              createdAt: now,
            ),
            RecurringTaskRule(
              id: 'monthly-invalid',
              title: 'Monthly invalid',
              description: '',
              recurrenceType: RecurrenceType.monthly,
              weekdays: const [],
              monthDay: 32,
              startDate: now,
              createdAt: now,
            ),
          ],
          recurringExceptions: const [],
          habits: const [],
          habitEntries: const [],
        ),
      );

      expect(result.isValid, isFalse);
      expect(
        _errorCodes(result),
        containsAll([
          'weekly_recurring_rule_without_weekdays',
          'invalid_recurring_rule_weekday',
          'duplicate_recurring_rule_weekday',
          'monthly_recurring_rule_without_month_day',
          'invalid_recurring_rule_month_day',
        ]),
      );
    });

    test('throws validation exception for invalid data', () {
      final now = DateTime(2026, 5, 13);
      final result = validator.validateData(
        PlannerBackupData(
          goals: const [],
          milestones: [
            Milestone(
              id: 'milestone-1',
              goalId: 'missing-goal',
              title: 'Milestone',
              description: '',
              createdAt: now,
            ),
          ],
          tasks: const [],
          recurringRules: const [],
          recurringExceptions: const [],
          habits: const [],
          habitEntries: const [],
        ),
      );

      expect(result.isValid, isFalse);
      expect(
        result.throwIfInvalid,
        throwsA(isA<PlannerBackupValidationException>()),
      );
    });
  });
}

PlannerBackupData _validBackupData() {
  final now = DateTime(2026, 5, 13);
  final scheduledDate = DateTime(2026, 5, 14);

  return PlannerBackupData(
    goals: [
      Goal(
        id: 'goal-1',
        title: 'Goal',
        description: '',
        status: GoalStatus.active,
        createdAt: now,
      ),
    ],
    milestones: [
      Milestone(
        id: 'milestone-1',
        goalId: 'goal-1',
        title: 'Milestone',
        description: '',
        createdAt: now,
      ),
    ],
    tasks: [
      PlannerTask(
        id: 'task-1',
        goalId: 'goal-1',
        milestoneId: 'milestone-1',
        recurringRuleId: 'rule-1',
        title: 'Task',
        description: '',
        scheduledDate: scheduledDate,
        isCompleted: true,
        completedAt: scheduledDate,
        createdAt: now,
      ),
    ],
    recurringRules: [
      RecurringTaskRule(
        id: 'rule-1',
        goalId: 'goal-1',
        milestoneId: 'milestone-1',
        title: 'Recurring',
        description: '',
        recurrenceType: RecurrenceType.weekly,
        weekdays: const [DateTime.monday],
        monthDay: null,
        startDate: now,
        createdAt: now,
      ),
      RecurringTaskRule(
        id: 'rule-2',
        title: 'Monthly recurring',
        description: '',
        recurrenceType: RecurrenceType.monthly,
        weekdays: const [],
        monthDay: 15,
        startDate: now,
        createdAt: now,
      ),
    ],
    recurringExceptions: [
      RecurringTaskException(
        id: 'exception-1',
        ruleId: 'rule-1',
        date: scheduledDate,
        createdAt: now,
      ),
    ],
    habits: [
      Habit(
        id: 'habit-1',
        title: 'Habit',
        description: '',
        trackingType: HabitTrackingType.count,
        targetCount: 3,
        sortOrder: 0,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    habitEntries: [
      HabitEntry(
        id: 'habit-entry-1',
        habitId: 'habit-1',
        date: scheduledDate,
        status: HabitEntryStatus.done,
        completedCount: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );
}

List<String> _errorCodes(PlannerBackupValidationResult result) {
  return result.errors.map((error) => error.code).toList();
}
