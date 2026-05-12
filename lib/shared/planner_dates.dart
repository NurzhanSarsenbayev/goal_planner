DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime todayDate() {
  return dateOnly(DateTime.now());
}

String formatPlannerDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day.$month.$year';
}
