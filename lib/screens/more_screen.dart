import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.onOpenAllTasks,
    required this.onOpenReports,
  });

  final VoidCallback onOpenAllTasks;
  final VoidCallback onOpenReports;

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
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reports'),
            subtitle: const Text('Review completed work and goal progress.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenReports,
          ),
        ),
      ],
    );
  }
}
