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

String relativePlannerDateTitle(DateTime date) {
  final normalizedDate = dateOnly(date);
  final today = todayDate();
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  if (normalizedDate == today) {
    return 'Today';
  }

  if (normalizedDate == tomorrow) {
    return 'Tomorrow';
  }

  if (normalizedDate == yesterday) {
    return 'Yesterday';
  }

  return formatPlannerDate(normalizedDate);
}

String plannerMonthTitle(DateTime date) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${monthNames[date.month - 1]} ${date.year}';
}
