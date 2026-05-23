import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_repository.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/features/reminders/application/daily_review_pending_checker.dart';
import 'package:goal_planner/features/tasks/application/task_repository.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('DailyReviewPendingChecker', () {
    test('counts unfinished today tasks, overdue tasks and pending habits', () {
      final reviewDate = DateTime(2026, 5, 21);
      final checker = _checker();

      final summary = checker.buildPendingSummary(
        reviewDate: reviewDate,
        tasks: [
          _task(id: 'today_open', scheduledDate: reviewDate),
          _task(id: 'today_done', scheduledDate: reviewDate, isCompleted: true),
          _task(id: 'overdue_open', scheduledDate: DateTime(2026, 5, 20)),
          _task(id: 'future_open', scheduledDate: DateTime(2026, 5, 22)),
          _task(id: 'unscheduled_open'),
        ],
        habits: [
          _habit(id: 'pending_missing_entry'),
          _habit(id: 'done'),
          _habit(id: 'skipped'),
          _habit(id: 'archived', isArchived: true),
        ],
        habitEntries: [
          _entry(
            habitId: 'done',
            date: reviewDate,
            status: HabitEntryStatus.done,
          ),
          _entry(
            habitId: 'skipped',
            date: reviewDate,
            status: HabitEntryStatus.skipped,
          ),
        ],
      );

      expect(summary.unfinishedTodayTaskCount, 1);
      expect(summary.overdueTaskCount, 1);
      expect(summary.pendingHabitCount, 1);
      expect(summary.pendingItemCount, 3);
      expect(summary.hasPendingItems, isTrue);
    });

    test('treats done, skipped and failed habit entries as filled', () {
      final reviewDate = DateTime(2026, 5, 21);
      final checker = _checker();

      final summary = checker.buildPendingSummary(
        reviewDate: reviewDate,
        tasks: const [],
        habits: [
          _habit(id: 'done'),
          _habit(id: 'skipped'),
          _habit(id: 'failed'),
        ],
        habitEntries: [
          _entry(
            habitId: 'done',
            date: reviewDate,
            status: HabitEntryStatus.done,
          ),
          _entry(
            habitId: 'skipped',
            date: reviewDate,
            status: HabitEntryStatus.skipped,
          ),
          _entry(
            habitId: 'failed',
            date: reviewDate,
            status: HabitEntryStatus.failed,
          ),
        ],
      );

      expect(summary.pendingHabitCount, 0);
      expect(summary.hasPendingItems, isFalse);
    });

    test('counts incomplete habit entry as pending', () {
      final reviewDate = DateTime(2026, 5, 21);
      final checker = _checker();

      final summary = checker.buildPendingSummary(
        reviewDate: reviewDate,
        tasks: const [],
        habits: [_habit(id: 'incomplete')],
        habitEntries: [
          _entry(
            habitId: 'incomplete',
            date: reviewDate,
            status: HabitEntryStatus.incomplete,
          ),
        ],
      );

      expect(summary.pendingHabitCount, 1);
      expect(summary.hasPendingItems, isTrue);
    });

    test('counts habit entry with none status as pending', () {
      final reviewDate = DateTime(2026, 5, 21);
      final checker = _checker();

      final summary = checker.buildPendingSummary(
        reviewDate: reviewDate,
        tasks: const [],
        habits: [_habit(id: 'habit_1')],
        habitEntries: [
          _entry(
            habitId: 'habit_1',
            date: reviewDate,
            status: HabitEntryStatus.none,
          ),
        ],
      );

      expect(summary.pendingHabitCount, 1);
      expect(summary.hasPendingItems, isTrue);
    });

    test('returns empty summary when there are no pending items', () {
      final reviewDate = DateTime(2026, 5, 21);
      final checker = _checker();

      final summary = checker.buildPendingSummary(
        reviewDate: reviewDate,
        tasks: [
          _task(id: 'today_done', scheduledDate: reviewDate, isCompleted: true),
          _task(id: 'future_open', scheduledDate: DateTime(2026, 5, 22)),
        ],
        habits: [_habit(id: 'done')],
        habitEntries: [
          _entry(
            habitId: 'done',
            date: reviewDate,
            status: HabitEntryStatus.done,
          ),
        ],
      );

      expect(summary.unfinishedTodayTaskCount, 0);
      expect(summary.overdueTaskCount, 0);
      expect(summary.pendingHabitCount, 0);
      expect(summary.pendingItemCount, 0);
      expect(summary.hasPendingItems, isFalse);
    });

    test('loads pending summary from repositories for today', () async {
      final today = DateTime(2026, 5, 21);
      final taskRepository = _FakeTaskRepository([
        _task(id: 'today_open', scheduledDate: today),
      ]);
      final habitRepository = _FakeHabitRepository(
        habits: [_habit(id: 'habit_1')],
        entries: const [],
      );
      final checker = DailyReviewPendingChecker(
        taskRepository: taskRepository,
        habitRepository: habitRepository,
        todayProvider: () => today,
      );

      final summary = await checker.loadPendingSummary();

      expect(summary.unfinishedTodayTaskCount, 1);
      expect(summary.pendingHabitCount, 1);
      expect(habitRepository.loadedStartDate, today);
      expect(habitRepository.loadedEndDate, today);
    });
  });
}

DailyReviewPendingChecker _checker() {
  return DailyReviewPendingChecker(
    taskRepository: const _FakeTaskRepository(),
    habitRepository: const _FakeHabitRepository(),
    todayProvider: () => DateTime(2026, 5, 21),
  );
}

PlannerTask _task({
  required String id,
  DateTime? scheduledDate,
  bool isCompleted = false,
}) {
  final now = DateTime(2026, 5, 21, 8);

  return PlannerTask(
    id: id,
    title: 'Task $id',
    description: '',
    createdAt: now,
    scheduledDate: scheduledDate,
    isCompleted: isCompleted,
    completedAt: isCompleted ? now : null,
  );
}

Habit _habit({required String id, bool isArchived = false}) {
  final now = DateTime(2026, 5, 21, 8);

  return Habit(
    id: id,
    title: 'Habit $id',
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: 0,
    isArchived: isArchived,
    createdAt: now,
    updatedAt: now,
  );
}

HabitEntry _entry({
  required String habitId,
  required DateTime date,
  required HabitEntryStatus status,
}) {
  final now = DateTime(2026, 5, 21, 8);

  return HabitEntry(
    id: 'entry_$habitId',
    habitId: habitId,
    date: date,
    status: status,
    completedCount: status == HabitEntryStatus.done ? 1 : 0,
    createdAt: now,
    updatedAt: now,
  );
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

class _FakeHabitRepository implements HabitRepository {
  const _FakeHabitRepository({this.habits = const [], this.entries = const []});

  final List<Habit> habits;
  final List<HabitEntry> entries;

  static DateTime? _loadedStartDate;
  static DateTime? _loadedEndDate;

  DateTime? get loadedStartDate => _loadedStartDate;

  DateTime? get loadedEndDate => _loadedEndDate;

  @override
  Future<List<Habit>> loadHabits() async {
    return habits;
  }

  @override
  Future<List<HabitEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _loadedStartDate = startDate;
    _loadedEndDate = endDate;

    return entries
        .where((entry) => !entry.date.isBefore(startDate))
        .where((entry) => !entry.date.isAfter(endDate))
        .toList();
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
