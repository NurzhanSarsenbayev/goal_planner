import 'package:drift/drift.dart' as drift;

import '../../features/habits/application/habit_repository.dart';
import '../../features/habits/domain/habit.dart' as domain;
import '../../features/habits/domain/habit_entry.dart' as domain;
import '../../shared/planner_dates.dart';
import '../local/app_database.dart' as local;
import 'habit_mappers.dart';

class DriftHabitRepository implements HabitRepository {
  const DriftHabitRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<List<domain.Habit>> loadHabits() async {
    final rows =
        await (_database.select(_database.habits)..orderBy([
              (table) => drift.OrderingTerm.asc(table.sortOrder),
              (table) => drift.OrderingTerm.asc(table.createdAt),
            ]))
            .get();

    return rows.map(mapHabit).toList();
  }

  @override
  Future<List<domain.HabitEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);

    final rows =
        await (_database.select(_database.habitEntries)..where((table) {
              return table.date.isBiggerOrEqualValue(start) &
                  table.date.isSmallerOrEqualValue(end);
            }))
            .get();

    return rows.map(mapHabitEntry).toList();
  }

  @override
  Future<List<domain.HabitEntry>> loadAllEntries() async {
    final rows =
        await (_database.select(_database.habitEntries)..orderBy([
              (table) => drift.OrderingTerm.asc(table.date),
              (table) => drift.OrderingTerm.asc(table.createdAt),
            ]))
            .get();

    return rows.map(mapHabitEntry).toList();
  }

  @override
  Future<void> saveHabit(domain.Habit habit) async {
    await _database
        .into(_database.habits)
        .insertOnConflictUpdate(
          local.HabitsCompanion.insert(
            id: habit.id,
            title: habit.title,
            description: drift.Value(habit.description),
            trackingType: habitTrackingTypeToDatabaseValue(habit.trackingType),
            targetCount: drift.Value(habit.targetCount),
            sortOrder: habit.sortOrder,
            isArchived: drift.Value(habit.isArchived),
            createdAt: habit.createdAt,
            updatedAt: habit.updatedAt,
          ),
        );
  }

  @override
  Future<void> saveEntry(domain.HabitEntry entry) async {
    await _database
        .into(_database.habitEntries)
        .insertOnConflictUpdate(
          local.HabitEntriesCompanion.insert(
            id: entry.id,
            habitId: entry.habitId,
            date: entry.date,
            status: habitEntryStatusToDatabaseValue(entry.status),
            completedCount: drift.Value(entry.completedCount),
            note: drift.Value(entry.note),
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
          ),
        );
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    await (_database.delete(
      _database.habitEntries,
    )..where((table) => table.id.equals(entryId))).go();
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await (_database.delete(
      _database.habits,
    )..where((table) => table.id.equals(habitId))).go();
  }
}
