import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class HabitsEmptyState extends StatelessWidget {
  const HabitsEmptyState({
    required this.onCreateHabit,
    this.title,
    this.description,
    this.buttonLabel,
    this.secondaryButtonLabel,
    this.onSecondaryAction,
    this.icon = Icons.track_changes_outlined,
    this.showExamples = true,
    super.key,
  });

  final Future<void> Function() onCreateHabit;
  final String? title;
  final String? description;
  final String? buttonLabel;
  final String? secondaryButtonLabel;
  final Future<void> Function()? onSecondaryAction;
  final IconData icon;
  final bool showExamples;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final resolvedTitle = title ?? l10n.habitsEmptyTitle;
    final resolvedDescription = description ?? l10n.habitsEmptyDescription;
    final resolvedButtonLabel = buttonLabel ?? l10n.habitsEmptyButton;

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
                resolvedTitle,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                resolvedDescription,
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
                label: Text(resolvedButtonLabel),
              ),
              if (secondaryButtonLabel != null &&
                  onSecondaryAction != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onSecondaryAction,
                  icon: const Icon(Icons.archive_outlined),
                  label: Text(secondaryButtonLabel!),
                ),
              ],
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
    final l10n = AppLocalizations.of(context);

    final examples = [
      l10n.habitExampleDrinkWater,
      l10n.habitExampleRead,
      l10n.habitExampleWalk,
      l10n.habitExampleStretch,
      l10n.habitExampleSleep,
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
