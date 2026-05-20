import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_goal_repository.dart';
import 'package:goal_planner/data/repositories/drift_habit_repository.dart';
import 'package:goal_planner/data/repositories/drift_milestone_repository.dart';
import 'package:goal_planner/data/repositories/drift_planner_backup_restore_repository.dart';
import 'package:goal_planner/data/repositories/drift_recurring_task_repository.dart';
import 'package:goal_planner/data/repositories/drift_task_repository.dart';
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
  group('DriftPlannerBackupRestoreRepository', () {
    late local.AppDatabase database;
    late DriftPlannerBackupRestoreRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftPlannerBackupRestoreRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('replaces all existing planner data with backup data', () async {
      final existing = _backupData(idPrefix: 'old');
      final replacement = _backupData(idPrefix: 'new');

      await repository.replaceAll(existing);
      await repository.replaceAll(replacement);

      final goals = await DriftGoalRepository(database).loadGoals();
      final milestones = await DriftMilestoneRepository(
        database,
      ).loadMilestones();
      final tasks = await DriftTaskRepository(database).loadTasks();
      final recurringRules = await DriftRecurringTaskRepository(
        database,
      ).loadRecurringTaskRules();
      final recurringExceptions = await DriftRecurringTaskRepository(
        database,
      ).loadRecurringTaskExceptions();
      final habits = await DriftHabitRepository(database).loadHabits();
      final habitEntries = await DriftHabitRepository(
        database,
      ).loadAllEntries();

      expect(goals.map((goal) => goal.id), ['new-goal']);
      expect(milestones.map((milestone) => milestone.id), ['new-milestone']);
      expect(tasks.map((task) => task.id), ['new-task']);
      expect(recurringRules.map((rule) => rule.id), ['new-rule']);
      expect(recurringExceptions.map((exception) => exception.id), [
        'new-exception',
      ]);
      expect(tasks.single.reminderMinutesBefore, 15);
      expect(habits.map((habit) => habit.id), ['new-habit']);
      expect(habitEntries.map((entry) => entry.id), ['new-habit-entry']);

      expect(tasks.single.goalId, 'new-goal');
      expect(tasks.single.milestoneId, 'new-milestone');
      expect(tasks.single.recurringRuleId, 'new-rule');
      expect(tasks.single.scheduledTimeMinutes, 570);
      expect(habitEntries.single.habitId, 'new-habit');
    });

    test('can restore empty backup data and clear database', () async {
      await repository.replaceAll(_backupData(idPrefix: 'old'));

      await repository.replaceAll(const PlannerBackupData.empty());

      expect(await DriftGoalRepository(database).loadGoals(), isEmpty);
      expect(
        await DriftMilestoneRepository(database).loadMilestones(),
        isEmpty,
      );
      expect(await DriftTaskRepository(database).loadTasks(), isEmpty);
      expect(
        await DriftRecurringTaskRepository(database).loadRecurringTaskRules(),
        isEmpty,
      );
      expect(
        await DriftRecurringTaskRepository(
          database,
        ).loadRecurringTaskExceptions(),
        isEmpty,
      );
      expect(await DriftHabitRepository(database).loadHabits(), isEmpty);
      expect(await DriftHabitRepository(database).loadAllEntries(), isEmpty);
    });

    test('rolls back when restore insert fails', () async {
      final now = DateTime(2026, 5, 13);
      final existing = _backupData(idPrefix: 'old');
      final invalid = PlannerBackupData(
        goals: [
          Goal(
            id: 'duplicate-goal',
            title: 'First duplicate goal',
            description: '',
            status: GoalStatus.active,
            createdAt: now,
          ),
          Goal(
            id: 'duplicate-goal',
            title: 'Second duplicate goal',
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
      );

      await repository.replaceAll(existing);

      await expectLater(repository.replaceAll(invalid), throwsA(anything));

      final goals = await DriftGoalRepository(database).loadGoals();
      final milestones = await DriftMilestoneRepository(
        database,
      ).loadMilestones();

      expect(goals.map((goal) => goal.id), ['old-goal']);
      expect(milestones.map((milestone) => milestone.id), ['old-milestone']);
    });
  });
}

PlannerBackupData _backupData({required String idPrefix}) {
  final now = DateTime(2026, 5, 13);
  final scheduledDate = DateTime(2026, 5, 14);

  return PlannerBackupData(
    goals: [
      Goal(
        id: '$idPrefix-goal',
        title: '$idPrefix goal',
        description: '',
        status: GoalStatus.active,
        createdAt: now,
      ),
    ],
    milestones: [
      Milestone(
        id: '$idPrefix-milestone',
        goalId: '$idPrefix-goal',
        title: '$idPrefix milestone',
        description: '',
        createdAt: now,
      ),
    ],
    tasks: [
      PlannerTask(
        id: '$idPrefix-task',
        goalId: '$idPrefix-goal',
        milestoneId: '$idPrefix-milestone',
        recurringRuleId: '$idPrefix-rule',
        title: '$idPrefix task',
        description: '',
        scheduledDate: scheduledDate,
        scheduledTimeMinutes: 9 * 60 + 30,
        reminderMinutesBefore: 15,
        isCompleted: true,
        completedAt: scheduledDate,
        createdAt: now,
      ),
    ],
    recurringRules: [
      RecurringTaskRule(
        id: '$idPrefix-rule',
        goalId: '$idPrefix-goal',
        milestoneId: '$idPrefix-milestone',
        title: '$idPrefix recurring',
        description: '',
        recurrenceType: RecurrenceType.weekly,
        weekdays: const [DateTime.monday],
        monthDay: null,
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
      ),
    ],
    recurringExceptions: [
      RecurringTaskException(
        id: '$idPrefix-exception',
        ruleId: '$idPrefix-rule',
        date: scheduledDate,
        createdAt: now,
      ),
    ],
    habits: [
      Habit(
        id: '$idPrefix-habit',
        title: '$idPrefix habit',
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
        id: '$idPrefix-habit-entry',
        habitId: '$idPrefix-habit',
        date: scheduledDate,
        status: HabitEntryStatus.done,
        completedCount: 3,
        note: null,
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );
}
