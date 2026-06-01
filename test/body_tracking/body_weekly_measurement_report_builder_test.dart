import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weekly_measurement_report_builder.dart';

void main() {
  group('BodyWeeklyMeasurementReportBuilder', () {
    const builder = BodyWeeklyMeasurementReportBuilder();

    test('builds weekly measurement report for selected week', () {
      final weekStartDate = DateTime(2026, 5, 25);
      final entry = _entry(
        date: weekStartDate,
        neckCm: 34,
        waistCm: 74,
        hipsCm: 101,
      );

      final report = builder.build(entries: [entry], weekDate: weekStartDate);

      expect(report.weekStartDate, DateTime(2026, 5, 25));
      expect(report.weekEndDate, DateTime(2026, 5, 31));
      expect(report.hasMeasurements, isTrue);
      expect(report.entry, entry);
      expect(report.neckCm, 34);
      expect(report.waistCm, 74);
      expect(report.hipsCm, 101);
    });

    test('normalizes any date inside week to monday week start', () {
      final report = builder.build(
        entries: const [],
        weekDate: DateTime(2026, 5, 27),
      );

      expect(report.weekStartDate, DateTime(2026, 5, 25));
      expect(report.weekEndDate, DateTime(2026, 5, 31));
      expect(report.hasMeasurements, isFalse);
    });

    test('ignores entries outside selected week', () {
      final weekStartDate = DateTime(2026, 5, 25);
      final entries = [
        _entry(
          id: 'before',
          date: weekStartDate.subtract(const Duration(days: 1)),
          waistCm: 90,
        ),
        _entry(id: 'current', date: weekStartDate, waistCm: 74),
        _entry(
          id: 'after',
          date: weekStartDate.add(const Duration(days: 7)),
          waistCm: 60,
        ),
      ];

      final report = builder.build(entries: entries, weekDate: weekStartDate);

      expect(report.entry?.id, 'current');
      expect(report.waistCm, 74);
    });

    test('uses latest measurement entry inside selected week', () {
      final weekStartDate = DateTime(2026, 5, 25);
      final entries = [
        _entry(
          id: 'monday',
          date: weekStartDate,
          waistCm: 75,
          updatedAt: DateTime(2026, 5, 25, 8),
        ),
        _entry(
          id: 'friday',
          date: weekStartDate.add(const Duration(days: 4)),
          waistCm: 73,
          updatedAt: DateTime(2026, 5, 29, 8),
        ),
      ];

      final report = builder.build(entries: entries, weekDate: weekStartDate);

      expect(report.entry?.id, 'friday');
      expect(report.waistCm, 73);
    });

    test(
      'uses latest updated entry when selected week has same-day entries',
      () {
        final weekStartDate = DateTime(2026, 5, 25);
        final entries = [
          _entry(
            id: 'older',
            date: weekStartDate,
            waistCm: 75,
            updatedAt: DateTime(2026, 5, 25, 8),
          ),
          _entry(
            id: 'newer',
            date: weekStartDate,
            waistCm: 74,
            updatedAt: DateTime(2026, 5, 25, 12),
          ),
        ];

        final report = builder.build(entries: entries, weekDate: weekStartDate);

        expect(report.entry?.id, 'newer');
        expect(report.waistCm, 74);
      },
    );

    test('calculates deltas against previous weekly measurement report', () {
      final previousReport = builder.build(
        entries: [
          _entry(
            date: DateTime(2026, 5, 18),
            neckCm: 35,
            waistCm: 76,
            hipsCm: 102,
          ),
        ],
        weekDate: DateTime(2026, 5, 18),
      );

      final currentReport = builder.build(
        entries: [
          _entry(
            date: DateTime(2026, 5, 25),
            neckCm: 34,
            waistCm: 74,
            hipsCm: 101,
          ),
        ],
        weekDate: DateTime(2026, 5, 25),
        previousReport: previousReport,
      );

      expect(currentReport.neckDeltaCm, -1);
      expect(currentReport.waistDeltaCm, -2);
      expect(currentReport.hipsDeltaCm, -1);
    });

    test('returns null deltas when previous value is missing', () {
      final previousReport = builder.build(
        entries: [_entry(date: DateTime(2026, 5, 18), waistCm: 76)],
        weekDate: DateTime(2026, 5, 18),
      );

      final currentReport = builder.build(
        entries: [_entry(date: DateTime(2026, 5, 25), neckCm: 34, waistCm: 74)],
        weekDate: DateTime(2026, 5, 25),
        previousReport: previousReport,
      );

      expect(currentReport.neckDeltaCm, isNull);
      expect(currentReport.waistDeltaCm, -2);
      expect(currentReport.hipsDeltaCm, isNull);
    });

    test('supports partial measurement entries', () {
      final report = builder.build(
        entries: [_entry(date: DateTime(2026, 5, 25), waistCm: 74)],
        weekDate: DateTime(2026, 5, 25),
      );

      expect(report.hasMeasurements, isTrue);
      expect(report.neckCm, isNull);
      expect(report.waistCm, 74);
      expect(report.hipsCm, isNull);
    });
  });
}

BodyMeasurementEntry _entry({
  String id = 'measurement-2026-05-25',
  required DateTime date,
  double? neckCm,
  double? waistCm,
  double? hipsCm,
  DateTime? updatedAt,
}) {
  final now = DateTime(2026, 5, 25, 8);

  return BodyMeasurementEntry(
    id: id,
    date: date,
    neckCm: neckCm,
    waistCm: waistCm,
    hipsCm: hipsCm,
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );
}
