import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
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
import 'package:goal_planner/features/reminders/standalone/domain/standalone_reminder.dart';
import 'package:goal_planner/features/reminders/daily_review/domain/daily_review_reminder_settings.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';

void main() {
  group('PlannerBackup', () {
    test('serializes and restores all planner data', () {
      final now = DateTime(2026, 5, 13, 10, 30);
      final scheduledDate = DateTime(2026, 5, 14);
      final completedAt = DateTime(2026, 5, 15);
      final habitDate = DateTime(2026, 5, 16);
      final bodyWeightDate = DateTime(2026, 5, 18);
      final reminderDate = DateTime(2026, 5, 17);

      final backup = PlannerBackup.create(
        exportedAt: now,
        data: PlannerBackupData(
          goals: [
            Goal(
              id: 'goal-1',
              title: 'Goal',
              description: 'Goal description',
              status: GoalStatus.active,
              createdAt: now,
            ),
          ],
          milestones: [
            Milestone(
              id: 'milestone-1',
              goalId: 'goal-1',
              title: 'Milestone',
              description: 'Milestone description',
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
              description: 'Task description',
              scheduledDate: scheduledDate,
              scheduledTimeMinutes: 9 * 60 + 30,
              reminderMinutesBefore: 15,
              isCompleted: true,
              completedAt: completedAt,
              createdAt: now,
            ),
          ],
          recurringRules: [
            RecurringTaskRule(
              id: 'rule-1',
              goalId: 'goal-1',
              milestoneId: 'milestone-1',
              title: 'Recurring task',
              description: 'Recurring description',
              recurrenceType: RecurrenceType.weekly,
              weekdays: const [DateTime.monday, DateTime.wednesday],
              monthDay: null,
              startDate: scheduledDate,
              endDate: null,
              isActive: true,
              createdAt: now,
              scheduledTimeMinutes: 9 * 60 + 30,
              reminderMinutesBefore: 15,
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
              description: 'Habit description',
              trackingType: HabitTrackingType.count,
              targetCount: 3,
              sortOrder: 1,
              isArchived: false,
              isReminderEnabled: true,
              reminderTimeMinutes: 19 * 60 + 45,
              createdAt: now,
              updatedAt: now,
            ),
          ],
          habitEntries: [
            HabitEntry(
              id: 'habit-entry-1',
              habitId: 'habit-1',
              date: habitDate,
              status: HabitEntryStatus.incomplete,
              completedCount: 2,
              note: 'Almost done',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          bodyWeightEntries: [
            BodyWeightEntry(
              id: 'body-weight-2026-05-18',
              date: bodyWeightDate,
              weightKg: 80.5,
              isSkipped: false,
              note: 'Morning weight',
              createdAt: now,
              updatedAt: now,
            ),
            BodyWeightEntry(
              id: 'body-weight-2026-05-19',
              date: bodyWeightDate.add(const Duration(days: 1)),
              weightKg: null,
              isSkipped: true,
              note: '',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          standaloneReminders: [
            StandaloneReminder(
              id: 'standalone-reminder-1',
              title: 'Call vet',
              scheduleType: StandaloneReminderScheduleType.once,
              scheduledDate: reminderDate,
              timeMinutes: 18 * 60 + 30,
              isEnabled: true,
              createdAt: now,
              updatedAt: now,
            ),
          ],
          dailyReviewReminderSettings: DailyReviewReminderSettings(
            isEnabled: false,
            timeMinutes: 20 * 60 + 15,
          ),
        ),
      );

      final encoded = jsonEncode(backup.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final restored = PlannerBackup.fromJson(decoded);

      expect(restored.schemaVersion, PlannerBackup.currentSchemaVersion);
      expect(restored.exportedAt, now);

      expect(restored.data.goals.single.title, 'Goal');
      expect(restored.data.goals.single.status, GoalStatus.active);

      expect(restored.data.milestones.single.goalId, 'goal-1');

      expect(restored.data.tasks.single.id, 'task-1');
      expect(restored.data.tasks.single.goalId, 'goal-1');
      expect(restored.data.tasks.single.milestoneId, 'milestone-1');
      expect(restored.data.tasks.single.recurringRuleId, 'rule-1');
      expect(restored.data.tasks.single.scheduledDate, scheduledDate);
      expect(restored.data.tasks.single.scheduledTimeMinutes, 570);
      expect(restored.data.tasks.single.reminderMinutesBefore, 15);
      expect(restored.data.tasks.single.isCompleted, isTrue);
      expect(restored.data.tasks.single.completedAt, completedAt);

      expect(restored.data.recurringRules.single.id, 'rule-1');
      expect(restored.data.recurringRules.single.goalId, 'goal-1');
      expect(restored.data.recurringRules.single.milestoneId, 'milestone-1');
      expect(
        restored.data.recurringRules.single.recurrenceType,
        RecurrenceType.weekly,
      );
      expect(restored.data.recurringRules.single.weekdays, [
        DateTime.monday,
        DateTime.wednesday,
      ]);
      expect(restored.data.recurringRules.single.monthDay, isNull);
      expect(restored.data.recurringRules.single.endDate, isNull);

      expect(restored.data.recurringRules.single.scheduledTimeMinutes, 570);
      expect(restored.data.recurringRules.single.reminderMinutesBefore, 15);

      expect(restored.data.recurringExceptions.single.ruleId, 'rule-1');
      expect(restored.data.recurringExceptions.single.date, scheduledDate);

      expect(restored.data.habits.single.trackingType, HabitTrackingType.count);
      expect(restored.data.habits.single.targetCount, 3);
      expect(restored.data.habits.single.isArchived, isFalse);
      expect(restored.data.habits.single.isReminderEnabled, isTrue);
      expect(restored.data.habits.single.reminderTimeMinutes, 1185);

      expect(
        restored.data.habitEntries.single.status,
        HabitEntryStatus.incomplete,
      );
      expect(restored.data.habitEntries.single.completedCount, 2);
      expect(restored.data.habitEntries.single.note, 'Almost done');

      expect(restored.data.bodyWeightEntries, hasLength(2));
      expect(
        restored.data.bodyWeightEntries.first.id,
        'body-weight-2026-05-18',
      );
      expect(restored.data.bodyWeightEntries.first.date, bodyWeightDate);
      expect(restored.data.bodyWeightEntries.first.weightKg, 80.5);
      expect(restored.data.bodyWeightEntries.first.isSkipped, isFalse);
      expect(restored.data.bodyWeightEntries.first.note, 'Morning weight');
      expect(restored.data.bodyWeightEntries.last.weightKg, isNull);
      expect(restored.data.bodyWeightEntries.last.isSkipped, isTrue);

      expect(
        restored.data.standaloneReminders.single.id,
        'standalone-reminder-1',
      );
      expect(restored.data.standaloneReminders.single.title, 'Call vet');
      expect(
        restored.data.standaloneReminders.single.scheduleType,
        StandaloneReminderScheduleType.once,
      );
      expect(
        restored.data.standaloneReminders.single.scheduledDate,
        reminderDate,
      );
      expect(restored.data.standaloneReminders.single.timeMinutes, 1110);
      expect(restored.data.standaloneReminders.single.isEnabled, isTrue);
      expect(restored.data.dailyReviewReminderSettings.isEnabled, isFalse);
      expect(restored.data.dailyReviewReminderSettings.timeMinutes, 1215);
    });

    test(
      'restores old backup without daily review reminder settings as defaults',
      () {
        final now = DateTime(2026, 5, 13);

        final restored = PlannerBackup.fromJson({
          'schemaVersion': PlannerBackup.currentSchemaVersion,
          'exportedAt': now.toIso8601String(),
          'data': const {},
        });

        expect(restored.data.dailyReviewReminderSettings.isEnabled, isTrue);
        expect(restored.data.bodyWeightEntries, isEmpty);
        expect(
          restored.data.dailyReviewReminderSettings.timeMinutes,
          defaultDailyReviewReminderTimeMinutes,
        );
      },
    );

    test('rejects unsupported schema version', () {
      expect(
        () => PlannerBackup.fromJson({
          'schemaVersion': 999,
          'exportedAt': DateTime(2026, 5, 13).toIso8601String(),
          'data': const {},
        }),
        throwsFormatException,
      );
    });

    test('restores old task backup without scheduled time as untimed task', () {
      final now = DateTime(2026, 5, 13);
      final scheduledDate = DateTime(2026, 5, 14);

      final restored = PlannerBackup.fromJson({
        'schemaVersion': PlannerBackup.currentSchemaVersion,
        'exportedAt': now.toIso8601String(),
        'data': {
          'tasks': [
            {
              'id': 'task-1',
              'goalId': null,
              'milestoneId': null,
              'recurringRuleId': null,
              'title': 'Task',
              'description': '',
              'scheduledDate': scheduledDate.toIso8601String(),
              'isCompleted': false,
              'completedAt': null,
              'createdAt': now.toIso8601String(),
            },
          ],
        },
      });

      expect(restored.data.tasks.single.scheduledDate, scheduledDate);
      expect(restored.data.tasks.single.scheduledTimeMinutes, isNull);
      expect(restored.data.tasks.single.reminderMinutesBefore, isNull);
    });

    test('supports empty backup data', () {
      final backup = PlannerBackup.create(
        exportedAt: DateTime(2026, 5, 13),
        data: const PlannerBackupData.empty(),
      );

      final restored = PlannerBackup.fromJson(
        jsonDecode(jsonEncode(backup.toJson())) as Map<String, dynamic>,
      );

      expect(restored.data.goals, isEmpty);
      expect(restored.data.milestones, isEmpty);
      expect(restored.data.tasks, isEmpty);
      expect(restored.data.recurringRules, isEmpty);
      expect(restored.data.recurringExceptions, isEmpty);
      expect(restored.data.habits, isEmpty);
      expect(restored.data.habitEntries, isEmpty);
      expect(restored.data.standaloneReminders, isEmpty);
      expect(restored.data.dailyReviewReminderSettings.isEnabled, isTrue);
      expect(
        restored.data.dailyReviewReminderSettings.timeMinutes,
        defaultDailyReviewReminderTimeMinutes,
      );
    });
  });
}
