import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/milestone.dart';

class TodayTaskDialog extends StatefulWidget {
  const TodayTaskDialog({
    super.key,
    required this.goals,
    required this.milestones,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;

  @override
  State<TodayTaskDialog> createState() => _TodayTaskDialogState();
}

class _TodayTaskDialogState extends State<TodayTaskDialog> {
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
      TodayTaskDraft(
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

    return AlertDialog(
      title: const Text('Add task for today'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Buy milk',
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional',
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _selectedGoalId,
              decoration: const InputDecoration(
                labelText: 'Goal',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No goal'),
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
              decoration: const InputDecoration(
                labelText: 'Milestone',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No milestone'),
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class TodayTaskDraft {
  const TodayTaskDraft({
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