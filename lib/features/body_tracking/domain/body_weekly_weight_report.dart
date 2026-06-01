import '../../../shared/planner_dates.dart';

class BodyWeeklyWeightReport {
  BodyWeeklyWeightReport({
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required this.weighedDaysCount,
    required this.skippedDaysCount,
    required this.averageWeightKg,
    required this.minWeightKg,
    required this.averageWeightDeltaKg,
    required this.minWeightDeltaKg,
  }) : weekStartDate = dateOnly(weekStartDate),
       weekEndDate = dateOnly(weekEndDate);

  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final int weighedDaysCount;
  final int skippedDaysCount;
  final double? averageWeightKg;
  final double? minWeightKg;
  final double? averageWeightDeltaKg;
  final double? minWeightDeltaKg;

  static const totalDaysCount = 7;

  bool get hasWeightData => averageWeightKg != null;

  int get missingDaysCount {
    final missingDays = totalDaysCount - weighedDaysCount - skippedDaysCount;

    return missingDays < 0 ? 0 : missingDays;
  }
}
