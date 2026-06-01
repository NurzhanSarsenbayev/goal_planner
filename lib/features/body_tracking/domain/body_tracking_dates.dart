import '../../../shared/planner_dates.dart';

DateTime bodyTrackingWeekStart(DateTime date) {
  final normalizedDate = dateOnly(date);

  return normalizedDate.subtract(
    Duration(days: normalizedDate.weekday - DateTime.monday),
  );
}

DateTime bodyTrackingWeekEnd(DateTime date) {
  return bodyTrackingWeekStart(date).add(const Duration(days: 6));
}
