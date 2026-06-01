import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_goal_repository.dart';
import 'package:goal_planner/data/repositories/drift_habit_repository.dart';
import 'package:goal_planner/data/repositories/drift_milestone_repository.dart';
import 'package:goal_planner/data/repositories/drift_planner_backup_restore_repository.dart';
import 'package:goal_planner/data/repositories/drift_recurring_task_repository.dart';
import 'package:goal_planner/data/repositories/drift_task_repository.dart';
import 'package:goal_planner/data/repositories/drift_standalone_reminder_repository.dart';
import 'package:goal_planner/data/repositories/drift_body_weight_repository.dart';
import 'package:goal_planner/data/repositories/drift_body_measurement_repository.dart';
import 'package:goal_planner/data/repositories/drift_body_profile_repository.dart';
import 'package:goal_planner/data/repositories/drift_daily_review_reminder_settings_repository.dart';
import 'package:goal_planner/features/reminders/standalone/domain/standalone_reminder.dart';
import 'package:goal_planner/features/reminders/daily_review/domain/daily_review_reminder_settings.dart';
import 'package:goal_planner/features/backup/domain/planner_backup.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/features/body_tracking/domain/body_profile.dart';
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
      final bodyWeightEntries = await DriftBodyWeightRepository(
        database,
      ).loadAllEntries();
      final bodyMeasurementEntries = await DriftBodyMeasurementRepository(
        database,
      ).loadAllEntries();
      final bodyProfile = await DriftBodyProfileRepository(
        database,
      ).loadProfile();
      final standaloneReminders = await DriftStandaloneReminderRepository(
        database,
      ).loadStandaloneReminders();
      final dailyReviewReminderSettings =
          await DriftDailyReviewReminderSettingsRepository(
            database,
          ).loadSettings();

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

      expect(bodyWeightEntries.map((entry) => entry.id), ['new-body-weight']);
      expect(bodyWeightEntries.single.weightKg, 80.5);
      expect(bodyWeightEntries.single.isSkipped, isFalse);

      expect(bodyMeasurementEntries.map((entry) => entry.id), [
        'new-body-measurement',
      ]);
      expect(bodyMeasurementEntries.single.neckCm, 34);
      expect(bodyMeasurementEntries.single.waistCm, 74);
      expect(bodyMeasurementEntries.single.hipsCm, 101);

      expect(bodyProfile, isNotNull);
      expect(bodyProfile!.id, defaultBodyProfileId);
      expect(bodyProfile.heightCm, 168);
      expect(bodyProfile.bodyFatFormula, BodyFatFormula.usNavyFemale);

      expect(standaloneReminders.map((reminder) => reminder.id), [
        'new-standalone-reminder',
      ]);
      expect(
        standaloneReminders.single.scheduleType,
        StandaloneReminderScheduleType.once,
      );

      expect(recurringRules.single.scheduledTimeMinutes, 570);
      expect(recurringRules.single.reminderMinutesBefore, 15);

      expect(standaloneReminders.single.scheduledDate, DateTime(2026, 5, 14));
      expect(standaloneReminders.single.timeMinutes, 1110);
      expect(dailyReviewReminderSettings.isEnabled, isFalse);
      expect(dailyReviewReminderSettings.timeMinutes, 1234);
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
      expect(
        await DriftBodyWeightRepository(database).loadAllEntries(),
        isEmpty,
      );
      expect(
        await DriftBodyMeasurementRepository(database).loadAllEntries(),
        isEmpty,
      );
      expect(await DriftBodyProfileRepository(database).loadProfile(), isNull);
      expect(
        await DriftStandaloneReminderRepository(
          database,
        ).loadStandaloneReminders(),
        isEmpty,
      );
      final dailyReviewReminderSettings =
          await DriftDailyReviewReminderSettingsRepository(
            database,
          ).loadSettings();

      expect(dailyReviewReminderSettings.isEnabled, isTrue);
      expect(
        dailyReviewReminderSettings.timeMinutes,
        defaultDailyReviewReminderTimeMinutes,
      );
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
        scheduledTimeMinutes: 9 * 60 + 30,
        reminderMinutesBefore: 15,
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
    bodyWeightEntries: [
      BodyWeightEntry(
        id: '$idPrefix-body-weight',
        date: scheduledDate,
        weightKg: 80.5,
        isSkipped: false,
        note: '$idPrefix body weight',
        createdAt: now,
        updatedAt: now,
      ),
    ],
    bodyMeasurementEntries: [
      BodyMeasurementEntry(
        id: '$idPrefix-body-measurement',
        date: scheduledDate,
        neckCm: 34,
        waistCm: 74,
        hipsCm: 101,
        note: '$idPrefix body measurement',
        createdAt: now,
        updatedAt: now,
      ),
    ],
    bodyProfile: BodyProfile(
      id: defaultBodyProfileId,
      heightCm: 168,
      bodyFatFormula: BodyFatFormula.usNavyFemale,
      createdAt: now,
      updatedAt: now,
    ),
    standaloneReminders: [
      StandaloneReminder(
        id: '$idPrefix-standalone-reminder',
        title: '$idPrefix standalone reminder',
        scheduleType: StandaloneReminderScheduleType.once,
        scheduledDate: scheduledDate,
        timeMinutes: 18 * 60 + 30,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    dailyReviewReminderSettings: DailyReviewReminderSettings(
      isEnabled: idPrefix != 'new',
      timeMinutes: idPrefix == 'new'
          ? 1234
          : defaultDailyReviewReminderTimeMinutes,
    ),
  );
}
