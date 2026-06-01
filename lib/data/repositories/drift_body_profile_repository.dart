import 'package:drift/drift.dart' as drift;

import '../../features/body_tracking/application/body_profile_repository.dart';
import '../../features/body_tracking/domain/body_profile.dart' as domain;
import '../local/app_database.dart' as local;

class DriftBodyProfileRepository implements BodyProfileRepository {
  const DriftBodyProfileRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<domain.BodyProfile?> loadProfile() async {
    final row =
        await (_database.select(_database.bodyProfiles)
              ..where((table) => table.id.equals(domain.defaultBodyProfileId))
              ..limit(1))
            .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _mapBodyProfile(row);
  }

  @override
  Future<void> saveProfile(domain.BodyProfile profile) async {
    await _database
        .into(_database.bodyProfiles)
        .insertOnConflictUpdate(
          local.BodyProfilesCompanion.insert(
            id: profile.id,
            heightCm: profile.heightCm,
            bodyFatFormula: domain.bodyFatFormulaToStorage(
              profile.bodyFatFormula,
            ),
            createdAt: profile.createdAt,
            updatedAt: profile.updatedAt,
          ),
        );
  }

  @override
  Future<void> deleteProfile() async {
    await (_database.delete(
      _database.bodyProfiles,
    )..where((table) => table.id.equals(domain.defaultBodyProfileId))).go();
  }
}

domain.BodyProfile _mapBodyProfile(local.BodyProfile row) {
  return domain.BodyProfile(
    id: row.id,
    heightCm: row.heightCm,
    bodyFatFormula: domain.bodyFatFormulaFromStorage(row.bodyFatFormula),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
