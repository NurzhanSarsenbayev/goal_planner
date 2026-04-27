import 'package:flutter/material.dart';

class StandaloneReportSection extends StatelessWidget {
  const StandaloneReportSection({super.key, required this.completedCount});

  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.inbox_outlined),
        title: const Text('Standalone'),
        subtitle: const Text('Completed tasks not linked to a goal'),
        trailing: Text(
          completedCount.toString(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
