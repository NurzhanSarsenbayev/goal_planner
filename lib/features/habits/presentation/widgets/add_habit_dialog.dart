import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({
    this.initialTitle = '',
    this.initialDescription = '',
    this.dialogTitle,
    this.actionLabel,
    super.key,
  });

  final String initialTitle;
  final String initialDescription;
  final String? dialogTitle;
  final String? actionLabel;

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
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

    Navigator.of(
      context,
    ).pop(AddHabitDraft(title: title, description: description));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
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
  const AddHabitDraft({required this.title, required this.description});

  final String title;
  final String description;
}
