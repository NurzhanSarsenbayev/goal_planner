import 'package:flutter/material.dart';

import '../../../../models/milestone.dart';

class MoveTaskToMilestoneDialog extends StatelessWidget {
  const MoveTaskToMilestoneDialog({super.key, required this.milestones});

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Move to milestone'),
      content: milestones.isEmpty
          ? const Text('No milestones available for this goal.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: milestones.map((milestone) {
                return ListTile(
                  title: Text(milestone.title),
                  subtitle: milestone.description.isEmpty
                      ? null
                      : Text(milestone.description),
                  onTap: () {
                    Navigator.of(context).pop(milestone);
                  },
                );
              }).toList(),
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
