import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/application/body_profile_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_profile_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/features/body_tracking/domain/body_profile.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';
import 'package:goal_planner/shared/planner_dates.dart';

void main() {
  group('BodyProfileTrackingService', () {
    late _FakeBodyProfileRepository profileRepository;
    late _FakeBodyWeightRepository weightRepository;
    late _FakeBodyMeasurementRepository measurementRepository;
    late DateTime now;
    late BodyProfileTrackingService service;

    setUp(() {
      profileRepository = _FakeBodyProfileRepository();
      weightRepository = _FakeBodyWeightRepository();
      measurementRepository = _FakeBodyMeasurementRepository();
      now = DateTime(2026, 6, 1, 8);
      service = BodyProfileTrackingService(
        profileRepository: profileRepository,
        weightRepository: weightRepository,
        measurementRepository: measurementRepository,
        now: () => now,
      );
    });

    test('returns null when profile does not exist', () async {
      final profile = await service.loadProfile();

      expect(profile, isNull);
    });

    test('saves body profile with default id', () async {
      await service.saveProfile(
        heightCm: 168,
        bodyFatFormula: BodyFatFormula.usNavyFemale,
      );

      final profile = await service.loadProfile();

      expect(profile, isNotNull);
      expect(profile!.id, defaultBodyProfileId);
      expect(profile.heightCm, 168);
      expect(profile.bodyFatFormula, BodyFatFormula.usNavyFemale);
      expect(profile.createdAt, now);
      expect(profile.updatedAt, now);
    });

    test('updates body profile and preserves createdAt', () async {
      final createdAt = now;

      await service.saveProfile(
        heightCm: 168,
        bodyFatFormula: BodyFatFormula.usNavyFemale,
      );

      now = DateTime(2026, 6, 2, 9);

      await service.saveProfile(
        heightCm: 169,
        bodyFatFormula: BodyFatFormula.usNavyMale,
      );

      final profile = await service.loadProfile();

      expect(profile, isNotNull);
      expect(profile!.id, defaultBodyProfileId);
      expect(profile.heightCm, 169);
      expect(profile.bodyFatFormula, BodyFatFormula.usNavyMale);
      expect(profile.createdAt, createdAt);
      expect(profile.updatedAt, now);
    });

    test('throws when height is non-positive', () {
      expect(
        service.saveProfile(
          heightCm: 0,
          bodyFatFormula: BodyFatFormula.usNavyFemale,
        ),
        throwsArgumentError,
      );
    });

    test('deletes body profile', () async {
      await service.saveProfile(
        heightCm: 168,
        bodyFatFormula: BodyFatFormula.usNavyFemale,
      );

      await service.deleteProfile();

      final profile = await service.loadProfile();

      expect(profile, isNull);
    });

    test('returns empty metrics when profile does not exist', () async {
      final metrics = await service.loadCurrentMetrics();

      expect(metrics.bmi, isNull);
      expect(metrics.estimatedBodyFatPercent, isNull);
      expect(metrics.hasAnyMetric, isFalse);
    });

    test('loads current metrics from latest weight and measurements', () async {
      await service.saveProfile(
        heightCm: 168,
        bodyFatFormula: BodyFatFormula.usNavyFemale,
      );

      final weightTrackingService = BodyWeightTrackingService(
        repository: weightRepository,
      );
      final measurementTrackingService = BodyMeasurementTrackingService(
        repository: measurementRepository,
      );

      await weightTrackingService.saveWeightForDate(
        date: DateTime(2026, 5, 25),
        weightKg: 61,
      );
      await weightTrackingService.saveWeightForDate(
        date: DateTime(2026, 6, 1),
        weightKg: 60,
      );
      await measurementTrackingService.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 5, 25),
        neckCm: 35,
        waistCm: 76,
        hipsCm: 102,
      );
      await measurementTrackingService.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 6, 1),
        neckCm: 34,
        waistCm: 74,
        hipsCm: 101,
      );

      final metrics = await service.loadCurrentMetrics();

      expect(metrics.bmi, closeTo(21.26, 0.01));
      expect(metrics.estimatedBodyFatPercent, closeTo(28.14, 0.01));
      expect(metrics.hasAnyMetric, isTrue);
    });
  });
}

class _FakeBodyProfileRepository implements BodyProfileRepository {
  BodyProfile? _profile;

  @override
  Future<void> deleteProfile() async {
    _profile = null;
  }

  @override
  Future<BodyProfile?> loadProfile() async {
    return _profile;
  }

  @override
  Future<void> saveProfile(BodyProfile profile) async {
    _profile = profile;
  }
}

class _FakeBodyWeightRepository implements BodyWeightRepository {
  final Map<String, BodyWeightEntry> _entriesById = {};

  @override
  Future<void> deleteEntry(String entryId) async {
    _entriesById.remove(entryId);
  }

  @override
  Future<List<BodyWeightEntry>> loadAllEntries() async {
    return _sortedEntries(_entriesById.values);
  }

  @override
  Future<List<BodyWeightEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);
    final entries = _entriesById.values.where((entry) {
      final entryDate = dateOnly(entry.date);

      return !entryDate.isBefore(start) && !entryDate.isAfter(end);
    });

    return _sortedEntries(entries);
  }

  @override
  Future<void> saveEntry(BodyWeightEntry entry) async {
    _entriesById[entry.id] = entry;
  }

  List<BodyWeightEntry> _sortedEntries(Iterable<BodyWeightEntry> entries) {
    return entries.toList(growable: false)..sort((firstEntry, secondEntry) {
      final dateComparison = firstEntry.date.compareTo(secondEntry.date);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return firstEntry.updatedAt.compareTo(secondEntry.updatedAt);
    });
  }
}

class _FakeBodyMeasurementRepository implements BodyMeasurementRepository {
  final Map<String, BodyMeasurementEntry> _entriesById = {};

  @override
  Future<void> deleteEntry(String entryId) async {
    _entriesById.remove(entryId);
  }

  @override
  Future<List<BodyMeasurementEntry>> loadAllEntries() async {
    return _sortedEntries(_entriesById.values);
  }

  @override
  Future<List<BodyMeasurementEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);
    final entries = _entriesById.values.where((entry) {
      final entryDate = dateOnly(entry.date);

      return !entryDate.isBefore(start) && !entryDate.isAfter(end);
    });

    return _sortedEntries(entries);
  }

  @override
  Future<void> saveEntry(BodyMeasurementEntry entry) async {
    _entriesById[entry.id] = entry;
  }

  List<BodyMeasurementEntry> _sortedEntries(
    Iterable<BodyMeasurementEntry> entries,
  ) {
    return entries.toList(growable: false)..sort((firstEntry, secondEntry) {
      final dateComparison = firstEntry.date.compareTo(secondEntry.date);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return firstEntry.updatedAt.compareTo(secondEntry.updatedAt);
    });
  }
}
