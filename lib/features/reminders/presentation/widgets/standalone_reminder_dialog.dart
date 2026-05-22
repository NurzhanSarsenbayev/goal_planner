import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/planner_dates.dart';
import '../../../../shared/planner_time.dart';
import '../../domain/standalone_reminder.dart';

class StandaloneReminderDraft {
  const StandaloneReminderDraft({
    required this.title,
    required this.scheduleType,
    required this.scheduledDate,
    required this.timeMinutes,
  });

  final String title;
  final StandaloneReminderScheduleType scheduleType;
  final DateTime? scheduledDate;
  final int timeMinutes;
}

class StandaloneReminderDialog extends StatefulWidget {
  const StandaloneReminderDialog({super.key});

  @override
  State<StandaloneReminderDialog> createState() =>
      _StandaloneReminderDialogState();
}

class _StandaloneReminderDialogState extends State<StandaloneReminderDialog> {
  final _titleController = TextEditingController();

  late StandaloneReminderScheduleType _scheduleType;
  late DateTime _scheduledDate;
  late int _timeMinutes;

  String? _errorText;

  @override
  void initState() {
    super.initState();

    final initialDateTime = DateTime.now().add(const Duration(minutes: 5));

    _scheduleType = StandaloneReminderScheduleType.daily;
    _scheduledDate = dateOnly(initialDateTime);
    _timeMinutes = plannerTimeMinutes(
      hour: initialDateTime.hour,
      minute: initialDateTime.minute,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  TimeOfDay get _initialTime {
    return TimeOfDay(hour: _timeMinutes ~/ 60, minute: _timeMinutes % 60);
  }

  DateTime get _selectedDateTime {
    return DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
    ).add(Duration(minutes: _timeMinutes));
  }

  Future<void> _pickDate() async {
    final today = todayDate();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate.isBefore(today) ? today : _scheduledDate,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    setState(() {
      _scheduledDate = dateOnly(pickedDate);
      _errorText = null;
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _initialTime,
    );

    if (!mounted || pickedTime == null) {
      return;
    }

    setState(() {
      _timeMinutes = plannerTimeMinutes(
        hour: pickedTime.hour,
        minute: pickedTime.minute,
      );
      _errorText = null;
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorText = l10n.standaloneReminderTitleRequiredError;
      });
      return;
    }

    if (_scheduleType == StandaloneReminderScheduleType.once &&
        !_selectedDateTime.isAfter(DateTime.now())) {
      setState(() {
        _errorText = l10n.standaloneReminderPastDateTimeError;
      });
      return;
    }

    Navigator.of(context).pop(
      StandaloneReminderDraft(
        title: title,
        scheduleType: _scheduleType,
        scheduledDate: _scheduleType == StandaloneReminderScheduleType.once
            ? _scheduledDate
            : null,
        timeMinutes: _timeMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateText = formatPlannerDate(_scheduledDate);
    final timeText = formatPlannerTime(_timeMinutes);

    return AlertDialog(
      title: Text(l10n.standaloneReminderDialogAddTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.standaloneReminderTitleFieldLabel,
                hintText: l10n.standaloneReminderTitleFieldHint,
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StandaloneReminderScheduleType>(
              initialValue: _scheduleType,
              decoration: InputDecoration(
                labelText: l10n.standaloneReminderScheduleTypeFieldLabel,
              ),
              items: [
                DropdownMenuItem(
                  value: StandaloneReminderScheduleType.daily,
                  child: Text(l10n.standaloneReminderScheduleDailyOption),
                ),
                DropdownMenuItem(
                  value: StandaloneReminderScheduleType.once,
                  child: Text(l10n.standaloneReminderScheduleOnceOption),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _scheduleType = value;
                  _errorText = null;
                });
              },
            ),
            if (_scheduleType == StandaloneReminderScheduleType.once) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(l10n.standaloneReminderDateButton(dateText)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text(l10n.standaloneReminderTimeButton(timeText)),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonAdd)),
      ],
    );
  }
}
