import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weekly_weight_report_builder.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weight_entry.dart';

void main() {
  group('BodyWeeklyWeightReportBuilder', () {
    const builder = BodyWeeklyWeightReportBuilder();

    test('divides weekly average by seven when all days have weight', () {
      final weekStartDate = DateTime(2026, 5, 25);
      final entries = [
        _entry(date: weekStartDate, weightKg: 80),
        _entry(
          date: weekStartDate.add(const Duration(days: 1)),
          weightKg: 80.55,
        ),
        _entry(
          date: weekStartDate.add(const Duration(days: 2)),
          weightKg: 80.15,
        ),
        _entry(date: weekStartDate.add(const Duration(days: 3)), weightKg: 80),
        _entry(
          date: weekStartDate.add(const Duration(days: 4)),
          weightKg: 79.8,
        ),
        _entry(
          date: weekStartDate.add(const Duration(days: 5)),
          weightKg: 79.6,
        ),
        _entry(
          date: weekStartDate.add(const Duration(days: 6)),
          weightKg: 79.8,
        ),
      ];

      final report = builder.build(entries: entries, weekDate: weekStartDate);

      expect(report.weighedDaysCount, 7);
      expect(report.skippedDaysCount, 0);
      expect(report.missingDaysCount, 0);
      expect(report.averageWeightKg, closeTo(79.9857142857, 0.000001));
      expect(report.minWeightKg, 79.6);
    });

    test('divides weekly average only by days with entered weight', () {
      final weekStartDate = DateTime(2026, 5, 25);
      final entries = [
        _entry(date: weekStartDate, weightKg: 80),
        _entry(date: weekStartDate.add(const Duration(days: 1)), weightKg: 80),
        _entry(
          date: weekStartDate.add(const Duration(days: 2)),
          isSkipped: true,
        ),
        _entry(
          date: weekStartDate.add(const Duration(days: 3)),
          weightKg: 79.8,
        ),
        _entry(
          date: weekStartDate.add(const Duration(days: 4)),
          weightKg: 79.6,
        ),
        _entry(
          date: weekStartDate.add(const Duration(days: 5)),
          weightKg: 79.8,
        ),
        _entry(date: weekStartDate.add(const Duration(days: 6)), weightKg: 79),
      ];

      final report = builder.build(entries: entries, weekDate: weekStartDate);

      expect(report.weighedDaysCount, 6);
      expect(report.skippedDaysCount, 1);
      expect(report.missingDaysCount, 0);
      expect(report.averageWeightKg, closeTo(79.7, 0.000001));
      expect(report.minWeightKg, 79);
    });

    test('does not count days without entries as weight days', () {
      final weekStartDate = DateTime(2026, 5, 25);
      final entries = [
        _entry(date: weekStartDate, weightKg: 80),
        _entry(
          date: weekStartDate.add(const Duration(days: 1)),
          weightKg: 79.5,
        ),
      ];

      final report = builder.build(entries: entries, weekDate: weekStartDate);

      expect(report.weighedDaysCount, 2);
      expect(report.skippedDaysCount, 0);
      expect(report.missingDaysCount, 5);
      expect(report.averageWeightKg, closeTo(79.75, 0.000001));
      expect(report.minWeightKg, 79.5);
    });

    test('returns empty values when week has no entered weights', () {
      final weekStartDate = DateTime(2026, 5, 25);
      final entries = [
        _entry(date: weekStartDate, isSkipped: true),
        _entry(
          date: weekStartDate.add(const Duration(days: 1)),
          isSkipped: true,
        ),
      ];

      final report = builder.build(entries: entries, weekDate: weekStartDate);

      expect(report.hasWeightData, false);
      expect(report.weighedDaysCount, 0);
      expect(report.skippedDaysCount, 2);
      expect(report.missingDaysCount, 5);
      expect(report.averageWeightKg, isNull);
      expect(report.minWeightKg, isNull);
    });

    test('ignores entries outside selected week', () {
      final weekStartDate = DateTime(2026, 5, 25);
      final entries = [
        _entry(
          date: weekStartDate.subtract(const Duration(days: 1)),
          weightKg: 100,
        ),
        _entry(date: weekStartDate, weightKg: 80),
        _entry(date: weekStartDate.add(const Duration(days: 7)), weightKg: 60),
      ];

      final report = builder.build(entries: entries, weekDate: weekStartDate);

      expect(report.weighedDaysCount, 1);
      expect(report.averageWeightKg, 80);
      expect(report.minWeightKg, 80);
    });

    test('normalizes any date inside week to monday week start', () {
      final report = builder.build(
        entries: const [],
        weekDate: DateTime(2026, 5, 27),
      );

      expect(report.weekStartDate, DateTime(2026, 5, 25));
      expect(report.weekEndDate, DateTime(2026, 5, 31));
    });

    test('calculates deltas against previous weekly report', () {
      final previousReport = builder.build(
        entries: [
          _entry(date: DateTime(2026, 5, 18), weightKg: 81),
          _entry(date: DateTime(2026, 5, 19), weightKg: 80),
        ],
        weekDate: DateTime(2026, 5, 18),
      );

      final currentReport = builder.build(
        entries: [
          _entry(date: DateTime(2026, 5, 25), weightKg: 80),
          _entry(date: DateTime(2026, 5, 26), weightKg: 79),
        ],
        weekDate: DateTime(2026, 5, 25),
        previousReport: previousReport,
      );

      expect(currentReport.averageWeightDeltaKg, closeTo(-1, 0.000001));
      expect(currentReport.minWeightDeltaKg, closeTo(-1, 0.000001));
    });
  });
}

BodyWeightEntry _entry({
  required DateTime date,
  double? weightKg,
  bool isSkipped = false,
}) {
  return BodyWeightEntry(
    id: 'weight-${date.toIso8601String()}',
    date: date,
    weightKg: weightKg,
    isSkipped: isSkipped,
    createdAt: date,
    updatedAt: date,
  );
}
