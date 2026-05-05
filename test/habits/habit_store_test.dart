import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_repository.dart';
import 'package:goal_planner/features/habits/application/habit_store.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';

void main() {
  group('HabitStore', () {
    test('initializes habits and visible week entries', () async {
      final habit = _habit();
      final entry = _entry(habitId: habit.id);
      final repository = _FakeHabitRepository(
        habits: [habit],
        entries: [entry],
      );
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();

      expect(store.isInitialized, isTrue);
      expect(store.isLoading, isFalse);
      expect(store.habits, [habit]);
      expect(store.visibleWeekEntries, [entry]);
      expect(repository.loadedEntryStartDate, DateTime(2026, 5, 4));
      expect(repository.loadedEntryEndDate, DateTime(2026, 5, 10));
    });

    test('builds week view from current state', () async {
      final habit = _habit();
      final entry = _entry(
        habitId: habit.id,
        date: DateTime(2026, 5, 6),
        status: HabitEntryStatus.done,
      );
      final store = HabitStore(
        habitRepository: _FakeHabitRepository(
          habits: [habit],
          entries: [entry],
        ),
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();

      final view = store.weekView;

      expect(view.rows, hasLength(1));
      expect(view.rows.single.cells[2].status, HabitEntryStatus.done);
    });

    test('changes visible week and reloads entries for range', () async {
      final repository = _FakeHabitRepository();
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();
      await store.goToNextWeek();

      expect(store.visibleWeekStart, DateTime(2026, 5, 11));
      expect(repository.loadedEntryStartDate, DateTime(2026, 5, 11));
      expect(repository.loadedEntryEndDate, DateTime(2026, 5, 17));
    });

    test('creates habit and persists it', () async {
      final repository = _FakeHabitRepository();
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();
      await store.createHabit(title: '  Water  ', description: '');

      expect(store.habits, hasLength(1));
      expect(store.habits.single.title, 'Water');
      expect(repository.savedHabits, [store.habits.single]);
    });

    test('updates habit and persists it', () async {
      final habit = _habit(title: 'Old');
      final repository = _FakeHabitRepository(habits: [habit]);
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();
      await store.updateHabit(
        habitId: habit.id,
        title: 'New',
        description: 'Updated',
      );

      expect(store.habits.single.title, 'New');
      expect(repository.savedHabits.single.title, 'New');
    });

    test('archives habit and persists it', () async {
      final habit = _habit();
      final repository = _FakeHabitRepository(habits: [habit]);
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();
      await store.archiveHabit(habit.id);

      expect(store.habits.single.isArchived, isTrue);
      expect(repository.savedHabits.single.isArchived, isTrue);
    });

    test('deletes habit and removes visible entries for that habit', () async {
      final habit = _habit();
      final entry = _entry(habitId: habit.id);
      final repository = _FakeHabitRepository(
        habits: [habit],
        entries: [entry],
      );
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();
      await store.deleteHabit(habit.id);

      expect(store.habits, isEmpty);
      expect(store.visibleWeekEntries, isEmpty);
      expect(repository.deletedHabitIds, [habit.id]);
    });

    test('marks entry and persists it', () async {
      final habit = _habit();
      final repository = _FakeHabitRepository(habits: [habit]);
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();
      await store.markEntry(
        habitId: habit.id,
        date: DateTime(2026, 5, 6),
        status: HabitEntryStatus.done,
      );

      expect(store.visibleWeekEntries, hasLength(1));
      expect(store.visibleWeekEntries.single.status, HabitEntryStatus.done);
      expect(repository.savedEntries, [store.visibleWeekEntries.single]);
    });

    test('does not mark entry for missing habit', () async {
      final repository = _FakeHabitRepository();
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();
      await store.markEntry(
        habitId: 'missing',
        date: DateTime(2026, 5, 6),
        status: HabitEntryStatus.done,
      );

      expect(store.visibleWeekEntries, isEmpty);
      expect(repository.savedEntries, isEmpty);
    });

    test('clears entry and persists deletion', () async {
      final habit = _habit();
      final entry = _entry(habitId: habit.id);
      final repository = _FakeHabitRepository(
        habits: [habit],
        entries: [entry],
      );
      final store = HabitStore(
        habitRepository: repository,
        initialWeekStart: DateTime(2026, 5, 4),
      );

      await store.initialize();
      await store.clearEntry(habitId: habit.id, date: DateTime(2026, 5, 5));

      expect(store.visibleWeekEntries, isEmpty);
      expect(repository.deletedEntryIds, [entry.id]);
    });
  });
}

class _FakeHabitRepository implements HabitRepository {
  _FakeHabitRepository({
    List<Habit> habits = const [],
    List<HabitEntry> entries = const [],
  }) : _habits = habits,
       _entries = entries;

  final List<Habit> _habits;
  final List<HabitEntry> _entries;

  final savedHabits = <Habit>[];
  final savedEntries = <HabitEntry>[];
  final deletedHabitIds = <String>[];
  final deletedEntryIds = <String>[];

  DateTime? loadedEntryStartDate;
  DateTime? loadedEntryEndDate;

  @override
  Future<List<Habit>> loadHabits() async {
    return _habits;
  }

  @override
  Future<List<HabitEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    loadedEntryStartDate = startDate;
    loadedEntryEndDate = endDate;
    return _entries;
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    savedHabits.add(habit);
  }

  @override
  Future<void> saveEntry(HabitEntry entry) async {
    savedEntries.add(entry);
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    deletedEntryIds.add(entryId);
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    deletedHabitIds.add(habitId);
  }
}

Habit _habit({
  String id = 'habit-1',
  String title = 'Habit',
  String description = '',
  HabitTrackingType trackingType = HabitTrackingType.binary,
  int? targetCount,
  int sortOrder = 0,
  bool isArchived = false,
}) {
  return Habit(
    id: id,
    title: title,
    description: description,
    trackingType: trackingType,
    targetCount: targetCount,
    sortOrder: sortOrder,
    isArchived: isArchived,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}

HabitEntry _entry({
  String id = 'entry-1',
  required String habitId,
  DateTime? date,
  HabitEntryStatus status = HabitEntryStatus.none,
  int completedCount = 0,
}) {
  return HabitEntry(
    id: id,
    habitId: habitId,
    date: date ?? DateTime(2026, 5, 5),
    status: status,
    completedCount: completedCount,
    createdAt: DateTime(2026, 5, 5),
    updatedAt: DateTime(2026, 5, 5),
  );
}
