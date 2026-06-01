import 'package:drift/drift.dart' as drift;

import '../../features/body_tracking/application/body_measurement_repository.dart';
import '../../features/body_tracking/domain/body_measurement_entry.dart'
    as domain;
import '../../shared/planner_dates.dart';
import '../local/app_database.dart' as local;

class DriftBodyMeasurementRepository implements BodyMeasurementRepository {
  const DriftBodyMeasurementRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<List<domain.BodyMeasurementEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);

    final rows =
        await (_database.select(_database.bodyMeasurementEntries)
              ..where((table) {
                return table.date.isBiggerOrEqualValue(start) &
                    table.date.isSmallerOrEqualValue(end);
              })
              ..orderBy([
                (table) => drift.OrderingTerm.asc(table.date),
                (table) => drift.OrderingTerm.asc(table.updatedAt),
              ]))
            .get();

    return rows.map(_mapBodyMeasurementEntry).toList(growable: false);
  }

  @override
  Future<List<domain.BodyMeasurementEntry>> loadAllEntries() async {
    final rows =
        await (_database.select(_database.bodyMeasurementEntries)..orderBy([
              (table) => drift.OrderingTerm.asc(table.date),
              (table) => drift.OrderingTerm.asc(table.updatedAt),
            ]))
            .get();

    return rows.map(_mapBodyMeasurementEntry).toList(growable: false);
  }

  @override
  Future<void> saveEntry(domain.BodyMeasurementEntry entry) async {
    await _database
        .into(_database.bodyMeasurementEntries)
        .insertOnConflictUpdate(
          local.BodyMeasurementEntriesCompanion.insert(
            id: entry.id,
            date: entry.date,
            neckCm: drift.Value(entry.neckCm),
            waistCm: drift.Value(entry.waistCm),
            hipsCm: drift.Value(entry.hipsCm),
            note: drift.Value(entry.note),
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
          ),
        );
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    await (_database.delete(
      _database.bodyMeasurementEntries,
    )..where((table) => table.id.equals(entryId))).go();
  }
}

domain.BodyMeasurementEntry _mapBodyMeasurementEntry(
  local.BodyMeasurementEntry row,
) {
  return domain.BodyMeasurementEntry(
    id: row.id,
    date: row.date,
    neckCm: row.neckCm,
    waistCm: row.waistCm,
    hipsCm: row.hipsCm,
    note: row.note,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
