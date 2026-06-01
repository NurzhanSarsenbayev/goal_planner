import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_repository.dart';
import 'package:goal_planner/features/body_tracking/application/body_measurement_tracking_service.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/shared/planner_dates.dart';

void main() {
  group('BodyMeasurementTrackingService', () {
    late _FakeBodyMeasurementRepository repository;
    late DateTime now;
    late BodyMeasurementTrackingService service;

    setUp(() {
      repository = _FakeBodyMeasurementRepository();
      now = DateTime(2026, 5, 25, 8);
      service = BodyMeasurementTrackingService(
        repository: repository,
        now: () => now,
      );
    });

    test('saves measurements for selected week with stable week id', () async {
      await service.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 5, 27, 20),
        neckCm: 34,
        waistCm: 74,
        hipsCm: 101,
        note: ' Weekly measurements ',
      );

      final report = await service.loadWeeklyReport(DateTime(2026, 5, 28));
      final entry = report.entry;

      expect(entry, isNotNull);
      expect(entry!.id, 'body-measurement-2026-05-25');
      expect(entry.date, DateTime(2026, 5, 25));
      expect(entry.neckCm, 34);
      expect(entry.waistCm, 74);
      expect(entry.hipsCm, 101);
      expect(entry.note, 'Weekly measurements');
      expect(entry.createdAt, now);
      expect(entry.updatedAt, now);
    });

    test('updates same week without creating duplicate entry', () async {
      final createdAt = now;

      await service.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 5, 27),
        waistCm: 74,
      );

      now = DateTime(2026, 5, 27, 12);

      await service.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 5, 31),
        waistCm: 73,
        hipsCm: 100,
        note: 'Updated',
      );

      final entries = await repository.loadAllEntries();

      expect(entries, hasLength(1));
      expect(entries.single.id, 'body-measurement-2026-05-25');
      expect(entries.single.date, DateTime(2026, 5, 25));
      expect(entries.single.neckCm, isNull);
      expect(entries.single.waistCm, 73);
      expect(entries.single.hipsCm, 100);
      expect(entries.single.note, 'Updated');
      expect(entries.single.createdAt, createdAt);
      expect(entries.single.updatedAt, now);
    });

    test('throws when saving empty measurements', () {
      expect(
        service.saveMeasurementsForWeek(weekDate: DateTime(2026, 5, 25)),
        throwsArgumentError,
      );
    });

    test('throws when saving non-positive measurement', () {
      expect(
        service.saveMeasurementsForWeek(
          weekDate: DateTime(2026, 5, 25),
          waistCm: 0,
        ),
        throwsArgumentError,
      );
    });

    test('loads weekly report with previous week deltas', () async {
      await service.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 5, 18),
        neckCm: 35,
        waistCm: 76,
        hipsCm: 102,
      );

      now = DateTime(2026, 5, 25, 8);

      await service.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 5, 25),
        neckCm: 34,
        waistCm: 74,
      );

      final report = await service.loadWeeklyReport(DateTime(2026, 5, 28));

      expect(report.weekStartDate, DateTime(2026, 5, 25));
      expect(report.weekEndDate, DateTime(2026, 5, 31));
      expect(report.hasMeasurements, isTrue);
      expect(report.neckCm, 34);
      expect(report.waistCm, 74);
      expect(report.hipsCm, isNull);
      expect(report.neckDeltaCm, -1);
      expect(report.waistDeltaCm, -2);
      expect(report.hipsDeltaCm, isNull);
    });

    test('loads weekly reports newest first and skips empty weeks', () async {
      await service.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 5, 18),
        waistCm: 76,
      );

      await service.saveMeasurementsForWeek(
        weekDate: DateTime(2026, 5, 25),
        waistCm: 74,
        hipsCm: 101,
      );

      final reports = await service.loadWeeklyReports(
        anchorDate: DateTime(2026, 5, 28),
        weeksCount: 4,
      );

      expect(reports, hasLength(2));

      expect(reports.first.weekStartDate, DateTime(2026, 5, 25));
      expect(reports.first.waistCm, 74);
      expect(reports.first.hipsCm, 101);
      expect(reports.first.waistDeltaCm, -2);
      expect(reports.first.hipsDeltaCm, isNull);

      expect(reports.last.weekStartDate, DateTime(2026, 5, 18));
      expect(reports.last.waistCm, 76);
      expect(reports.last.waistDeltaCm, isNull);
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
      return firstEntry.date.compareTo(secondEntry.date);
    });
  }
}
