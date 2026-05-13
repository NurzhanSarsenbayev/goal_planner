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
        now: () => now,
      );

      final backup = await service.createBackup();

      expect(backup.exportedAt, now);
      expect(backup.data.goals.single.id, goal.id);
      expect(backup.data.milestones.single.id, milestone.id);
      expect(backup.data.tasks.single.id, task.id);
      expect(backup.data.recurringRules.single.id, recurringRule.id);
      expect(backup.data.recurringExceptions.single.id, recurringException.id);
      expect(backup.data.habits.single.id, habit.id);
      expect(backup.data.habitEntries.single.id, habitEntry.id);
    });

    test('supports empty repositories', () async {
      final now = DateTime(2026, 5, 13);

      final service = PlannerBackupExportService(
        goalRepository: _FakeGoalRepository(),
        milestoneRepository: _FakeMilestoneRepository(),
        taskRepository: _FakeTaskRepository(),
        recurringTaskRepository: _FakeRecurringTaskRepository(),
        habitRepository: _FakeHabitRepository(),
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
