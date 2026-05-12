import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.moreToolsSection,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        _MoreNavigationCard(
          icon: Icons.task_alt,
          title: l10n.allTasksTitle,
          subtitle: l10n.moreAllTasksSubtitle,
          onTap: onOpenAllTasks,
        ),
        const SizedBox(height: 8),
        _MoreNavigationCard(
          icon: Icons.analytics,
          title: l10n.reportsTitle,
          subtitle: l10n.moreReportsSubtitle,
          onTap: onOpenReports,
        ),
        const SizedBox(height: 8),
        _MoreNavigationCard(
          icon: Icons.repeat,
          title: l10n.moreRecurringTasksTitle,
          subtitle: l10n.moreRecurringTasksSubtitle,
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
