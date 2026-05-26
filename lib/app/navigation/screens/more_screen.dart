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
        _MoreNavigationCard(
          icon: Icons.analytics_outlined,
          title: l10n.moreProgressReportsTitle,
          subtitle: l10n.moreProgressReportsSubtitle,
          onTap: onOpenReports,
        ),
        const SizedBox(height: 8),
        _MoreSectionCard(
          icon: Icons.notifications_none_outlined,
          title: l10n.moreRemindersSection,
          children: [
            _MoreActionTile(
              icon: Icons.notifications_outlined,
              title: l10n.moreStandaloneRemindersTitle,
              subtitle: l10n.moreStandaloneRemindersSubtitle,
              onTap: onOpenStandaloneReminders,
            ),
            _MoreActionTile(
              icon: Icons.nightlight_outlined,
              title: l10n.moreDailyReviewReminderTitle,
              subtitle: l10n.moreDailyReviewReminderSubtitle,
              onTap: onOpenDailyReviewReminderSettings,
            ),
            if (kDebugMode)
              _MoreActionTile(
                icon: Icons.notifications_active_outlined,
                title: l10n.moreTestNotificationTitle,
                subtitle: l10n.moreTestNotificationSubtitle,
                onTap: () {
                  onShowTestNotification();
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        _MoreSectionCard(
          icon: Icons.event_note_outlined,
          title: l10n.morePlanningSection,
          children: [
            _MoreActionTile(
              icon: Icons.task_alt,
              title: l10n.allTasksTitle,
              subtitle: l10n.moreAllTasksSubtitle,
              onTap: onOpenAllTasks,
            ),
            _MoreActionTile(
              icon: Icons.repeat,
              title: l10n.moreRecurringTasksTitle,
              subtitle: l10n.moreRecurringTasksSubtitle,
              onTap: onOpenRecurringTasks,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _MoreSectionCard(
          icon: Icons.settings_outlined,
          title: l10n.moreAppSection,
          children: [
            ListTile(
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
          ],
        ),
        const SizedBox(height: 8),
        _MoreSectionCard(
          icon: Icons.backup_outlined,
          title: l10n.moreBackupRestoreSection,
          children: [
            _MoreActionTile(
              icon: Icons.backup_outlined,
              title: l10n.moreCreateBackupTitle,
              subtitle: _backupSubtitle(context, l10n),
              onTap: () {
                onCreateBackup();
              },
            ),
            _MoreActionTile(
              icon: Icons.ios_share_outlined,
              title: l10n.moreExportBackupTitle,
              subtitle: l10n.moreExportBackupSubtitle,
              onTap: () {
                onExportBackup();
              },
            ),
            _MoreActionTile(
              icon: Icons.restore_outlined,
              title: l10n.moreRestoreBackupTitle,
              subtitle: l10n.moreRestoreBackupSubtitle,
              onTap: () {
                onRestoreLatestBackup();
              },
            ),
            _MoreActionTile(
              icon: Icons.upload_file_outlined,
              title: l10n.moreRestoreExternalBackupTitle,
              subtitle: l10n.moreRestoreExternalBackupSubtitle,
              onTap: () {
                onRestoreExternalBackup();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _MoreSectionCard extends StatelessWidget {
  const _MoreSectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: children,
      ),
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

class _MoreActionTile extends StatelessWidget {
  const _MoreActionTile({
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
