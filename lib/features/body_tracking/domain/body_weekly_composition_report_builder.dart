import 'body_metrics_calculator.dart';
import 'body_profile.dart';
import 'body_tracking_dates.dart';
import 'body_weekly_composition_report.dart';
import 'body_weekly_measurement_report.dart';
import 'body_weekly_weight_report.dart';

class BodyWeeklyCompositionReportBuilder {
  const BodyWeeklyCompositionReportBuilder({
    BodyMetricsCalculator metricsCalculator = const BodyMetricsCalculator(),
  }) : _metricsCalculator = metricsCalculator;

  final BodyMetricsCalculator _metricsCalculator;

  List<BodyWeeklyCompositionReport> build({
    required BodyProfile? profile,
    required List<BodyWeeklyWeightReport> weightReports,
    required List<BodyWeeklyMeasurementReport> measurementReports,
  }) {
    final weightReportsByWeek = <DateTime, BodyWeeklyWeightReport>{
      for (final report in weightReports)
        bodyTrackingWeekStart(report.weekStartDate): report,
    };
    final measurementReportsByWeek = <DateTime, BodyWeeklyMeasurementReport>{
      for (final report in measurementReports)
        bodyTrackingWeekStart(report.weekStartDate): report,
    };
    final weekStartDates = <DateTime>{
      ...weightReportsByWeek.keys,
      ...measurementReportsByWeek.keys,
    }.toList(growable: false)..sort();

    final reports = <BodyWeeklyCompositionReport>[];
    BodyWeeklyCompositionReport? previousReport;

    for (final weekStartDate in weekStartDates) {
      final weightReport = weightReportsByWeek[weekStartDate];
      final measurementReport = measurementReportsByWeek[weekStartDate];
      final estimatedBodyFatPercent = _estimatedBodyFatPercent(
        profile: profile,
        weightReport: weightReport,
        measurementReport: measurementReport,
      );
      final report = BodyWeeklyCompositionReport(
        weekStartDate: weekStartDate,
        weekEndDate: bodyTrackingWeekEnd(weekStartDate),
        averageWeightKg: weightReport?.averageWeightKg,
        averageWeightDeltaKg: weightReport?.averageWeightDeltaKg,
        estimatedBodyFatPercent: estimatedBodyFatPercent,
        estimatedBodyFatDeltaPercent: _delta(
          current: estimatedBodyFatPercent,
          previous: previousReport?.estimatedBodyFatPercent,
        ),
      );

      if (!report.hasAnyData) {
        continue;
      }

      reports.add(report);
      previousReport = report;
    }

    return reports.reversed.toList(growable: false);
  }

  double? _estimatedBodyFatPercent({
    required BodyProfile? profile,
    required BodyWeeklyWeightReport? weightReport,
    required BodyWeeklyMeasurementReport? measurementReport,
  }) {
    if (profile == null) {
      return null;
    }

    return _metricsCalculator
        .calculate(
          profile: profile,
          weightKg: weightReport?.averageWeightKg,
          neckCm: measurementReport?.neckCm,
          waistCm: measurementReport?.waistCm,
          hipsCm: measurementReport?.hipsCm,
        )
        .estimatedBodyFatPercent;
  }

  double? _delta({required double? current, required double? previous}) {
    if (current == null || previous == null) {
      return null;
    }

    return current - previous;
  }
}
