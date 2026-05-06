import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.onOpenAllTasks,
    required this.onOpenReports,
    required this.onOpenRecurringTasks,
  });

  final VoidCallback onOpenAllTasks;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenRecurringTasks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
