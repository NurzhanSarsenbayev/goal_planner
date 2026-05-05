import 'package:flutter/material.dart';

class HabitDayLabelsRow extends StatelessWidget {
  const HabitDayLabelsRow({required this.dates, super.key});

  final List<DateTime> dates;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final date in dates) Expanded(child: _DayLabel(date: date)),
      ],
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDate(date, DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: isToday ? colorScheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            _weekdayLabel(date),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isToday ? colorScheme.onPrimaryContainer : null,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date.day.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isToday ? colorScheme.onPrimaryContainer : null,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String _weekdayLabel(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    DateTime.sunday => 'Sun',
    _ => '',
  };
}

bool _isSameDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
