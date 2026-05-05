import 'package:flutter/material.dart';

import '../../application/habit_week_view_builder.dart';
import 'habit_presentation_callbacks.dart';
import 'habit_segment_cell.dart';

class HabitJournalCard extends StatelessWidget {
  const HabitJournalCard({
    required this.row,
    required this.onCellTap,
    required this.onEditHabit,
    required this.onArchiveHabit,
    required this.onDeleteHabit,
    super.key,
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
              child: HabitSegmentCell(
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
