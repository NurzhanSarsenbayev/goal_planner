import '../../../shared/planner_dates.dart';
import 'body_weight_entry.dart';
import 'body_weekly_weight_report.dart';

class BodyWeeklyWeightReportBuilder {
  const BodyWeeklyWeightReportBuilder();

  BodyWeeklyWeightReport build({
    required List<BodyWeightEntry> entries,
    required DateTime weekDate,
    BodyWeeklyWeightReport? previousReport,
  }) {
    final weekStartDate = bodyTrackingWeekStart(weekDate);
    final weekEndDate = weekStartDate.add(const Duration(days: 6));
    final weekEntries = _entriesForWeek(
      entries: entries,
      weekStartDate: weekStartDate,
      weekEndDate: weekEndDate,
    );
    final weights = weekEntries
        .where((entry) => entry.weightKg != null)
        .map((entry) => entry.weightKg!)
        .toList(growable: false);

    final averageWeightKg = _average(weights);
    final minWeightKg = _min(weights);

    return BodyWeeklyWeightReport(
      weekStartDate: weekStartDate,
      weekEndDate: weekEndDate,
      weighedDaysCount: weights.length,
      skippedDaysCount: weekEntries.where((entry) => entry.isSkipped).length,
      averageWeightKg: averageWeightKg,
      minWeightKg: minWeightKg,
      averageWeightDeltaKg: _delta(
        current: averageWeightKg,
        previous: previousReport?.averageWeightKg,
      ),
      minWeightDeltaKg: _delta(
        current: minWeightKg,
        previous: previousReport?.minWeightKg,
      ),
    );
  }

  List<BodyWeightEntry> _entriesForWeek({
    required List<BodyWeightEntry> entries,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
  }) {
    final entriesByDate = <DateTime, BodyWeightEntry>{};

    for (final entry in entries) {
      final entryDate = dateOnly(entry.date);

      if (entryDate.isBefore(weekStartDate) || entryDate.isAfter(weekEndDate)) {
        continue;
      }

      entriesByDate[entryDate] = entry;
    }

    return entriesByDate.values.toList(growable: false);
  }

  double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }

    final sum = values.fold<double>(0, (total, value) => total + value);

    return sum / values.length;
  }

  double? _min(List<double> values) {
    if (values.isEmpty) {
      return null;
    }

    var minValue = values.first;

    for (final value in values.skip(1)) {
      if (value < minValue) {
        minValue = value;
      }
    }

    return minValue;
  }

  double? _delta({required double? current, required double? previous}) {
    if (current == null || previous == null) {
      return null;
    }

    return current - previous;
  }
}

DateTime bodyTrackingWeekStart(DateTime date) {
  final normalizedDate = dateOnly(date);

  return normalizedDate.subtract(
    Duration(days: normalizedDate.weekday - DateTime.monday),
  );
}
