import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/planner_time.dart';
import '../../application/daily_review_reminder_settings_store.dart';

class DailyReviewReminderSettingsScreen extends StatefulWidget {
  const DailyReviewReminderSettingsScreen({
    super.key,
    required this.settingsStore,
  });

  final DailyReviewReminderSettingsStore settingsStore;

  @override
  State<DailyReviewReminderSettingsScreen> createState() =>
      _DailyReviewReminderSettingsScreenState();
}

class _DailyReviewReminderSettingsScreenState
    extends State<DailyReviewReminderSettingsScreen> {
  @override
  void initState() {
    super.initState();

    unawaited(widget.settingsStore.initialize());
  }

  Future<void> _pickReminderTime() async {
    final settings = widget.settingsStore.settings;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.timeMinutes ~/ 60,
        minute: settings.timeMinutes % 60,
      ),
    );

    if (!mounted || pickedTime == null) {
      return;
    }

    await widget.settingsStore.setTimeMinutes(
      plannerTimeMinutes(hour: pickedTime.hour, minute: pickedTime.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: widget.settingsStore,
      builder: (context, _) {
        final store = widget.settingsStore;
        final settings = store.settings;
        final timeText = formatPlannerTime(settings.timeMinutes);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.dailyReviewReminderSettingsTitle)),
          body: store.isLoading && !store.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.dailyReviewReminderSettingsDescription,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: SwitchListTile(
                        secondary: const Icon(Icons.nightlight_outlined),
                        title: Text(l10n.dailyReviewReminderEnabledTitle),
                        subtitle: Text(l10n.dailyReviewReminderEnabledSubtitle),
                        value: settings.isEnabled,
                        onChanged: (isEnabled) {
                          unawaited(store.setEnabled(isEnabled));
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        enabled: settings.isEnabled,
                        leading: const Icon(Icons.schedule),
                        title: Text(l10n.dailyReviewReminderTimeTitle),
                        subtitle: Text(
                          l10n.dailyReviewReminderTimeSubtitle(timeText),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: settings.isEnabled ? _pickReminderTime : null,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
