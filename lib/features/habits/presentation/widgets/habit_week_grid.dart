import 'package:flutter/material.dart';

import '../../../../shared/planner_dates.dart';
import '../../application/habit_week_view_builder.dart';
import '../../domain/habit_entry_status.dart';
import '../../domain/habit.dart';

typedef HabitCellTapCallback =
    Future<void> Function({
      required String habitId,
      required DateTime date,
      required HabitEntryStatus status,
    });

typedef HabitActionCallback = Future<void> Function(Habit habit);

class HabitWeekGrid extends StatelessWidget {
  const HabitWeekGrid({
    required this.weekView,
    required this.isLoading,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCurrentWeek,
    required this.onCellTap,
    required this.onEditHabit,
    required this.onArchiveHabit,
    required this.onDeleteHabit,
    super.key,
  });

  final HabitWeekView weekView;
  final bool isLoading;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCurrentWeek;
  final HabitCellTapCallback onCellTap;
  final HabitActionCallback onEditHabit;
  final HabitActionCallback onArchiveHabit;
  final HabitActionCallback onDeleteHabit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WeekHeader(
          weekView: weekView,
          onPreviousWeek: onPreviousWeek,
          onNextWeek: onNextWeek,
          onCurrentWeek: onCurrentWeek,
        ),
        if (isLoading) const LinearProgressIndicator(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            itemCount: weekView.rows.length + 1,
            separatorBuilder: (_, index) {
              if (index == 0) {
                return const SizedBox(height: 18);
              }

              return const SizedBox(height: 24);
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return _DayLabelsRow(dates: weekView.dates);
              }

              final row = weekView.rows[index - 1];

              return _HabitJournalCard(
                row: row,
                onCellTap: onCellTap,
                onEditHabit: onEditHabit,
                onArchiveHabit: onArchiveHabit,
                onDeleteHabit: onDeleteHabit,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.weekView,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCurrentWeek,
  });

  final HabitWeekView weekView;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekView.dates.last;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Text(
            '${formatPlannerDate(weekView.weekStart)} — '
            '${formatPlannerDate(weekEnd)}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                onPressed: onPreviousWeek,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: TextButton(
                    onPressed: onCurrentWeek,
                    child: const Text('Current week'),
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextWeek,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayLabelsRow extends StatelessWidget {
  const _DayLabelsRow({required this.dates});

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

class _HabitJournalCard extends StatelessWidget {
  const _HabitJournalCard({
    required this.row,
    required this.onCellTap,
    required this.onEditHabit,
    required this.onArchiveHabit,
    required this.onDeleteHabit,
  });

  final HabitWeekRow row;
  final HabitCellTapCallback onCellTap;
  final HabitActionCallback onEditHabit;
  final HabitActionCallback onArchiveHabit;
  final HabitActionCallback onDeleteHabit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.habit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
            _HabitActionsMenu(
              onEdit: () {
                onEditHabit(row.habit);
              },
              onArchive: () {
                onArchiveHabit(row.habit);
              },
              onDelete: () {
                onDeleteHabit(row.habit);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        _HabitSegmentsRow(row: row, onCellTap: onCellTap),
      ],
    );
  }
}

class _HabitSegmentsRow extends StatelessWidget {
  const _HabitSegmentsRow({required this.row, required this.onCellTap});

  final HabitWeekRow row;
  final HabitCellTapCallback onCellTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < row.cells.length; index += 1)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == row.cells.length - 1 ? 0 : 2,
              ),
              child: _HabitSegmentCell(
                status: row.cells[index].status,
                borderRadius: _borderRadiusForIndex(
                  index: index,
                  total: row.cells.length,
                ),
                onTap: () {
                  onCellTap(
                    habitId: row.habit.id,
                    date: row.cells[index].date,
                    status: row.cells[index].status,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  BorderRadius _borderRadiusForIndex({required int index, required int total}) {
    const radius = Radius.circular(12);

    if (total == 1) {
      return const BorderRadius.all(radius);
    }

    return BorderRadius.horizontal(
      left: index == 0 ? radius : Radius.zero,
      right: index == total - 1 ? radius : Radius.zero,
    );
  }
}

enum _HabitMenuAction { edit, archive, delete }

class _HabitActionsMenu extends StatelessWidget {
  const _HabitActionsMenu({
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_HabitMenuAction>(
      tooltip: 'Habit actions',
      onSelected: (action) {
        switch (action) {
          case _HabitMenuAction.edit:
            onEdit();
          case _HabitMenuAction.archive:
            onArchive();
          case _HabitMenuAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: _HabitMenuAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: _HabitMenuAction.archive,
            child: ListTile(
              leading: Icon(Icons.archive_outlined),
              title: Text('Archive'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: _HabitMenuAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Delete'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ];
      },
    );
  }
}

class _HabitSegmentCell extends StatelessWidget {
  const _HabitSegmentCell({
    required this.status,
    required this.borderRadius,
    required this.onTap,
  });

  final HabitEntryStatus status;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: _backgroundColor(colorScheme),
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: SizedBox(
          height: 42,
          child: Center(
            child: _icon == null
                ? null
                : Icon(_icon, size: 20, color: _foregroundColor(colorScheme)),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    return switch (status) {
      HabitEntryStatus.none => colorScheme.surfaceContainerHighest,
      HabitEntryStatus.done => colorScheme.primary,
      HabitEntryStatus.incomplete => colorScheme.secondaryContainer,
      HabitEntryStatus.failed => colorScheme.errorContainer,
      HabitEntryStatus.skipped => colorScheme.surfaceContainerHigh,
    };
  }

  Color _foregroundColor(ColorScheme colorScheme) {
    return switch (status) {
      HabitEntryStatus.done => colorScheme.onPrimary,
      HabitEntryStatus.failed => colorScheme.onErrorContainer,
      HabitEntryStatus.incomplete => colorScheme.onSecondaryContainer,
      HabitEntryStatus.skipped => colorScheme.onSurfaceVariant,
      HabitEntryStatus.none => colorScheme.onSurfaceVariant,
    };
  }

  IconData? get _icon {
    return switch (status) {
      HabitEntryStatus.none => null,
      HabitEntryStatus.done => Icons.check,
      HabitEntryStatus.incomplete => Icons.remove,
      HabitEntryStatus.failed => Icons.close,
      HabitEntryStatus.skipped => Icons.do_not_disturb_on_outlined,
    };
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
