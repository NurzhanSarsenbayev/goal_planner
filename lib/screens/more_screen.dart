import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.onOpenAllTasks});

  final VoidCallback onOpenAllTasks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.task_alt),
            title: const Text('All tasks'),
            subtitle: const Text('View all tasks in one place.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenAllTasks,
          ),
        ),
      ],
    );
  }
}
