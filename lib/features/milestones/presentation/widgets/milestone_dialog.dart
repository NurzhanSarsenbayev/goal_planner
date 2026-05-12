import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class MilestoneDialog extends StatefulWidget {
  const MilestoneDialog({
    super.key,
    this.initialTitle = '',
    this.initialDescription = '',
    this.title,
    this.submitLabel,
  });

  final String initialTitle;
  final String initialDescription;
  final String? title;
  final String? submitLabel;

  @override
  State<MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<MilestoneDialog> {
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
    ).pop(MilestoneDraft(title: title, description: description));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.title ?? l10n.milestoneDialogAddTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.milestoneTitleFieldLabel,
              hintText: l10n.milestoneTitleFieldHint,
            ),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.milestoneDescriptionFieldLabel,
              hintText: l10n.milestoneDescriptionFieldHint,
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
          child: Text(widget.submitLabel ?? l10n.commonAdd),
        ),
      ],
    );
  }
}

class MilestoneDraft {
  const MilestoneDraft({required this.title, required this.description});

  final String title;
  final String description;
}
