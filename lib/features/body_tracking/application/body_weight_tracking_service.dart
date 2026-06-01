import '../../../shared/planner_dates.dart';
import '../domain/body_weekly_weight_report.dart';
import '../domain/body_weekly_weight_report_builder.dart';
import '../domain/body_weight_entry.dart';
import 'body_weight_repository.dart';

class BodyWeightTrackingService {
  BodyWeightTrackingService({
    required BodyWeightRepository repository,
    BodyWeeklyWeightReportBuilder reportBuilder =
        const BodyWeeklyWeightReportBuilder(),
    DateTime Function()? now,
  }) : _repository = repository,
       _reportBuilder = reportBuilder,
       _now = now ?? DateTime.now;

  final BodyWeightRepository _repository;
  final BodyWeeklyWeightReportBuilder _reportBuilder;
  final DateTime Function() _now;

  Future<BodyWeightEntry?> loadEntryForDate(DateTime date) async {
    final normalizedDate = dateOnly(date);
    final entries = await _repository.loadEntriesForRange(
      startDate: normalizedDate,
      endDate: normalizedDate,
    );

    if (entries.isEmpty) {
      return null;
    }

    return entries.last;
  }

  Future<void> saveWeightForDate({
    required DateTime date,
    required double weightKg,
    String note = '',
  }) async {
    if (weightKg <= 0) {
      throw ArgumentError.value(weightKg, 'weightKg', 'must be positive.');
    }

    final normalizedDate = dateOnly(date);
    final existingEntry = await loadEntryForDate(normalizedDate);
    final now = _now();

    await _repository.saveEntry(
      BodyWeightEntry(
        id: existingEntry?.id ?? bodyWeightEntryIdForDate(normalizedDate),
        date: normalizedDate,
        weightKg: weightKg,
        isSkipped: false,
        note: note.trim(),
        createdAt: existingEntry?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Future<void> markSkippedForDate({
    required DateTime date,
    String note = '',
  }) async {
    final normalizedDate = dateOnly(date);
    final existingEntry = await loadEntryForDate(normalizedDate);
    final now = _now();

    await _repository.saveEntry(
      BodyWeightEntry(
        id: existingEntry?.id ?? bodyWeightEntryIdForDate(normalizedDate),
        date: normalizedDate,
        isSkipped: true,
        note: note.trim(),
        createdAt: existingEntry?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Future<void> clearEntryForDate(DateTime date) async {
    final existingEntry = await loadEntryForDate(date);

    if (existingEntry == null) {
      return;
    }

    await _repository.deleteEntry(existingEntry.id);
  }

  Future<BodyWeeklyWeightReport> loadWeeklyReport(DateTime weekDate) async {
    final weekStartDate = bodyTrackingWeekStart(weekDate);
    final weekEndDate = weekStartDate.add(const Duration(days: 6));
    final previousWeekStartDate = weekStartDate.subtract(
      const Duration(days: 7),
    );
    final previousWeekEndDate = previousWeekStartDate.add(
      const Duration(days: 6),
    );

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

  Future<List<BodyWeeklyWeightReport>> loadWeeklyReports({
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
    final newestWeekEndDate = newestWeekStartDate.add(const Duration(days: 6));
    final entries = await _repository.loadEntriesForRange(
      startDate: oldestPreviousWeekStartDate,
      endDate: newestWeekEndDate,
    );
    final reports = <BodyWeeklyWeightReport>[];
    BodyWeeklyWeightReport? previousReport;

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

      if (report.hasWeightData || report.skippedDaysCount > 0) {
        reports.add(report);
      }
    }

    return reports.reversed.toList(growable: false);
  }
}

String bodyWeightEntryIdForDate(DateTime date) {
  final normalizedDate = dateOnly(date);
  final year = normalizedDate.year.toString().padLeft(4, '0');
  final month = normalizedDate.month.toString().padLeft(2, '0');
  final day = normalizedDate.day.toString().padLeft(2, '0');

  return 'body-weight-$year-$month-$day';
}
