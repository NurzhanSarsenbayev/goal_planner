import 'package:drift/drift.dart' as drift;

import '../../features/body_tracking/application/body_weight_repository.dart';
import '../../features/body_tracking/domain/body_weight_entry.dart' as domain;
import '../../shared/planner_dates.dart';
import '../local/app_database.dart' as local;

class DriftBodyWeightRepository implements BodyWeightRepository {
  const DriftBodyWeightRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<List<domain.BodyWeightEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);

    final rows =
        await (_database.select(_database.bodyWeightEntries)
              ..where((table) {
                return table.date.isBiggerOrEqualValue(start) &
                    table.date.isSmallerOrEqualValue(end);
              })
              ..orderBy([
                (table) => drift.OrderingTerm.asc(table.date),
                (table) => drift.OrderingTerm.asc(table.createdAt),
              ]))
            .get();

    return rows.map(_mapBodyWeightEntry).toList(growable: false);
  }

  @override
  Future<List<domain.BodyWeightEntry>> loadAllEntries() async {
    final rows =
        await (_database.select(_database.bodyWeightEntries)..orderBy([
              (table) => drift.OrderingTerm.asc(table.date),
              (table) => drift.OrderingTerm.asc(table.createdAt),
            ]))
            .get();

    return rows.map(_mapBodyWeightEntry).toList(growable: false);
  }

  @override
  Future<void> saveEntry(domain.BodyWeightEntry entry) async {
    await _database
        .into(_database.bodyWeightEntries)
        .insertOnConflictUpdate(
          local.BodyWeightEntriesCompanion.insert(
            id: entry.id,
            date: entry.date,
            weightKg: drift.Value(entry.weightKg),
            isSkipped: drift.Value(entry.isSkipped),
            note: drift.Value(entry.note),
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
          ),
        );
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    await (_database.delete(
      _database.bodyWeightEntries,
    )..where((table) => table.id.equals(entryId))).go();
  }
}

domain.BodyWeightEntry _mapBodyWeightEntry(local.BodyWeightEntry row) {
  return domain.BodyWeightEntry(
    id: row.id,
    date: row.date,
    weightKg: row.weightKg,
    isSkipped: row.isSkipped,
    note: row.note,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
