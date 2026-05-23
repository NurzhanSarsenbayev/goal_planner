import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/planner_time.dart';
import '../../../../../shared/presentation/widgets/placeholder_screen.dart';
import '../../application/standalone_reminder_store.dart';
import '../../domain/standalone_reminder.dart';
import '../widgets/standalone_reminder_dialog.dart';

class StandaloneRemindersScreen extends StatefulWidget {
  const StandaloneRemindersScreen({super.key, required this.reminderStore});

  final StandaloneReminderStore reminderStore;

  @override
  State<StandaloneRemindersScreen> createState() =>
      _StandaloneRemindersScreenState();
}

class _StandaloneRemindersScreenState extends State<StandaloneRemindersScreen> {
  @override
  void initState() {
    super.initState();

    unawaited(widget.reminderStore.initialize());
  }

  Future<void> _showAddReminderDialog() async {
    final l10n = AppLocalizations.of(context);

    final draft = await showDialog<StandaloneReminderDraft>(
      context: context,
      builder: (context) {
        return StandaloneReminderDialog(
          title: l10n.standaloneReminderDialogAddTitle,
          submitLabel: l10n.commonAdd,
        );
      },
    );

    if (draft == null) {
      return;
    }

    await widget.reminderStore.createStandaloneReminder(
      title: draft.title,
      scheduleType: draft.scheduleType,
      scheduledDate: draft.scheduledDate,
      timeMinutes: draft.timeMinutes,
    );
  }

  Future<void> _showEditReminderDialog(StandaloneReminder reminder) async {
    final l10n = AppLocalizations.of(context);

    final draft = await showDialog<StandaloneReminderDraft>(
      context: context,
      builder: (context) {
        return StandaloneReminderDialog(
          title: l10n.standaloneReminderDialogEditTitle,
          submitLabel: l10n.commonSave,
          initialTitle: reminder.title,
          initialScheduleType: reminder.scheduleType,
          initialScheduledDate: reminder.scheduledDate,
          initialTimeMinutes: reminder.timeMinutes,
        );
      },
    );

    if (draft == null) {
      return;
    }

    await widget.reminderStore.updateStandaloneReminder(
      reminderId: reminder.id,
      title: draft.title,
      scheduleType: draft.scheduleType,
      scheduledDate: draft.scheduledDate,
      timeMinutes: draft.timeMinutes,
    );
  }

  Future<void> _confirmDeleteReminder(StandaloneReminder reminder) async {
    final l10n = AppLocalizations.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.standaloneReminderDeleteDialogTitle),
          content: Text(l10n.standaloneReminderDeleteDialogMessage),
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
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await widget.reminderStore.deleteStandaloneReminder(reminder.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: widget.reminderStore,
      builder: (context, _) {
        final reminderStore = widget.reminderStore;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.standaloneRemindersScreenTitle)),
          body: _StandaloneRemindersBody(
            reminderStore: reminderStore,
            onEditReminder: _showEditReminderDialog,
            onDeleteReminder: _confirmDeleteReminder,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddReminderDialog,
            icon: const Icon(Icons.add),
            label: Text(l10n.standaloneReminderAddButton),
          ),
        );
      },
    );
  }
}

class _StandaloneRemindersBody extends StatelessWidget {
  const _StandaloneRemindersBody({
    required this.reminderStore,
    required this.onEditReminder,
    required this.onDeleteReminder,
  });

  final StandaloneReminderStore reminderStore;
  final ValueChanged<StandaloneReminder> onEditReminder;
  final ValueChanged<StandaloneReminder> onDeleteReminder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (reminderStore.isLoading && !reminderStore.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reminderStore.reminders.isEmpty) {
      return PlaceholderScreen(
        title: l10n.standaloneRemindersScreenTitle,
        description: l10n.standaloneRemindersEmptyDescription,
        icon: Icons.notifications_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reminderStore.reminders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final reminder = reminderStore.reminders[index];

        return _StandaloneReminderCard(
          reminder: reminder,
          onEnabledChanged: (isEnabled) {
            unawaited(
              reminderStore.setStandaloneReminderEnabled(
                reminderId: reminder.id,
                isEnabled: isEnabled,
              ),
            );
          },
          onEdit: () {
            onEditReminder(reminder);
          },
          onDelete: () {
            onDeleteReminder(reminder);
          },
        );
      },
    );
  }
}

class _StandaloneReminderCard extends StatelessWidget {
  const _StandaloneReminderCard({
    required this.reminder,
    required this.onEnabledChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final StandaloneReminder reminder;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _subtitle(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isExpired,
  }) {
    final time = formatPlannerTime(reminder.timeMinutes);

    switch (reminder.scheduleType) {
      case StandaloneReminderScheduleType.once:
        final scheduledDate = reminder.scheduledDate;
        final locale = Localizations.localeOf(context).toLanguageTag();

        if (scheduledDate == null) {
          return l10n.standaloneReminderOnceMissingDateSubtitle(time);
        }

        final date = DateFormat.yMMMd(locale).format(scheduledDate.toLocal());

        if (isExpired) {
          return l10n.standaloneReminderExpiredSubtitle(date, time);
        }

        return l10n.standaloneReminderOnceSubtitle(date, time);

      case StandaloneReminderScheduleType.daily:
        return l10n.standaloneReminderDailySubtitle(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isExpired = isStandaloneReminderExpired(reminder, DateTime.now());

    return Card(
      child: ListTile(
        leading: Icon(
          reminder.scheduleType == StandaloneReminderScheduleType.daily
              ? Icons.repeat
              : Icons.event_outlined,
        ),
        title: Text(reminder.title),
        subtitle: Text(_subtitle(context, l10n, isExpired: isExpired)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExpired)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  l10n.standaloneReminderExpiredStatus,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            else
              Switch(value: reminder.isEnabled, onChanged: onEnabledChanged),
            PopupMenuButton<_StandaloneReminderAction>(
              onSelected: (action) {
                switch (action) {
                  case _StandaloneReminderAction.edit:
                    onEdit();
                  case _StandaloneReminderAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: _StandaloneReminderAction.edit,
                    child: Text(l10n.commonEdit),
                  ),
                  PopupMenuItem(
                    value: _StandaloneReminderAction.delete,
                    child: Text(l10n.commonDelete),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum _StandaloneReminderAction { edit, delete }
