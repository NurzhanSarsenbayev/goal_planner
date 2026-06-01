import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/domain/body_measurement_entry.dart';
import 'package:goal_planner/features/body_tracking/domain/body_profile.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weekly_composition_report_builder.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weekly_measurement_report.dart';
import 'package:goal_planner/features/body_tracking/domain/body_weekly_weight_report.dart';

void main() {
  group('BodyWeeklyCompositionReportBuilder', () {
    const builder = BodyWeeklyCompositionReportBuilder();

    test('builds weekly composition reports from weight and measurements', () {
      final reports = builder.build(
        profile: _profile(),
        weightReports: [
          _weightReport(
            weekStartDate: DateTime(2026, 6, 1),
            averageWeightKg: 60,
            averageWeightDeltaKg: -1,
          ),
          _weightReport(
            weekStartDate: DateTime(2026, 5, 25),
            averageWeightKg: 61,
          ),
        ],
        measurementReports: [
          _measurementReport(
            weekStartDate: DateTime(2026, 6, 1),
            neckCm: 34,
            waistCm: 74,
            hipsCm: 101,
          ),
          _measurementReport(
            weekStartDate: DateTime(2026, 5, 25),
            neckCm: 35,
            waistCm: 76,
            hipsCm: 102,
          ),
        ],
      );

      expect(reports, hasLength(2));

      expect(reports.first.weekStartDate, DateTime(2026, 6, 1));
      expect(reports.first.averageWeightKg, 60);
      expect(reports.first.averageWeightDeltaKg, -1);
      expect(reports.first.estimatedBodyFatPercent, closeTo(28.14, 0.01));
      expect(reports.first.estimatedBodyFatDeltaPercent, closeTo(-0.99, 0.01));

      expect(reports.last.weekStartDate, DateTime(2026, 5, 25));
      expect(reports.last.averageWeightKg, 61);
      expect(reports.last.estimatedBodyFatPercent, closeTo(29.13, 0.01));
      expect(reports.last.estimatedBodyFatDeltaPercent, isNull);
    });

    test('keeps average weight when body profile is missing', () {
      final reports = builder.build(
        profile: null,
        weightReports: [
          _weightReport(
            weekStartDate: DateTime(2026, 6, 1),
            averageWeightKg: 60,
          ),
        ],
        measurementReports: [
          _measurementReport(
            weekStartDate: DateTime(2026, 6, 1),
            neckCm: 34,
            waistCm: 74,
            hipsCm: 101,
          ),
        ],
      );

      expect(reports, hasLength(1));
      expect(reports.first.averageWeightKg, 60);
      expect(reports.first.estimatedBodyFatPercent, isNull);
      expect(reports.first.hasAnyData, isTrue);
    });

    test('keeps estimated body fat when weekly weight is missing', () {
      final reports = builder.build(
        profile: _profile(),
        weightReports: const [],
        measurementReports: [
          _measurementReport(
            weekStartDate: DateTime(2026, 6, 1),
            neckCm: 34,
            waistCm: 74,
            hipsCm: 101,
          ),
        ],
      );

      expect(reports, hasLength(1));
      expect(reports.first.averageWeightKg, isNull);
      expect(reports.first.estimatedBodyFatPercent, closeTo(28.14, 0.01));
      expect(reports.first.hasAnyData, isTrue);
    });

    test('returns empty reports when there is no useful data', () {
      final reports = builder.build(
        profile: null,
        weightReports: const [],
        measurementReports: const [],
      );

      expect(reports, isEmpty);
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

BodyWeeklyWeightReport _weightReport({
  required DateTime weekStartDate,
  required double? averageWeightKg,
  double? averageWeightDeltaKg,
}) {
  return BodyWeeklyWeightReport(
    weekStartDate: weekStartDate,
    weekEndDate: weekStartDate.add(const Duration(days: 6)),
    weighedDaysCount: averageWeightKg == null ? 0 : 7,
    skippedDaysCount: 0,
    averageWeightKg: averageWeightKg,
    minWeightKg: averageWeightKg,
    averageWeightDeltaKg: averageWeightDeltaKg,
    minWeightDeltaKg: averageWeightDeltaKg,
  );
}

BodyWeeklyMeasurementReport _measurementReport({
  required DateTime weekStartDate,
  required double? neckCm,
  required double? waistCm,
  required double? hipsCm,
}) {
  final now = DateTime(2026, 6, 1, 8);

  return BodyWeeklyMeasurementReport(
    weekStartDate: weekStartDate,
    weekEndDate: weekStartDate.add(const Duration(days: 6)),
    entry: BodyMeasurementEntry(
      id: 'measurement-${weekStartDate.toIso8601String()}',
      date: weekStartDate,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
      createdAt: now,
      updatedAt: now,
    ),
    neckDeltaCm: null,
    waistDeltaCm: null,
    hipsDeltaCm: null,
  );
}
