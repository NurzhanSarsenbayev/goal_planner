import '../../../shared/planner_dates.dart';
import 'body_measurement_entry.dart';

class BodyWeeklyMeasurementReport {
  BodyWeeklyMeasurementReport({
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required this.entry,
    required this.neckDeltaCm,
    required this.waistDeltaCm,
    required this.hipsDeltaCm,
  }) : weekStartDate = dateOnly(weekStartDate),
       weekEndDate = dateOnly(weekEndDate);

  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final BodyMeasurementEntry? entry;
  final double? neckDeltaCm;
  final double? waistDeltaCm;
  final double? hipsDeltaCm;

  bool get hasMeasurements => entry?.hasAnyMeasurement ?? false;

  double? get neckCm => entry?.neckCm;

  double? get waistCm => entry?.waistCm;

  double? get hipsCm => entry?.hipsCm;
}
