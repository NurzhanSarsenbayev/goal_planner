import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../report_period_l10n.dart';
import '../../domain/report_period.dart';

class ReportPeriodSelector extends StatelessWidget {
  const ReportPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  final ReportPeriod selectedPeriod;
  final void Function(ReportPeriod period) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SegmentedButton<ReportPeriod>(
      segments: [
        ButtonSegment(
          value: ReportPeriod.today,
          label: Text(ReportPeriod.today.localizedShortLabel(l10n)),
        ),
        ButtonSegment(
          value: ReportPeriod.last7Days,
          label: Text(ReportPeriod.last7Days.localizedShortLabel(l10n)),
        ),
        ButtonSegment(
          value: ReportPeriod.last14Days,
          label: Text(ReportPeriod.last14Days.localizedShortLabel(l10n)),
        ),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}
