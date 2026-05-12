import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class StandaloneReportSection extends StatelessWidget {
  const StandaloneReportSection({super.key, required this.completedCount});

  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.inbox_outlined),
        title: Text(l10n.reportsStandaloneTitle),
        subtitle: Text(l10n.reportsStandaloneSubtitle),
        trailing: Text(
          completedCount.toString(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
