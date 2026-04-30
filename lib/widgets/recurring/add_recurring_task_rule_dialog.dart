import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../models/milestone.dart';
import '../../models/recurring_task_rule.dart';

class AddRecurringTaskRuleDraft {
  const AddRecurringTaskRuleDraft({
    required this.title,
    required this.description,
    required this.goalId,
    required this.milestoneId,
    required this.recurrenceType,
    required this.weekdays,
    required this.monthDay,
  });

  final String title;
  final String description;
  final String? goalId;
  final String? milestoneId;
  final RecurrenceType recurrenceType;
  final List<int> weekdays;
  final int? monthDay;
}

class AddRecurringTaskRuleDialog extends StatefulWidget {
  const AddRecurringTaskRuleDialog({
    super.key,
    required this.goals,
    required this.milestones,
    this.initialRule,
    this.dialogTitle = 'Add recurring task',
    this.submitLabel = 'Add',
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final RecurringTaskRule? initialRule;
  final String dialogTitle;
  final String submitLabel;

  @override
  State<AddRecurringTaskRuleDialog> createState() =>
      _AddRecurringTaskRuleDialogState();
}

class _AddRecurringTaskRuleDialogState
    extends State<AddRecurringTaskRuleDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  RecurrenceType _recurrenceType = RecurrenceType.weekly;
  final Set<int> _selectedWeekdays = {};
  int _selectedMonthDay = 1;
  String? _selectedGoalId;
  String? _selectedMilestoneId;

  bool get _canSubmit {
    final hasTitle = _titleController.text.trim().isNotEmpty;

    if (!hasTitle) {
      return false;
    }

    return switch (_recurrenceType) {
      RecurrenceType.weekly => _selectedWeekdays.isNotEmpty,
      RecurrenceType.monthly =>
        _selectedMonthDay >= 1 && _selectedMonthDay <= 31,
    };
  }

  @override
  void initState() {
    super.initState();

    final initialRule = widget.initialRule;

    if (initialRule != null) {
      _titleController.text = initialRule.title;
      _descriptionController.text = initialRule.description;
      _recurrenceType = initialRule.recurrenceType;
      _selectedWeekdays
        ..clear()
        ..addAll(initialRule.weekdays);
      _selectedMonthDay = initialRule.monthDay ?? 1;
      _selectedGoalId = initialRule.goalId;
      _selectedMilestoneId = initialRule.milestoneId;
    }

    _titleController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final availableMilestones = widget.milestones
        .where((milestone) => milestone.goalId == _selectedGoalId)
        .toList();

    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _selectedGoalId,
              decoration: const InputDecoration(labelText: 'Goal'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No goal'),
                ),
                for (final goal in widget.goals)
                  DropdownMenuItem<String?>(
                    value: goal.id,
                    child: Text(goal.title),
                  ),
              ],
              onChanged: (goalId) {
                setState(() {
                  _selectedGoalId = goalId;
                  _selectedMilestoneId = null;
                });
              },
            ),
            if (_selectedGoalId != null) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                key: ValueKey(_selectedGoalId),
                initialValue: _selectedMilestoneId,
                decoration: const InputDecoration(labelText: 'Milestone'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Direct goal task'),
                  ),
                  for (final milestone in availableMilestones)
                    DropdownMenuItem<String?>(
                      value: milestone.id,
                      child: Text(milestone.title),
                    ),
                ],
                onChanged: (milestoneId) {
                  setState(() {
                    _selectedMilestoneId = milestoneId;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            SegmentedButton<RecurrenceType>(
              segments: const [
                ButtonSegment(
                  value: RecurrenceType.weekly,
                  label: Text('Weekly'),
                ),
                ButtonSegment(
                  value: RecurrenceType.monthly,
                  label: Text('Monthly'),
                ),
              ],
              selected: {_recurrenceType},
              onSelectionChanged: (selection) {
                setState(() {
                  _recurrenceType = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_recurrenceType == RecurrenceType.weekly)
              _WeekdaySelector(
                selectedWeekdays: _selectedWeekdays,
                onChanged: (weekday) {
                  setState(() {
                    if (_selectedWeekdays.contains(weekday)) {
                      _selectedWeekdays.remove(weekday);
                    } else {
                      _selectedWeekdays.add(weekday);
                    }
                  });
                },
              )
            else ...[
              DropdownButtonFormField<int>(
                initialValue: _selectedMonthDay,
                decoration: const InputDecoration(labelText: 'Day of month'),
                items: [
                  for (var day = 1; day <= 31; day++)
                    DropdownMenuItem(value: day, child: Text('Day $day')),
                ],
                onChanged: (day) {
                  if (day == null) {
                    return;
                  }

                  setState(() {
                    _selectedMonthDay = day;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'If a month does not have this day, the task will be created on the last day of that month.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }

  void _submit() {
    final selectedWeekdays = _selectedWeekdays.toList()..sort();

    Navigator.of(context).pop(
      AddRecurringTaskRuleDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        goalId: _selectedGoalId,
        milestoneId: _selectedMilestoneId,
        recurrenceType: _recurrenceType,
        weekdays: _recurrenceType == RecurrenceType.weekly
            ? selectedWeekdays
            : const [],
        monthDay: _recurrenceType == RecurrenceType.monthly
            ? _selectedMonthDay
            : null,
      ),
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
