import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/milestone.dart';

class AddTaskWithPlacementDialog extends StatefulWidget {
  const AddTaskWithPlacementDialog({
    super.key,
    required this.goals,
    required this.milestones,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;

  @override
  State<AddTaskWithPlacementDialog> createState() =>
      _AddTaskWithPlacementDialogState();
}

class _AddTaskWithPlacementDialogState
    extends State<AddTaskWithPlacementDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      AddTaskWithPlacementDraft(
        title: title,
        description: description,
        goalId: _selectedGoalId,
        milestoneId: _selectedMilestoneId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableMilestones = _availableMilestones;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.taskDialogAddForTodayTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.taskTitleFieldLabel,
                hintText: l10n.taskTitleFieldHint,
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.taskDescriptionFieldLabel,
                hintText: l10n.taskDescriptionFieldHint,
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _selectedGoalId,
              decoration: InputDecoration(labelText: l10n.taskGoalFieldLabel),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.taskNoGoalOption),
                ),
                ...widget.goals.map(
                  (goal) => DropdownMenuItem<String?>(
                    value: goal.id,
                    child: Text(goal.title),
                  ),
                ),
              ],
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonAdd)),
      ],
    );
  }
}

class AddTaskWithPlacementDraft {
  const AddTaskWithPlacementDraft({
    required this.title,
    required this.description,
    required this.goalId,
    required this.milestoneId,
  });

  final String title;
  final String description;
  final String? goalId;
  final String? milestoneId;
}
