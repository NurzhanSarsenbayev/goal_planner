import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/planner_time.dart';
import '../../../../shared/presentation/widgets/placeholder_screen.dart';
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
    final draft = await showDialog<StandaloneReminderDraft>(
      context: context,
      builder: (context) {
        return const StandaloneReminderDialog();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: widget.reminderStore,
      builder: (context, _) {
        final reminderStore = widget.reminderStore;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.standaloneRemindersScreenTitle)),
          body: _StandaloneRemindersBody(reminderStore: reminderStore),
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
  const _StandaloneRemindersBody({required this.reminderStore});

  final StandaloneReminderStore reminderStore;

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

        return _StandaloneReminderCard(reminder: reminder);
      },
    );
  }
}

class _StandaloneReminderCard extends StatelessWidget {
  const _StandaloneReminderCard({required this.reminder});

  final StandaloneReminder reminder;

  String _subtitle(BuildContext context, AppLocalizations l10n) {
    final time = formatPlannerTime(reminder.timeMinutes);

    switch (reminder.scheduleType) {
      case StandaloneReminderScheduleType.once:
        final scheduledDate = reminder.scheduledDate;
        final locale = Localizations.localeOf(context).toLanguageTag();

        if (scheduledDate == null) {
          return l10n.standaloneReminderOnceMissingDateSubtitle(time);
        }

        final date = DateFormat.yMMMd(locale).format(scheduledDate.toLocal());

        return l10n.standaloneReminderOnceSubtitle(date, time);

      case StandaloneReminderScheduleType.daily:
        return l10n.standaloneReminderDailySubtitle(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          reminder.scheduleType == StandaloneReminderScheduleType.daily
              ? Icons.repeat
              : Icons.event_outlined,
        ),
        title: Text(reminder.title),
        subtitle: Text(_subtitle(context, l10n)),
        trailing: Text(
          reminder.isEnabled
              ? l10n.standaloneReminderEnabledStatus
              : l10n.standaloneReminderDisabledStatus,
        ),
      ),
    );
  }
}
