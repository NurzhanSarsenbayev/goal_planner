import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_body_profile_repository.dart';
import 'package:goal_planner/features/body_tracking/domain/body_profile.dart';

void main() {
  group('DriftBodyProfileRepository', () {
    late local.AppDatabase database;
    late DriftBodyProfileRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftBodyProfileRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('returns null when profile does not exist', () async {
      final profile = await repository.loadProfile();

      expect(profile, isNull);
    });

    test('persists and loads body profile', () async {
      final profile = _profile();

      await repository.saveProfile(profile);

      final loadedProfile = await repository.loadProfile();

      expect(loadedProfile, isNotNull);
      expect(loadedProfile!.id, defaultBodyProfileId);
      expect(loadedProfile.heightCm, 168);
      expect(loadedProfile.bodyFatFormula, BodyFatFormula.usNavyFemale);
      expect(loadedProfile.createdAt, profile.createdAt);
      expect(loadedProfile.updatedAt, profile.updatedAt);
    });

    test('updates existing body profile', () async {
      final profile = _profile();
      final updatedAt = DateTime(2026, 6, 1, 12);

      await repository.saveProfile(profile);
      await repository.saveProfile(
        profile.copyWith(
          heightCm: 169,
          bodyFatFormula: BodyFatFormula.usNavyMale,
          updatedAt: updatedAt,
        ),
      );

      final loadedProfile = await repository.loadProfile();

      expect(loadedProfile, isNotNull);
      expect(loadedProfile!.heightCm, 169);
      expect(loadedProfile.bodyFatFormula, BodyFatFormula.usNavyMale);
      expect(loadedProfile.createdAt, profile.createdAt);
      expect(loadedProfile.updatedAt, updatedAt);
    });

    test('deletes body profile', () async {
      await repository.saveProfile(_profile());

      await repository.deleteProfile();

      final loadedProfile = await repository.loadProfile();

      expect(loadedProfile, isNull);
    });
  });
}

BodyProfile _profile() {
  final now = DateTime(2026, 6, 1, 8);

  return BodyProfile(
    id: defaultBodyProfileId,
    heightCm: 168,
    bodyFatFormula: BodyFatFormula.usNavyFemale,
    createdAt: now,
    updatedAt: now,
  );
}
