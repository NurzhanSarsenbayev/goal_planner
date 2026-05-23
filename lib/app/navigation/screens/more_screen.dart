import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../settings/app_language.dart';
import '../../../l10n/app_localizations.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.onCreateBackup,
    required this.onExportBackup,
    required this.onRestoreLatestBackup,
    required this.onRestoreExternalBackup,
    required this.lastBackupAt,
    required this.onOpenAllTasks,
    required this.onOpenReports,
    required this.onOpenRecurringTasks,
    required this.onShowTestNotification,
    required this.onOpenStandaloneReminders,
    required this.onOpenDailyReviewReminderSettings,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final Future<void> Function() onCreateBackup;
  final Future<void> Function() onExportBackup;
  final Future<void> Function() onRestoreLatestBackup;
  final Future<void> Function() onRestoreExternalBackup;
  final DateTime? lastBackupAt;
  final VoidCallback onOpenAllTasks;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenRecurringTasks;
  final Future<void> Function() onShowTestNotification;
  final VoidCallback onOpenStandaloneReminders;
  final VoidCallback onOpenDailyReviewReminderSettings;

  String _backupSubtitle(BuildContext context, AppLocalizations l10n) {
    final backupAt = lastBackupAt;

    if (backupAt == null) {
      return l10n.moreBackupNeverCreated;
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final formattedDate = DateFormat.yMMMd(
      locale,
    ).add_Hm().format(backupAt.toLocal());

    return l10n.moreBackupLastCreated(formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.moreSettingsSection,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.moreLanguageTitle),
            subtitle: DropdownButtonHideUnderline(
              child: DropdownButton<AppLanguage>(
                value: selectedLanguage,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: AppLanguage.system,
                    child: Text(l10n.moreLanguageSystemOption),
                  ),
                  DropdownMenuItem(
                    value: AppLanguage.english,
                    child: Text(l10n.moreLanguageEnglishOption),
                  ),
                  DropdownMenuItem(
                    value: AppLanguage.russian,
                    child: Text(l10n.moreLanguageRussianOption),
                  ),
                ],
                onChanged: (language) {
                  if (language == null) {
                    return;
                  }

                  onLanguageChanged(language);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.nightlight_outlined),
            title: Text(l10n.moreDailyReviewReminderTitle),
            subtitle: Text(l10n.moreDailyReviewReminderSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenDailyReviewReminderSettings,
          ),
        ),
        Text(
          l10n.moreBackupSection,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.moreCreateBackupTitle),
            subtitle: Text(_backupSubtitle(context, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              onCreateBackup();
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.ios_share_outlined),
            title: Text(l10n.moreExportBackupTitle),
            subtitle: Text(l10n.moreExportBackupSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              onExportBackup();
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: Text(l10n.moreRestoreBackupTitle),
            subtitle: Text(l10n.moreRestoreBackupSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              onRestoreLatestBackup();
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(l10n.moreRestoreExternalBackupTitle),
            subtitle: Text(l10n.moreRestoreExternalBackupSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              onRestoreExternalBackup();
            },
          ),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 16),
          Text(
            l10n.moreNotificationsSection,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(l10n.moreTestNotificationTitle),
              subtitle: Text(l10n.moreTestNotificationSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                onShowTestNotification();
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.moreToolsSection,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        _MoreNavigationCard(
          icon: Icons.notifications_outlined,
          title: l10n.moreStandaloneRemindersTitle,
          subtitle: l10n.moreStandaloneRemindersSubtitle,
          onTap: onOpenStandaloneReminders,
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
