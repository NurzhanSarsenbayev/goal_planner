import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_weight_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';
import 'package:goal_planner/shared/planner_dates.dart';

void main() {
  group('BodyWeightTrackingService', () {
    late _FakeBodyWeightRepository repository;
    late DateTime now;
    late BodyWeightTrackingService service;

    setUp(() {
      repository = _FakeBodyWeightRepository();
      now = DateTime(2026, 5, 25, 8);
      service = BodyWeightTrackingService(
        repository: repository,
        now: () => now,
      );
    });

    test('saves weight for selected date with stable date id', () async {
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 25, 20),
        weightKg: 80.5,
        note: ' Morning weight ',
      );

      final entry = await service.loadEntryForDate(DateTime(2026, 5, 25));

      expect(entry, isNotNull);
      expect(entry!.id, 'body-weight-2026-05-25');
      expect(entry.date, DateTime(2026, 5, 25));
      expect(entry.weightKg, 80.5);
      expect(entry.isSkipped, isFalse);
      expect(entry.note, 'Morning weight');
      expect(entry.createdAt, now);
      expect(entry.updatedAt, now);
    });

    test('updates same date without creating duplicate entry', () async {
      final createdAt = now;

      await service.saveWeightForDate(
        date: DateTime(2026, 5, 25),
        weightKg: 80.5,
      );

      now = DateTime(2026, 5, 25, 12);

      await service.saveWeightForDate(
        date: DateTime(2026, 5, 25),
        weightKg: 79.8,
        note: 'Updated',
      );

      final entries = await repository.loadAllEntries();

      expect(entries, hasLength(1));
      expect(entries.single.weightKg, 79.8);
      expect(entries.single.isSkipped, isFalse);
      expect(entries.single.note, 'Updated');
      expect(entries.single.createdAt, createdAt);
      expect(entries.single.updatedAt, now);
    });

    test('marks selected date as skipped and clears weight', () async {
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 25),
        weightKg: 80.5,
      );

      now = DateTime(2026, 5, 25, 12);

      await service.markSkippedForDate(
        date: DateTime(2026, 5, 25),
        note: 'Did not weigh',
      );

      final entry = await service.loadEntryForDate(DateTime(2026, 5, 25));

      expect(entry, isNotNull);
      expect(entry!.weightKg, isNull);
      expect(entry.isSkipped, isTrue);
      expect(entry.note, 'Did not weigh');
      expect(entry.updatedAt, now);
    });

    test('clears selected date entry', () async {
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 25),
        weightKg: 80.5,
      );

      await service.clearEntryForDate(DateTime(2026, 5, 25));

      final entry = await service.loadEntryForDate(DateTime(2026, 5, 25));

      expect(entry, isNull);
    });

    test('does nothing when clearing empty date', () async {
      await service.clearEntryForDate(DateTime(2026, 5, 25));

      final entries = await repository.loadAllEntries();

      expect(entries, isEmpty);
    });

    test('throws when saving non-positive weight', () async {
      expect(
        service.saveWeightForDate(date: DateTime(2026, 5, 25), weightKg: 0),
        throwsArgumentError,
      );
    });

    test('loads weekly report with previous week deltas', () async {
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 18),
        weightKg: 81,
      );
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 19),
        weightKg: 80,
      );
      await service.markSkippedForDate(date: DateTime(2026, 5, 20));

      await service.saveWeightForDate(
        date: DateTime(2026, 5, 25),
        weightKg: 80,
      );
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 26),
        weightKg: 79,
      );
      await service.markSkippedForDate(date: DateTime(2026, 5, 27));

      final report = await service.loadWeeklyReport(DateTime(2026, 5, 28));

      expect(report.weekStartDate, DateTime(2026, 5, 25));
      expect(report.weekEndDate, DateTime(2026, 5, 31));
      expect(report.weighedDaysCount, 2);
      expect(report.skippedDaysCount, 1);
      expect(report.missingDaysCount, 4);
      expect(report.averageWeightKg, closeTo(79.5, 0.000001));
      expect(report.minWeightKg, 79);
      expect(report.averageWeightDeltaKg, closeTo(-1, 0.000001));
      expect(report.minWeightDeltaKg, closeTo(-1, 0.000001));
    });

    test('loads weekly reports newest first and skips empty weeks', () async {
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 18),
        weightKg: 81,
      );
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 19),
        weightKg: 80,
      );

      await service.saveWeightForDate(
        date: DateTime(2026, 5, 25),
        weightKg: 80,
      );
      await service.saveWeightForDate(
        date: DateTime(2026, 5, 26),
        weightKg: 79,
      );
      await service.markSkippedForDate(date: DateTime(2026, 5, 27));

      final reports = await service.loadWeeklyReports(
        anchorDate: DateTime(2026, 5, 28),
        weeksCount: 4,
      );

      expect(reports, hasLength(2));
      expect(reports.first.weekStartDate, DateTime(2026, 5, 25));
      expect(reports.first.averageWeightKg, closeTo(79.5, 0.000001));
      expect(reports.first.minWeightKg, 79);
      expect(reports.first.averageWeightDeltaKg, closeTo(-1, 0.000001));
      expect(reports.first.minWeightDeltaKg, closeTo(-1, 0.000001));

      expect(reports.last.weekStartDate, DateTime(2026, 5, 18));
      expect(reports.last.averageWeightKg, closeTo(80.5, 0.000001));
      expect(reports.last.minWeightKg, 80);
      expect(reports.last.averageWeightDeltaKg, isNull);
      expect(reports.last.minWeightDeltaKg, isNull);
    });

    test('loads skipped-only weekly report', () async {
      await service.markSkippedForDate(date: DateTime(2026, 5, 25));

      final reports = await service.loadWeeklyReports(
        anchorDate: DateTime(2026, 5, 28),
        weeksCount: 4,
      );

      expect(reports, hasLength(1));
      expect(reports.single.weekStartDate, DateTime(2026, 5, 25));
      expect(reports.single.hasWeightData, isFalse);
      expect(reports.single.skippedDaysCount, 1);
    });

    test('throws when loading non-positive number of weekly reports', () {
      expect(
        service.loadWeeklyReports(
          anchorDate: DateTime(2026, 5, 28),
          weeksCount: 0,
        ),
        throwsArgumentError,
      );
    });
  });
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
      return firstEntry.date.compareTo(secondEntry.date);
    });
  }
}
