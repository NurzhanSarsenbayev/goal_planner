import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

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
            _weekdayLabel(l10n, date),
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

String _weekdayLabel(AppLocalizations l10n, DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => l10n.habitWeekdayMon,
    DateTime.tuesday => l10n.habitWeekdayTue,
    DateTime.wednesday => l10n.habitWeekdayWed,
    DateTime.thursday => l10n.habitWeekdayThu,
    DateTime.friday => l10n.habitWeekdayFri,
    DateTime.saturday => l10n.habitWeekdaySat,
    DateTime.sunday => l10n.habitWeekdaySun,
    _ => '',
  };
}

bool _isSameDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
