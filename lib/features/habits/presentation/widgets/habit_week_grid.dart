import 'package:flutter/material.dart';

import '../../../../shared/planner_dates.dart';
import '../../application/habit_week_view_builder.dart';
import '../../domain/habit_entry_status.dart';

typedef HabitCellToggleCallback =
    Future<void> Function({
      required String habitId,
      required DateTime date,
      required HabitEntryStatus status,
    });

class HabitWeekGrid extends StatelessWidget {
  const HabitWeekGrid({
    required this.weekView,
    required this.isLoading,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCurrentWeek,
    required this.onToggleCell,
    super.key,
  });

  final HabitWeekView weekView;
  final bool isLoading;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCurrentWeek;
  final HabitCellToggleCallback onToggleCell;

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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _HabitWeekTable(
                  weekView: weekView,
                  onToggleCell: onToggleCell,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitWeekTable extends StatelessWidget {
  const _HabitWeekTable({required this.weekView, required this.onToggleCell});

  final HabitWeekView weekView;
  final HabitCellToggleCallback onToggleCell;

  static const double _habitColumnWidth = 172;
  static const double _dayColumnWidth = 44;

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
            onToggleCell: onToggleCell,
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
            child: _DayHeader(date: date),
          ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDate(date, DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isToday ? colorScheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            _weekdayLabel(date),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isToday ? colorScheme.onPrimaryContainer : null,
              fontWeight: isToday ? FontWeight.w700 : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date.day.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isToday ? colorScheme.onPrimaryContainer : null,
              fontWeight: isToday ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );
  }

  static String _weekdayLabel(DateTime date) {
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

  static bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.row,
    required this.habitColumnWidth,
    required this.dayColumnWidth,
    required this.onToggleCell,
  });

  final HabitWeekRow row;
  final double habitColumnWidth;
  final double dayColumnWidth;
  final HabitCellToggleCallback onToggleCell;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: habitColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.habit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (row.habit.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    row.habit.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          for (final cell in row.cells)
            SizedBox(
              width: dayColumnWidth,
              child: Center(
                child: _HabitCellButton(
                  status: cell.status,
                  onTap: () {
                    onToggleCell(
                      habitId: row.habit.id,
                      date: cell.date,
                      status: cell.status,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HabitCellButton extends StatelessWidget {
  const _HabitCellButton({required this.status, required this.onTap});

  final HabitEntryStatus status;
  final VoidCallback onTap;

  bool get _isDone => status == HabitEntryStatus.done;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: _isDone ? colorScheme.primary : colorScheme.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            _icon,
            size: 20,
            color: _isDone
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (status) {
      HabitEntryStatus.none => Icons.add,
      HabitEntryStatus.done => Icons.check,
      HabitEntryStatus.incomplete => Icons.remove,
      HabitEntryStatus.failed => Icons.close,
      HabitEntryStatus.skipped => Icons.do_not_disturb_on_outlined,
    };
  }
}
