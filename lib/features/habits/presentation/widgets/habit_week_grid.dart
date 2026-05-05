import 'package:flutter/material.dart';

import '../../application/habit_week_view_builder.dart';
import 'habit_day_labels_row.dart';
import 'habit_journal_card.dart';
import 'habit_presentation_callbacks.dart';
import 'habit_week_header.dart';

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
        HabitWeekHeader(
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
                return HabitDayLabelsRow(dates: weekView.dates);
              }

              final row = weekView.rows[index - 1];

              return HabitJournalCard(
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
