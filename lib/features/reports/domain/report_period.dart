import '../../../shared/planner_dates.dart';

enum ReportPeriod { today, last7Days, last14Days }

extension ReportPeriodDetails on ReportPeriod {
  DateTime startDate(DateTime today) {
    final normalizedToday = dateOnly(today);

    return switch (this) {
      ReportPeriod.today => normalizedToday,
      ReportPeriod.last7Days => normalizedToday.subtract(
        const Duration(days: 6),
      ),
      ReportPeriod.last14Days => normalizedToday.subtract(
        const Duration(days: 13),
      ),
    };
  }

  int get daysCount {
    return switch (this) {
      ReportPeriod.today => 1,
      ReportPeriod.last7Days => 7,
      ReportPeriod.last14Days => 14,
    };
  }
}
