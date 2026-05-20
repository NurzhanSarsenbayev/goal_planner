const minPlannerTimeMinutes = 0;
const maxPlannerTimeMinutes = 24 * 60 - 1;

bool isValidPlannerTimeMinutes(int minutes) {
  return minutes >= minPlannerTimeMinutes && minutes <= maxPlannerTimeMinutes;
}

int plannerTimeMinutes({required int hour, required int minute}) {
  assert(hour >= 0 && hour <= 23, 'hour must be between 0 and 23.');
  assert(minute >= 0 && minute <= 59, 'minute must be between 0 and 59.');

  return hour * 60 + minute;
}

String formatPlannerTime(int minutes) {
  assert(
    isValidPlannerTimeMinutes(minutes),
    'minutes must be between 0 and 1439.',
  );

  final hour = minutes ~/ 60;
  final minute = minutes % 60;

  final hourText = hour.toString().padLeft(2, '0');
  final minuteText = minute.toString().padLeft(2, '0');

  return '$hourText:$minuteText';
}
