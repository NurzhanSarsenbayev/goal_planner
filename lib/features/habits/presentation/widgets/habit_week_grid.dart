import 'package:flutter/material.dart';

import '../../../../shared/planner_dates.dart';
import '../../application/habit_week_view_builder.dart';
import '../../domain/habit_entry_status.dart';

class HabitWeekGrid extends StatelessWidget {
  const HabitWeekGrid({
    required this.weekView,
    required this.isLoading,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCurrentWeek,
    super.key,
  });

  final HabitWeekView weekView;
  final bool isLoading;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekView.dates.last;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onPreviousWeek,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${formatPlannerDate(weekView.weekStart)} — ${formatPlannerDate(weekEnd)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: onCurrentWeek,
                      child: const Text('Current week'),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNextWeek,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        if (isLoading) const LinearProgressIndicator(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _HabitWeekTable(weekView: weekView),
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitWeekTable extends StatelessWidget {
  const _HabitWeekTable({required this.weekView});

  final HabitWeekView weekView;

  static const double _habitColumnWidth = 160;
  static const double _dayColumnWidth = 48;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderRow(
          dates: weekView.dates,
          habitColumnWidth: _habitColumnWidth,
          dayColumnWidth: _dayColumnWidth,
        ),
        const SizedBox(height: 8),
        for (final row in weekView.rows) ...[
          _HabitRow(
            row: row,
            habitColumnWidth: _habitColumnWidth,
            dayColumnWidth: _dayColumnWidth,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.dates,
    required this.habitColumnWidth,
    required this.dayColumnWidth,
  });

  final List<DateTime> dates;
  final double habitColumnWidth;
  final double dayColumnWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: habitColumnWidth),
        for (final date in dates)
          SizedBox(
            width: dayColumnWidth,
            child: Column(
              children: [
                Text(
                  _weekdayLabel(date),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  date.day.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
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
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.row,
    required this.habitColumnWidth,
    required this.dayColumnWidth,
  });

  final HabitWeekRow row;
  final double habitColumnWidth;
  final double dayColumnWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: habitColumnWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.habit.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (row.habit.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      row.habit.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            for (final cell in row.cells)
              SizedBox(
                width: dayColumnWidth,
                child: Center(child: _HabitStatusIcon(status: cell.status)),
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitStatusIcon extends StatelessWidget {
  const _HabitStatusIcon({required this.status});

  final HabitEntryStatus status;

  @override
  Widget build(BuildContext context) {
    return Icon(
      _icon,
      size: 22,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  IconData get _icon {
    return switch (status) {
      HabitEntryStatus.none => Icons.radio_button_unchecked,
      HabitEntryStatus.done => Icons.check_circle,
      HabitEntryStatus.incomplete => Icons.remove_circle_outline,
      HabitEntryStatus.failed => Icons.cancel_outlined,
      HabitEntryStatus.skipped => Icons.do_not_disturb_on_outlined,
    };
  }
}
