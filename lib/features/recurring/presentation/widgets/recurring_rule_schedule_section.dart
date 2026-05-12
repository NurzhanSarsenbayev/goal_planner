import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/recurring_task_rule.dart';

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
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SegmentedButton<RecurrenceType>(
          segments: [
            ButtonSegment(
              value: RecurrenceType.weekly,
              label: Text(l10n.recurringRuleWeeklyLabel),
            ),
            ButtonSegment(
              value: RecurrenceType.monthly,
              label: Text(l10n.recurringRuleMonthlyLabel),
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
            decoration: InputDecoration(
              labelText: l10n.recurringRuleMonthDayFieldLabel,
            ),
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem(
                  value: day,
                  child: Text(l10n.recurringRuleMonthDayOption(day)),
                ),
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
                l10n.recurringRuleShortMonthFallbackNote,
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
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _WeekdayChip(
          label: l10n.recurringWeekdayMonShort,
          weekday: DateTime.monday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: l10n.recurringWeekdayTueShort,
          weekday: DateTime.tuesday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: l10n.recurringWeekdayWedShort,
          weekday: DateTime.wednesday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: l10n.recurringWeekdayThuShort,
          weekday: DateTime.thursday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: l10n.recurringWeekdayFriShort,
          weekday: DateTime.friday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: l10n.recurringWeekdaySatShort,
          weekday: DateTime.saturday,
          selectedWeekdays: selectedWeekdays,
          onChanged: onChanged,
        ),
        _WeekdayChip(
          label: l10n.recurringWeekdaySunShort,
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
