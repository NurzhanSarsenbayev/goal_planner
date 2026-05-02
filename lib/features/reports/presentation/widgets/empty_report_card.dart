import 'package:flutter/material.dart';

class EmptyReportCard extends StatelessWidget {
  const EmptyReportCard({super.key, required this.periodTitle});

  final String periodTitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.analytics),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No completed tasks for $periodTitle yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
