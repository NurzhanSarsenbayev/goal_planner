import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_repository.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/features/reminders/habit/application/habit_reminder_pending_checker.dart';

void main() {
  group('HabitReminderPendingChecker', () {
    test('treats active reminder habit without today entry as pending', () {
      final checker = _checker();
      final habit = _habit();

      final isPending = checker.isHabitPendingToday(
        habit: habit,
        habitEntries: const [],
        today: DateTime(2026, 5, 24, 12),
      );

      expect(isPending, isTrue);
    });

    test('treats none and incomplete today entries as pending', () {
      final checker = _checker();
      final today = DateTime(2026, 5, 24);
      final noneHabit = _habit(id: 'none');
      final incompleteHabit = _habit(id: 'incomplete');

      expect(
        checker.isHabitPendingToday(
          habit: noneHabit,
          habitEntries: [
            _entry(
              habitId: noneHabit.id,
              date: today,
              status: HabitEntryStatus.none,
            ),
          ],
          today: today,
        ),
        isTrue,
      );

      expect(
        checker.isHabitPendingToday(
          habit: incompleteHabit,
          habitEntries: [
            _entry(
              habitId: incompleteHabit.id,
              date: today,
              status: HabitEntryStatus.incomplete,
            ),
          ],
          today: today,
        ),
        isTrue,
      );
    });

    test('suppresses done skipped and failed today entries', () {
      final checker = _checker();
      final today = DateTime(2026, 5, 24);

      for (final status in [
        HabitEntryStatus.done,
        HabitEntryStatus.skipped,
        HabitEntryStatus.failed,
      ]) {
        final habit = _habit(id: status.name);

        final isPending = checker.isHabitPendingToday(
          habit: habit,
          habitEntries: [
            _entry(habitId: habit.id, date: today, status: status),
          ],
          today: today,
        );

        expect(isPending, isFalse, reason: status.name);
      }
    });

    test('ignores entry from another date', () {
      final checker = _checker();
      final habit = _habit();

      final isPending = checker.isHabitPendingToday(
        habit: habit,
        habitEntries: [
          _entry(
            habitId: habit.id,
            date: DateTime(2026, 5, 23),
            status: HabitEntryStatus.done,
          ),
        ],
        today: DateTime(2026, 5, 24),
      );

      expect(isPending, isTrue);
    });

    test('does not notify archived habit', () {
      final checker = _checker();

      final isPending = checker.isHabitPendingToday(
        habit: _habit(isArchived: true),
        habitEntries: const [],
        today: DateTime(2026, 5, 24),
      );

      expect(isPending, isFalse);
    });

    test('does not notify disabled reminder habit', () {
      final checker = _checker();

      final isPending = checker.isHabitPendingToday(
        habit: _habit(isReminderEnabled: false),
        habitEntries: const [],
        today: DateTime(2026, 5, 24),
      );

      expect(isPending, isFalse);
    });

    test('loads today entries from repository', () async {
      final today = DateTime(2026, 5, 24);
      final habit = _habit();
      final repository = _FakeHabitRepository(
        entries: [
          _entry(habitId: habit.id, date: today, status: HabitEntryStatus.done),
        ],
      );
      final checker = HabitReminderPendingChecker(
        habitRepository: repository,
        todayProvider: () => today,
      );

      final shouldNotify = await checker.shouldNotifyHabitToday(habit);

      expect(shouldNotify, isFalse);
      expect(repository.loadedStartDate, today);
      expect(repository.loadedEndDate, today);
    });
  });
}

HabitReminderPendingChecker _checker() {
  return HabitReminderPendingChecker(
    habitRepository: const _FakeHabitRepository(),
    todayProvider: () => DateTime(2026, 5, 24),
  );
}

Habit _habit({
  String id = 'habit-1',
  bool isArchived = false,
  bool isReminderEnabled = true,
  int? reminderTimeMinutes = 20 * 60,
}) {
  final now = DateTime(2026, 5, 24, 10);

  return Habit(
    id: id,
    title: 'Habit $id',
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: 0,
    isArchived: isArchived,
    isReminderEnabled: isReminderEnabled,
    reminderTimeMinutes: reminderTimeMinutes,
    createdAt: now,
    updatedAt: now,
  );
}

HabitEntry _entry({
  required String habitId,
  required DateTime date,
  required HabitEntryStatus status,
}) {
  final now = DateTime(2026, 5, 24, 10);

  return HabitEntry(
    id: 'entry-$habitId-${date.toIso8601String()}',
    habitId: habitId,
    date: date,
    status: status,
    completedCount: status == HabitEntryStatus.done ? 1 : 0,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeHabitRepository implements HabitRepository {
  const _FakeHabitRepository({this.entries = const []});

  final List<HabitEntry> entries;

  static DateTime? _loadedStartDate;
  static DateTime? _loadedEndDate;

  DateTime? get loadedStartDate => _loadedStartDate;

  DateTime? get loadedEndDate => _loadedEndDate;

  @override
  Future<List<Habit>> loadHabits() async {
    return const [];
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
        .toList(growable: false);
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
