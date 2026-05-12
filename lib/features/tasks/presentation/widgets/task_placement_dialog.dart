import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/milestone.dart';

class TaskPlacementDialog extends StatefulWidget {
  const TaskPlacementDialog({
    super.key,
    required this.goals,
    required this.milestones,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;

  @override
  State<TaskPlacementDialog> createState() => _TaskPlacementDialogState();
}

class _TaskPlacementDialogState extends State<TaskPlacementDialog> {
  String? _selectedGoalId;
  String? _selectedMilestoneId;

  List<Milestone> get _availableMilestones {
    if (_selectedGoalId == null) {
      return [];
    }

    return widget.milestones
        .where((milestone) => milestone.goalId == _selectedGoalId)
        .toList();
  }

  void _submit() {
    if (_selectedGoalId == null) {
      return;
    }

    Navigator.of(context).pop(
      TaskPlacementDraft(
        goalId: _selectedGoalId!,
        milestoneId: _selectedMilestoneId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableMilestones = _availableMilestones;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.taskAttachToGoalTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedGoalId,
            decoration: InputDecoration(labelText: l10n.taskGoalFieldLabel),
            items: widget.goals
                .map(
                  (goal) => DropdownMenuItem<String>(
                    value: goal.id,
                    child: Text(goal.title),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGoalId = value;
                _selectedMilestoneId = null;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _selectedMilestoneId,
            decoration: InputDecoration(
              labelText: l10n.taskMilestoneFieldLabel,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.taskNoMilestoneOption),
              ),
              ...availableMilestones.map(
                (milestone) => DropdownMenuItem<String?>(
                  value: milestone.id,
                  child: Text(milestone.title),
                ),
              ),
            ],
            onChanged: _selectedGoalId == null
                ? null
                : (value) {
                    setState(() {
                      _selectedMilestoneId = value;
                    });
                  },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _selectedGoalId == null ? null : _submit,
          child: Text(l10n.taskAttachButton),
        ),
      ],
    );
  }
}

class TaskPlacementDraft {
  const TaskPlacementDraft({required this.goalId, required this.milestoneId});

  final String goalId;
  final String? milestoneId;
}
