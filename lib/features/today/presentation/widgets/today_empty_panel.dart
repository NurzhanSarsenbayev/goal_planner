import 'package:flutter/material.dart';

class TodayEmptyPanel extends StatelessWidget {
  const TodayEmptyPanel({required this.onPlanToday, super.key});

  final VoidCallback onPlanToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.today_outlined, size: 48, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'Plan today lightly',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Add one task that would make today feel a little more under control.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPlanToday,
              icon: const Icon(Icons.add),
              label: const Text('Plan today'),
            ),
          ],
        ),
      ),
    );
  }
}
