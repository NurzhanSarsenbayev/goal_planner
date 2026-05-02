import 'package:flutter/material.dart';

import '../../features/reports/domain/report_period.dart';

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
    return SegmentedButton<ReportPeriod>(
      segments: const [
        ButtonSegment(value: ReportPeriod.today, label: Text('Today')),
        ButtonSegment(value: ReportPeriod.last7Days, label: Text('7 days')),
        ButtonSegment(value: ReportPeriod.last14Days, label: Text('14 days')),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}
