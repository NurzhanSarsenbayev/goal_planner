import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/backup/application/planner_backup_export_service.dart';
import 'package:goal_planner/features/goals/application/goal_repository.dart';
import 'package:goal_planner/features/habits/application/habit_repository.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/features/milestones/application/milestone_repository.dart';
import 'package:goal_planner/features/recurring/application/recurring_task_repository.dart';
import 'package:goal_planner/features/tasks/application/task_repository.dart';
import 'package:goal_planner/features/reminders/standalone/application/standalone_reminder_repository.dart';
import 'package:goal_planner/features/reminders/standalone/domain/standalone_reminder.dart';
import 'package:goal_planner/features/reminders/daily_review/application/daily_review_reminder_settings_repository.dart';
import 'package:goal_planner/features/reminders/daily_review/domain/daily_review_reminder_settings.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_repository.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';
import 'package:goal_planner/models/goal.dart';
import 'package:goal_planner/models/milestone.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_exception.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('PlannerBackupExportService', () {
    test('creates backup from repositories', () async {
      final now = DateTime(2026, 5, 13, 12);
      final goal = Goal(
        id: 'goal-1',
        title: 'Goal',
        description: '',
        status: GoalStatus.active,
        createdAt: now,
      );
      final milestone = Milestone(
        id: 'milestone-1',
        goalId: goal.id,
        title: 'Milestone',
        description: '',
        createdAt: now,
      );
      final task = PlannerTask(
        id: 'task-1',
        goalId: goal.id,
        milestoneId: milestone.id,
        title: 'Task',
        description: '',
        scheduledDate: now,
        scheduledTimeMinutes: 9 * 60 + 30,
        createdAt: now,
      );
      final recurringRule = RecurringTaskRule(
        id: 'rule-1',
        goalId: goal.id,
        milestoneId: milestone.id,
        title: 'Recurring',
        description: '',
        recurrenceType: RecurrenceType.weekly,
        weekdays: const [DateTime.monday],
        monthDay: null,
        startDate: now,
        createdAt: now,
      );
      final recurringException = RecurringTaskException(
        id: 'exception-1',
        ruleId: recurringRule.id,
        date: now,
        createdAt: now,
      );
      final habit = Habit(
        id: 'habit-1',
        title: 'Habit',
        description: '',
        trackingType: HabitTrackingType.binary,
        targetCount: null,
        sortOrder: 0,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      );
      final habitEntry = HabitEntry(
        id: 'habit-entry-1',
        habitId: habit.id,
        date: now,
        status: HabitEntryStatus.done,
        completedCount: 1,
        note: null,
        createdAt: now,
        updatedAt: now,
      );
      final bodyWeightEntry = BodyWeightEntry(
        id: 'body-weight-2026-05-13',
        date: now,
        weightKg: 80.5,
        isSkipped: false,
        note: 'Morning weight',
        createdAt: now,
        updatedAt: now,
      );
      final standaloneReminder = StandaloneReminder(
        id: 'standalone-reminder-1',
        title: 'Plan your day',
        scheduleType: StandaloneReminderScheduleType.daily,
        scheduledDate: null,
        timeMinutes: 9 * 60,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );
      final dailyReviewReminderSettings = DailyReviewReminderSettings(
        isEnabled: false,
        timeMinutes: 20 * 60,
      );

      final service = PlannerBackupExportService(
        goalRepository: _FakeGoalRepository([goal]),
        milestoneRepository: _FakeMilestoneRepository([milestone]),
        taskRepository: _FakeTaskRepository([task]),
        recurringTaskRepository: _FakeRecurringTaskRepository(
          rules: [recurringRule],
          exceptions: [recurringException],
        ),
        habitRepository: _FakeHabitRepository(
          habits: [habit],
          entries: [habitEntry],
        ),
        bodyWeightRepository: _FakeBodyWeightRepository([bodyWeightEntry]),
        standaloneReminderRepository: _FakeStandaloneReminderRepository([
          standaloneReminder,
        ]),
        dailyReviewReminderSettingsRepository:
            _FakeDailyReviewReminderSettingsRepository(
              dailyReviewReminderSettings,
            ),
        now: () => now,
      );

      final backup = await service.createBackup();

      expect(backup.exportedAt, now);
      expect(backup.data.goals.single.id, goal.id);
      expect(backup.data.milestones.single.id, milestone.id);
      expect(backup.data.tasks.single.id, task.id);
      expect(backup.data.tasks.single.scheduledTimeMinutes, 570);
      expect(backup.data.recurringRules.single.id, recurringRule.id);
      expect(backup.data.recurringExceptions.single.id, recurringException.id);
      expect(backup.data.habits.single.id, habit.id);
      expect(backup.data.habitEntries.single.id, habitEntry.id);
      expect(backup.data.bodyWeightEntries.single.id, bodyWeightEntry.id);
      expect(backup.data.bodyWeightEntries.single.weightKg, 80.5);
      expect(backup.data.standaloneReminders.single.id, standaloneReminder.id);
      expect(backup.data.dailyReviewReminderSettings.isEnabled, isFalse);
      expect(backup.data.dailyReviewReminderSettings.timeMinutes, 1200);
    });

    test('supports empty repositories', () async {
      final now = DateTime(2026, 5, 13);

      final service = PlannerBackupExportService(
        goalRepository: _FakeGoalRepository(),
        milestoneRepository: _FakeMilestoneRepository(),
        taskRepository: _FakeTaskRepository(),
        recurringTaskRepository: _FakeRecurringTaskRepository(),
        habitRepository: _FakeHabitRepository(),
        bodyWeightRepository: const _FakeBodyWeightRepository(),
        standaloneReminderRepository: _FakeStandaloneReminderRepository(),
        dailyReviewReminderSettingsRepository:
            const _FakeDailyReviewReminderSettingsRepository(
              DailyReviewReminderSettings.defaults(),
            ),
        now: () => now,
      );

      final backup = await service.createBackup();

      expect(backup.exportedAt, now);
      expect(backup.data.goals, isEmpty);
      expect(backup.data.milestones, isEmpty);
      expect(backup.data.tasks, isEmpty);
      expect(backup.data.recurringRules, isEmpty);
      expect(backup.data.recurringExceptions, isEmpty);
      expect(backup.data.habits, isEmpty);
      expect(backup.data.habitEntries, isEmpty);
      expect(backup.data.bodyWeightEntries, isEmpty);
      expect(backup.data.standaloneReminders, isEmpty);
      expect(backup.data.dailyReviewReminderSettings.isEnabled, isTrue);
      expect(
        backup.data.dailyReviewReminderSettings.timeMinutes,
        defaultDailyReviewReminderTimeMinutes,
      );
    });
  });
}

class _FakeGoalRepository implements GoalRepository {
  const _FakeGoalRepository([this.goals = const []]);

  final List<Goal> goals;

  @override
  Future<List<Goal>> loadGoals() async {
    return goals;
  }

  @override
  Future<void> saveGoal(Goal goal) async {}
}

class _FakeMilestoneRepository implements MilestoneRepository {
  const _FakeMilestoneRepository([this.milestones = const []]);

  final List<Milestone> milestones;

  @override
  Future<List<Milestone>> loadMilestones() async {
    return milestones;
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async {}
}

class _FakeTaskRepository implements TaskRepository {
  const _FakeTaskRepository([this.tasks = const []]);

  final List<PlannerTask> tasks;

  @override
  Future<List<PlannerTask>> loadTasks() async {
    return tasks;
  }

  @override
  Future<void> saveTask(PlannerTask task) async {}

  @override
  Future<void> updateTask(PlannerTask task) async {}

  @override
  Future<void> deleteTask(String taskId) async {}
}

class _FakeRecurringTaskRepository implements RecurringTaskRepository {
  const _FakeRecurringTaskRepository({
    this.rules = const [],
    this.exceptions = const [],
  });

  final List<RecurringTaskRule> rules;
  final List<RecurringTaskException> exceptions;

  @override
  Future<List<RecurringTaskRule>> loadRecurringTaskRules() async {
    return rules;
  }

  @override
  Future<List<RecurringTaskException>> loadRecurringTaskExceptions() async {
    return exceptions;
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

class _FakeHabitRepository implements HabitRepository {
  const _FakeHabitRepository({this.habits = const [], this.entries = const []});

  final List<Habit> habits;
  final List<HabitEntry> entries;

  @override
  Future<List<Habit>> loadHabits() async {
    return habits;
  }

  @override
  Future<List<HabitEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return entries;
  }

  @override
  Future<List<HabitEntry>> loadAllEntries() async {
    return entries;
  }

  @override
  Future<void> saveHabit(Habit habit) async {}

  @override
  Future<void> saveEntry(HabitEntry entry) async {}

  @override
  Future<void> deleteEntry(String entryId) async {}

  @override
  Future<void> deleteHabit(String habitId) async {}
}

class _FakeBodyWeightRepository implements BodyWeightRepository {
  const _FakeBodyWeightRepository([this.entries = const []]);

  final List<BodyWeightEntry> entries;

  @override
  Future<void> deleteEntry(String entryId) async {}

  @override
  Future<List<BodyWeightEntry>> loadAllEntries() async {
    return entries;
  }

  @override
  Future<List<BodyWeightEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return entries;
  }

  @override
  Future<void> saveEntry(BodyWeightEntry entry) async {}
}

class _FakeStandaloneReminderRepository
    implements StandaloneReminderRepository {
  const _FakeStandaloneReminderRepository([this.reminders = const []]);

  final List<StandaloneReminder> reminders;

  @override
  Future<List<StandaloneReminder>> loadStandaloneReminders() async {
    return reminders;
  }

  @override
  Future<void> saveStandaloneReminder(StandaloneReminder reminder) async {}

  @override
  Future<void> updateStandaloneReminder(StandaloneReminder reminder) async {}

  @override
  Future<void> deleteStandaloneReminder(String reminderId) async {}
}

class _FakeDailyReviewReminderSettingsRepository
    implements DailyReviewReminderSettingsRepository {
  const _FakeDailyReviewReminderSettingsRepository(this.settings);

  final DailyReviewReminderSettings settings;

  @override
  Future<DailyReviewReminderSettings> loadSettings() async {
    return settings;
  }

  @override
  Future<void> saveSettings(DailyReviewReminderSettings settings) async {}
}
