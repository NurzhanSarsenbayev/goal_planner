import '../../../shared/planner_dates.dart';

class BodyWeeklyCompositionReport {
  BodyWeeklyCompositionReport({
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required this.averageWeightKg,
    required this.averageWeightDeltaKg,
    required this.estimatedBodyFatPercent,
    required this.estimatedBodyFatDeltaPercent,
  }) : weekStartDate = dateOnly(weekStartDate),
       weekEndDate = dateOnly(weekEndDate);

  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double? averageWeightKg;
  final double? averageWeightDeltaKg;
  final double? estimatedBodyFatPercent;
  final double? estimatedBodyFatDeltaPercent;

  bool get hasAverageWeight => averageWeightKg != null;

  bool get hasEstimatedBodyFat => estimatedBodyFatPercent != null;

  bool get hasAnyData => hasAverageWeight || hasEstimatedBodyFat;
}
