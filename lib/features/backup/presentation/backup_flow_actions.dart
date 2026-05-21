import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/planner_task.dart';
import '../../../state/planner_store.dart';
import '../../habits/application/habit_store.dart';
import '../../reminders/application/task_reminder_lifecycle_service.dart';
import '../application/planner_backup_file_export_service.dart';
import '../application/planner_backup_file_storage.dart';
import '../application/planner_backup_restore_service.dart';

class BackupFlowActions {
  const BackupFlowActions({
    required PlannerBackupFileExportService backupFileExportService,
    required PlannerBackupFileStorage backupFileStorage,
    required PlannerBackupRestoreService backupRestoreService,
    required PlannerStore store,
    required HabitStore habitStore,
    required TaskReminderLifecycleService taskReminderLifecycleService,
    required bool Function() isMounted,
    required ValueChanged<DateTime?> onBackupStatusChanged,
  }) : _backupFileExportService = backupFileExportService,
       _backupFileStorage = backupFileStorage,
       _backupRestoreService = backupRestoreService,
       _store = store,
       _habitStore = habitStore,
       _taskReminderLifecycleService = taskReminderLifecycleService,
       _isMounted = isMounted,
       _onBackupStatusChanged = onBackupStatusChanged;

  final PlannerBackupFileExportService _backupFileExportService;
  final PlannerBackupFileStorage _backupFileStorage;
  final PlannerBackupRestoreService _backupRestoreService;
  final PlannerStore _store;
  final HabitStore _habitStore;
  final TaskReminderLifecycleService _taskReminderLifecycleService;
  final bool Function() _isMounted;
  final ValueChanged<DateTime?> _onBackupStatusChanged;

  Future<void> loadBackupStatus() async {
    try {
      final latestBackup = await _backupFileStorage.readLatestBackup();

      if (!_isMounted()) {
        return;
      }

      _onBackupStatusChanged(latestBackup?.exportedAt);
    } catch (_) {
      if (!_isMounted()) {
        return;
      }

      _onBackupStatusChanged(null);
    }
  }

  Future<void> exportBackupFile(BuildContext context) async {
    try {
      final file = await _backupFileExportService.createBackupFile();
      final latestBackup = await _backupFileStorage.readBackup(file);

      if (!_isMounted() || !context.mounted) {
        return;
      }

      _onBackupStatusChanged(latestBackup.exportedAt);

      final l10n = AppLocalizations.of(context);

      final result = await SharePlus.instance.share(
        ShareParams(
          title: l10n.backupExportShareTitle,
          subject: l10n.backupExportShareTitle,
          text: l10n.backupExportShareText,
          files: [XFile(file.path)],
        ),
      );

      if (!_isMounted() || !context.mounted) {
        return;
      }

      if (result.status == ShareResultStatus.dismissed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupExportDismissedMessage)),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportSuccessMessage)));
    } catch (_) {
      if (!_isMounted() || !context.mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportFailureMessage)));
    }
  }

  Future<void> createBackupFile(BuildContext context) async {
    try {
      final file = await _backupFileExportService.createBackupFile();
      final latestBackup = await _backupFileStorage.readBackup(file);

      if (!_isMounted() || !context.mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      _onBackupStatusChanged(latestBackup.exportedAt);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupCreateSuccessMessage(file.path))),
      );
    } catch (_) {
      if (!_isMounted() || !context.mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupCreateFailureMessage)));
    }
  }

  Future<void> restoreLatestBackupFile(BuildContext context) async {
    try {
      final latestBackupFile = await _backupFileStorage.findLatestBackupFile();

      if (!_isMounted() || !context.mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      if (latestBackupFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupRestoreNoLocalBackupMessage)),
        );
        return;
      }

      final confirmed = await _confirmRestore(
        context,
        message: l10n.backupRestoreConfirmMessage,
      );

      if (!_isMounted() || !context.mounted || !confirmed) {
        return;
      }

      await _restoreBackupFile(context, latestBackupFile);
    } catch (_) {
      _showRestoreFailure(context);
    }
  }

  Future<void> restoreExternalBackupFile(BuildContext context) async {
    try {
      const backupFileType = XTypeGroup(
        label: 'Goal Planner backup',
        extensions: ['json'],
        mimeTypes: ['application/json'],
      );

      final pickedFile = await openFile(acceptedTypeGroups: [backupFileType]);

      if (!_isMounted() || !context.mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);

      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupRestorePickCancelledMessage)),
        );
        return;
      }

      final confirmed = await _confirmRestore(
        context,
        message: l10n.backupRestoreExternalConfirmMessage,
      );

      if (!_isMounted() || !context.mounted || !confirmed) {
        return;
      }

      await _restoreBackupFile(context, File(pickedFile.path));
    } catch (_) {
      _showRestoreFailure(context);
    }
  }

  Future<bool> _confirmRestore(
    BuildContext context, {
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(l10n.backupRestoreConfirmTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.backupRestoreConfirmAction),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<void> _restoreBackupFile(BuildContext context, File file) async {
    final previousTasks = List<PlannerTask>.of(_store.tasks);

    final result = await _backupRestoreService.restoreFromFile(file);

    await _store.reload();
    await _habitStore.reload();
    await _resyncTaskRemindersAfterRestore(previousTasks);

    if (!_isMounted() || !context.mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    _onBackupStatusChanged(result.exportedAt);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.backupRestoreSuccessMessage)));
  }

  Future<void> _resyncTaskRemindersAfterRestore(
    List<PlannerTask> previousTasks,
  ) async {
    try {
      await _taskReminderLifecycleService.syncAfterTaskSetReplacement(
        previousTasks: previousTasks,
        currentTasks: _store.tasks,
      );
    } catch (_) {
      // Reminder restore sync must not block backup restore.
    }
  }

  void _showRestoreFailure(BuildContext context) {
    if (!_isMounted() || !context.mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.backupRestoreFailureMessage)));
  }
}
