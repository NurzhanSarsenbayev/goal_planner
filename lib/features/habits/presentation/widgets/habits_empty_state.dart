import 'package:flutter/material.dart';

class HabitsEmptyState extends StatelessWidget {
  const HabitsEmptyState({
    required this.onCreateHabit,
    this.title = 'Start tracking a small routine',
    this.description =
        'Pick something simple that you want to notice every week.',
    this.buttonLabel = 'Create first habit',
    this.icon = Icons.track_changes_outlined,
    this.showExamples = true,
    super.key,
  });

  final Future<void> Function() onCreateHabit;
  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final bool showExamples;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (showExamples) ...[
                const SizedBox(height: 20),
                const _HabitExamples(),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreateHabit,
                icon: const Icon(Icons.add),
                label: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitExamples extends StatelessWidget {
  const _HabitExamples();

  @override
  Widget build(BuildContext context) {
    final examples = [
      'Drink water',
      'Read 10 minutes',
      'Walk',
      'Stretch',
      'Sleep before midnight',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final example in examples)
          Chip(label: Text(example), visualDensity: VisualDensity.compact),
      ],
    );
  }
}
