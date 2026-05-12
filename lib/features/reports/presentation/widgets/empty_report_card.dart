import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class EmptyReportCard extends StatelessWidget {
  const EmptyReportCard({super.key, required this.periodTitle});

  final String periodTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.analytics),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.reportsEmptyMessage(periodTitle),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
