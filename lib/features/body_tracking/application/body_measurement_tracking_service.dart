import '../domain/body_measurement_entry.dart';
import '../domain/body_tracking_dates.dart';
import '../domain/body_weekly_measurement_report.dart';
import '../domain/body_weekly_measurement_report_builder.dart';
import 'body_measurement_repository.dart';

class BodyMeasurementTrackingService {
  BodyMeasurementTrackingService({
    required BodyMeasurementRepository repository,
    BodyWeeklyMeasurementReportBuilder reportBuilder =
        const BodyWeeklyMeasurementReportBuilder(),
    DateTime Function()? now,
  }) : _repository = repository,
       _reportBuilder = reportBuilder,
       _now = now ?? DateTime.now;

  final BodyMeasurementRepository _repository;
  final BodyWeeklyMeasurementReportBuilder _reportBuilder;
  final DateTime Function() _now;

  Future<void> saveMeasurementsForWeek({
    required DateTime weekDate,
    double? neckCm,
    double? waistCm,
    double? hipsCm,
    String note = '',
  }) async {
    _validateMeasurements(neckCm: neckCm, waistCm: waistCm, hipsCm: hipsCm);

    final weekStartDate = bodyTrackingWeekStart(weekDate);
    final existingEntry = await _loadEntryForWeek(weekStartDate);
    final now = _now();

    await _repository.saveEntry(
      BodyMeasurementEntry(
        id: existingEntry?.id ?? bodyMeasurementEntryIdForWeek(weekStartDate),
        date: weekStartDate,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
        note: note.trim(),
        createdAt: existingEntry?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Future<BodyWeeklyMeasurementReport> loadWeeklyReport(
    DateTime weekDate,
  ) async {
    final weekStartDate = bodyTrackingWeekStart(weekDate);
    final weekEndDate = bodyTrackingWeekEnd(weekStartDate);
    final previousWeekStartDate = weekStartDate.subtract(
      const Duration(days: 7),
    );
    final previousWeekEndDate = bodyTrackingWeekEnd(previousWeekStartDate);

    final currentEntries = await _repository.loadEntriesForRange(
      startDate: weekStartDate,
      endDate: weekEndDate,
    );
    final previousEntries = await _repository.loadEntriesForRange(
      startDate: previousWeekStartDate,
      endDate: previousWeekEndDate,
    );
    final previousReport = _reportBuilder.build(
      entries: previousEntries,
      weekDate: previousWeekStartDate,
    );

    return _reportBuilder.build(
      entries: currentEntries,
      weekDate: weekStartDate,
      previousReport: previousReport,
    );
  }

  Future<List<BodyWeeklyMeasurementReport>> loadWeeklyReports({
    required DateTime anchorDate,
    int weeksCount = 12,
  }) async {
    if (weeksCount <= 0) {
      throw ArgumentError.value(weeksCount, 'weeksCount', 'must be positive.');
    }

    final newestWeekStartDate = bodyTrackingWeekStart(anchorDate);
    final oldestPreviousWeekStartDate = newestWeekStartDate.subtract(
      Duration(days: 7 * weeksCount),
    );
    final newestWeekEndDate = bodyTrackingWeekEnd(newestWeekStartDate);
    final entries = await _repository.loadEntriesForRange(
      startDate: oldestPreviousWeekStartDate,
      endDate: newestWeekEndDate,
    );
    final reports = <BodyWeeklyMeasurementReport>[];
    BodyWeeklyMeasurementReport? previousReport;

    for (var index = 0; index <= weeksCount; index += 1) {
      final weekStartDate = oldestPreviousWeekStartDate.add(
        Duration(days: 7 * index),
      );
      final report = _reportBuilder.build(
        entries: entries,
        weekDate: weekStartDate,
        previousReport: previousReport,
      );

      previousReport = report;

      if (index == 0) {
        continue;
      }

      if (report.hasMeasurements) {
        reports.add(report);
      }
    }

    return reports.reversed.toList(growable: false);
  }

  Future<BodyMeasurementEntry?> _loadEntryForWeek(DateTime weekDate) async {
    final weekStartDate = bodyTrackingWeekStart(weekDate);
    final entries = await _repository.loadEntriesForRange(
      startDate: weekStartDate,
      endDate: weekStartDate,
    );

    if (entries.isEmpty) {
      return null;
    }

    return entries.last;
  }

  void _validateMeasurements({
    required double? neckCm,
    required double? waistCm,
    required double? hipsCm,
  }) {
    if (neckCm == null && waistCm == null && hipsCm == null) {
      throw ArgumentError('At least one measurement must be provided.');
    }

    _validatePositiveMeasurement(neckCm, 'neckCm');
    _validatePositiveMeasurement(waistCm, 'waistCm');
    _validatePositiveMeasurement(hipsCm, 'hipsCm');
  }

  void _validatePositiveMeasurement(double? value, String fieldName) {
    if (value != null && value <= 0) {
      throw ArgumentError.value(value, fieldName, 'must be positive.');
    }
  }
}

String bodyMeasurementEntryIdForWeek(DateTime weekDate) {
  final weekStartDate = bodyTrackingWeekStart(weekDate);
  final year = weekStartDate.year.toString().padLeft(4, '0');
  final month = weekStartDate.month.toString().padLeft(2, '0');
  final day = weekStartDate.day.toString().padLeft(2, '0');

  return 'body-measurement-$year-$month-$day';
}
