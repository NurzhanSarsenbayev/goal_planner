import 'package:flutter/material.dart';

import '../../models/recurring_task_rule.dart';

class RecurringRuleScheduleSection extends StatelessWidget {
  const RecurringRuleScheduleSection({
    super.key,
    required this.recurrenceType,
    required this.selectedWeekdays,
    required this.selectedMonthDay,
    required this.onRecurrenceTypeChanged,
    required this.onWeekdayToggled,
    required this.onMonthDayChanged,
  });

  final RecurrenceType recurrenceType;
  final Set<int> selectedWeekdays;
  final int selectedMonthDay;
  final ValueChanged<RecurrenceType> onRecurrenceTypeChanged;
  final ValueChanged<int> onWeekdayToggled;
  final ValueChanged<int> onMonthDayChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedButton<RecurrenceType>(
          segments: const [
            ButtonSegment(value: RecurrenceType.weekly, label: Text('Weekly')),
            ButtonSegment(
              value: RecurrenceType.monthly,
              label: Text('Monthly'),
            ),
          ],
          selected: {recurrenceType},
          onSelectionChanged: (selection) {
            onRecurrenceTypeChanged(selection.first);
          },
        ),
        const SizedBox(height: 16),
        if (recurrenceType == RecurrenceType.weekly)
          _WeekdaySelector(
            selectedWeekdays: selectedWeekdays,
            onChanged: onWeekdayToggled,
          )
        else ...[
          DropdownButtonFormField<int>(
            initialValue: selectedMonthDay,
            decoration: const InputDecoration(labelText: 'Day of month'),
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem(value: day, child: Text('Day $day')),
            ],
            onChanged: (day) {
              if (day == null) {
                return;
              }

              onMonthDayChanged(day);
            },
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              return Text(
                'If a month does not have this day, the task will be created on the last day of that month.',
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
        ],
      ],
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({
    required this.selectedWeekdays,
    required this.onChanged,
  });

  final Set<int> selectedWeekdays;
  final void Function(int weekday) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _WeekdayChip(
          label: 'Mon',
          weekday: DateTime.monday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: 'Tue',
          weekday: DateTime.tuesday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: 'Wed',
          weekday: DateTime.wednesday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: 'Thu',
          weekday: DateTime.thursday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: 'Fri',
          weekday: DateTime.friday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: 'Sat',
          weekday: DateTime.saturday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: 'Sun',
          weekday: DateTime.sunday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.label,
    required this.weekday,
    required this.selectedWeekdays,
    required this.onChanged,
  });

  final String label;
  final int weekday;
  final Set<int> selectedWeekdays;
  final void Function(int weekday) onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selectedWeekdays.contains(weekday),
      onSelected: (_) {
        onChanged(weekday);
      },
    );
  }
}
