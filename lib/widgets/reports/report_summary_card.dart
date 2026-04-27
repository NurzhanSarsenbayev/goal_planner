import 'package:flutter/material.dart';

class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({
    super.key,
    required this.completedCount,
    required this.goalLinkedCount,
    required this.standaloneCount,
    required this.activeDaysCount,
    required this.periodDaysCount,
    required this.goalLinkedSharePercent,
  });

  final int completedCount;
  final int goalLinkedCount;
  final int standaloneCount;
  final int activeDaysCount;
  final int periodDaysCount;
  final int goalLinkedSharePercent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Completed tasks',
              value: completedCount.toString(),
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Goal-linked',
              value: goalLinkedCount.toString(),
            ),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Standalone', value: standaloneCount.toString()),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Goal-linked share',
              value: '$goalLinkedSharePercent%',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Active days',
              value: '$activeDaysCount / $periodDaysCount',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
