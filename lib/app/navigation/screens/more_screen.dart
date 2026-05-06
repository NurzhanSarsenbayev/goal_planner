import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.onOpenAllTasks,
    required this.onOpenReports,
    required this.onOpenRecurringTasks,
    required this.onOpenHabits,
  });

  final VoidCallback onOpenAllTasks;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenRecurringTasks;
  final VoidCallback onOpenHabits;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _FeaturedHabitsCard(onTap: onOpenHabits),
        const SizedBox(height: 20),
        Text(
          'Tools',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        _MoreNavigationCard(
          icon: Icons.task_alt,
          title: 'All tasks',
          subtitle: 'View all tasks in one place.',
          onTap: onOpenAllTasks,
        ),
        const SizedBox(height: 8),
        _MoreNavigationCard(
          icon: Icons.analytics,
          title: 'Reports',
          subtitle: 'Review completed work and goal progress.',
          onTap: onOpenReports,
        ),
        const SizedBox(height: 8),
        _MoreNavigationCard(
          icon: Icons.repeat,
          title: 'Recurring tasks',
          subtitle: 'Manage repeated weekday and monthly tasks.',
          onTap: onOpenRecurringTasks,
        ),
      ],
    );
  }
}

class _FeaturedHabitsCard extends StatelessWidget {
  const _FeaturedHabitsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.track_changes_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Habits',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Track small routines across the week and see what actually sticks.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeatureChip(label: 'Weekly tracker'),
                  _FeatureChip(label: 'Local-first'),
                  _FeatureChip(label: 'Done / Missed / Skip'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.open_in_new, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Open habits',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}

class _MoreNavigationCard extends StatelessWidget {
  const _MoreNavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
