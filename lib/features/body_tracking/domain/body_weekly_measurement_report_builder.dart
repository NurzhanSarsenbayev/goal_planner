import '../../../shared/planner_dates.dart';
import 'body_measurement_entry.dart';
import 'body_tracking_dates.dart';
import 'body_weekly_measurement_report.dart';

class BodyWeeklyMeasurementReportBuilder {
  const BodyWeeklyMeasurementReportBuilder();

  BodyWeeklyMeasurementReport build({
    required List<BodyMeasurementEntry> entries,
    required DateTime weekDate,
    BodyWeeklyMeasurementReport? previousReport,
  }) {
    final weekStartDate = bodyTrackingWeekStart(weekDate);
    final weekEndDate = bodyTrackingWeekEnd(weekDate);
    final entry = _entryForWeek(
      entries: entries,
      weekStartDate: weekStartDate,
      weekEndDate: weekEndDate,
    );
    final previousEntry = previousReport?.entry;

    return BodyWeeklyMeasurementReport(
      weekStartDate: weekStartDate,
      weekEndDate: weekEndDate,
      entry: entry,
      neckDeltaCm: _delta(
        current: entry?.neckCm,
        previous: previousEntry?.neckCm,
      ),
      waistDeltaCm: _delta(
        current: entry?.waistCm,
        previous: previousEntry?.waistCm,
      ),
      hipsDeltaCm: _delta(
        current: entry?.hipsCm,
        previous: previousEntry?.hipsCm,
      ),
    );
  }

  BodyMeasurementEntry? _entryForWeek({
    required List<BodyMeasurementEntry> entries,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
  }) {
    final weekEntries = entries
        .where((entry) {
          final entryDate = dateOnly(entry.date);

          return !entryDate.isBefore(weekStartDate) &&
              !entryDate.isAfter(weekEndDate);
        })
        .toList(growable: false);

    if (weekEntries.isEmpty) {
      return null;
    }

    weekEntries.sort((firstEntry, secondEntry) {
      final dateComparison = firstEntry.date.compareTo(secondEntry.date);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return firstEntry.updatedAt.compareTo(secondEntry.updatedAt);
    });

    return weekEntries.last;
  }

  double? _delta({required double? current, required double? previous}) {
    if (current == null || previous == null) {
      return null;
    }

    return current - previous;
  }
}
