import 'package:flutter/material.dart';

import '../../../../shared/planner_time.dart';
import '../../../../l10n/app_localizations.dart';
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
    required this.scheduledTimeMinutes,
    required this.reminderMinutesBefore,
  });

  final String title;
  final String description;
  final String? goalId;
  final String? milestoneId;
  final RecurrenceType recurrenceType;
  final List<int> weekdays;
  final int? monthDay;
  final int? scheduledTimeMinutes;
  final int? reminderMinutesBefore;
}

class AddRecurringTaskRuleDialog extends StatefulWidget {
  const AddRecurringTaskRuleDialog({
    super.key,
    required this.goals,
    required this.milestones,
    this.initialRule,
    this.dialogTitle,
    this.submitLabel,
    this.initialDate,
    this.initialGoalId,
    this.initialMilestoneId,
  }) : assert(
         initialMilestoneId == null || initialGoalId != null,
         'initialGoalId is required when initialMilestoneId is set.',
       );

  final List<Goal> goals;
  final List<Milestone> milestones;
  final RecurringTaskRule? initialRule;
  final DateTime? initialDate;
  final String? initialGoalId;
  final String? initialMilestoneId;
  final String? dialogTitle;
  final String? submitLabel;

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
  int? _scheduledTimeMinutes;
  int? _reminderMinutesBefore;
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

  TimeOfDay get _initialTime {
    final scheduledTimeMinutes = _scheduledTimeMinutes;

    if (scheduledTimeMinutes == null) {
      return TimeOfDay.now();
    }

    return TimeOfDay(
      hour: scheduledTimeMinutes ~/ 60,
      minute: scheduledTimeMinutes % 60,
    );
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
      _scheduledTimeMinutes = initialRule.scheduledTimeMinutes;
      _reminderMinutesBefore = initialRule.reminderMinutesBefore;
      _selectedGoalId = initialRule.goalId;
      _selectedMilestoneId = initialRule.milestoneId;
    } else {
      _selectedGoalId = widget.initialGoalId;
      _selectedMilestoneId = widget.initialMilestoneId;

      if (widget.initialDate != null) {
        final initialDate = widget.initialDate!;

        _selectedWeekdays
          ..clear()
          ..add(initialDate.weekday);

        _selectedMonthDay = initialDate.day;
      }
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

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _initialTime,
    );

    if (!mounted || pickedTime == null) {
      return;
    }

    setState(() {
      _scheduledTimeMinutes = plannerTimeMinutes(
        hour: pickedTime.hour,
        minute: pickedTime.minute,
      );
    });
  }

  void _clearTime() {
    setState(() {
      _scheduledTimeMinutes = null;
      _reminderMinutesBefore = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.dialogTitle ?? l10n.recurringRuleDialogAddTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.recurringRuleTitleFieldLabel,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.recurringRuleDescriptionFieldLabel,
              ),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      _scheduledTimeMinutes == null
                          ? l10n.taskTimeNotSetButton
                          : l10n.taskTimeSelectedButton(
                              formatPlannerTime(_scheduledTimeMinutes!),
                            ),
                    ),
                  ),
                ),
                if (_scheduledTimeMinutes != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _clearTime,
                    child: Text(l10n.taskTimeClearButton),
                  ),
                ],
              ],
            ),
            if (_scheduledTimeMinutes != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _reminderMinutesBefore,
                decoration: InputDecoration(
                  labelText: l10n.taskReminderFieldLabel,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.taskReminderNoneOption),
                  ),
                  DropdownMenuItem<int?>(
                    value: 0,
                    child: Text(l10n.taskReminderAtTimeOption),
                  ),
                  DropdownMenuItem<int?>(
                    value: 5,
                    child: Text(l10n.taskReminderMinutesBeforeOption(5)),
                  ),
                  DropdownMenuItem<int?>(
                    value: 15,
                    child: Text(l10n.taskReminderMinutesBeforeOption(15)),
                  ),
                  DropdownMenuItem<int?>(
                    value: 30,
                    child: Text(l10n.taskReminderMinutesBeforeOption(30)),
                  ),
                  DropdownMenuItem<int?>(
                    value: 60,
                    child: Text(l10n.taskReminderHoursBeforeOption(1)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _reminderMinutesBefore = value;
                  });
                },
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
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(widget.submitLabel ?? l10n.commonAdd),
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
        scheduledTimeMinutes: _scheduledTimeMinutes,
        reminderMinutesBefore: _reminderMinutesBefore,
      ),
    );
  }
}
