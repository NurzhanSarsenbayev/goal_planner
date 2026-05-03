import 'package:flutter/material.dart';

import '../../../../models/goal.dart';
import '../../../../models/milestone.dart';
import '../../../../models/recurring_task_rule.dart';
import 'recurring_rule_placement_section.dart';
import 'recurring_rule_schedule_section.dart';

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
    this.initialDate,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final RecurringTaskRule? initialRule;
  final DateTime? initialDate;
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
    } else if (widget.initialDate != null) {
      final initialDate = widget.initialDate!;

      _selectedWeekdays
        ..clear()
        ..add(initialDate.weekday);

      _selectedMonthDay = initialDate.day;
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
            RecurringRulePlacementSection(
              goals: widget.goals,
              milestones: widget.milestones,
              selectedGoalId: _selectedGoalId,
              selectedMilestoneId: _selectedMilestoneId,
              onGoalChanged: (goalId) {
                setState(() {
                  _selectedGoalId = goalId;
                  _selectedMilestoneId = null;
                });
              },
              onMilestoneChanged: (milestoneId) {
                setState(() {
                  _selectedMilestoneId = milestoneId;
                });
              },
            ),
            const SizedBox(height: 16),
            RecurringRuleScheduleSection(
              recurrenceType: _recurrenceType,
              selectedWeekdays: _selectedWeekdays,
              selectedMonthDay: _selectedMonthDay,
              onRecurrenceTypeChanged: (recurrenceType) {
                setState(() {
                  _recurrenceType = recurrenceType;
                });
              },
              onWeekdayToggled: (weekday) {
                setState(() {
                  if (_selectedWeekdays.contains(weekday)) {
                    _selectedWeekdays.remove(weekday);
                  } else {
                    _selectedWeekdays.add(weekday);
                  }
                });
              },
              onMonthDayChanged: (monthDay) {
                setState(() {
                  _selectedMonthDay = monthDay;
                });
              },
            ),
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
