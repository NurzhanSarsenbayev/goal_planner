import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/planner_dates.dart';
import '../../application/habit_week_view_builder.dart';

class HabitWeekHeader extends StatelessWidget {
  const HabitWeekHeader({
    required this.weekView,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCurrentWeek,
    super.key,
  });

  final HabitWeekView weekView;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekView.dates.last;
    final l10n = AppLocalizations.of(context);

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
                    child: Text(l10n.habitCurrentWeek),
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
