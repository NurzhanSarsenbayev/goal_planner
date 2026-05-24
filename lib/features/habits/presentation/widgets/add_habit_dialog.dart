import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/planner_time.dart';

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({
    this.initialTitle = '',
    this.initialDescription = '',
    this.dialogTitle,
    this.actionLabel,
    this.initialIsReminderEnabled = false,
    this.initialReminderTimeMinutes,
    super.key,
  });

  final String initialTitle;
  final String initialDescription;
  final String? dialogTitle;
  final String? actionLabel;
  final bool initialIsReminderEnabled;
  final int? initialReminderTimeMinutes;

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  static const _defaultReminderTimeMinutes = 20 * 60;

  late bool _isReminderEnabled;
  late int? _reminderTimeMinutes;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _isReminderEnabled = widget.initialIsReminderEnabled;
    _reminderTimeMinutes = widget.initialReminderTimeMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      AddHabitDraft(
        title: title,
        description: description,
        isReminderEnabled: _isReminderEnabled,
        reminderTimeMinutes: _isReminderEnabled ? _reminderTimeMinutes : null,
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final initialMinutes = _reminderTimeMinutes ?? _defaultReminderTimeMinutes;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialMinutes ~/ 60,
        minute: initialMinutes % 60,
      ),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _isReminderEnabled = true;
      _reminderTimeMinutes = plannerTimeMinutes(
        hour: picked.hour,
        minute: picked.minute,
      );
    });
  }

  void _setReminderEnabled(bool value) {
    setState(() {
      _isReminderEnabled = value;
      _reminderTimeMinutes = value
          ? _reminderTimeMinutes ?? _defaultReminderTimeMinutes
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      scrollable: true,
      title: Text(widget.dialogTitle ?? l10n.habitAddDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.habitTitleFieldLabel,
              hintText: l10n.habitTitleFieldHint,
            ),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.habitDescriptionFieldLabel,
              hintText: l10n.habitDescriptionFieldHint,
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.habitReminderEnabledTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isReminderEnabled && _reminderTimeMinutes != null
                          ? l10n.habitReminderTimeSubtitle(
                              formatPlannerTime(_reminderTimeMinutes!),
                            )
                          : l10n.habitReminderDisabledSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: _isReminderEnabled, onChanged: _setReminderEnabled),
            ],
          ),
          if (_isReminderEnabled) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickReminderTime,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.schedule, size: 18),
                label: Text(
                  l10n.habitReminderTimeButton(
                    formatPlannerTime(
                      _reminderTimeMinutes ?? _defaultReminderTimeMinutes,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.actionLabel ?? l10n.commonAdd),
        ),
      ],
    );
  }
}

class AddHabitDraft {
  const AddHabitDraft({
    required this.title,
    required this.description,
    required this.isReminderEnabled,
    required this.reminderTimeMinutes,
  });

  final String title;
  final String description;
  final bool isReminderEnabled;
  final int? reminderTimeMinutes;
}
