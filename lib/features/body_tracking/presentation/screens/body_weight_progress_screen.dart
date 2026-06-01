import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/body_weight_tracking_service.dart';
import '../../domain/body_weekly_weight_report.dart';
import '../widgets/body_weight_weekly_average_chart.dart';

class BodyWeightProgressScreen extends StatefulWidget {
  const BodyWeightProgressScreen({super.key, required this.service});

  final BodyWeightTrackingService service;

  @override
  State<BodyWeightProgressScreen> createState() =>
      _BodyWeightProgressScreenState();
}

class _BodyWeightProgressScreenState extends State<BodyWeightProgressScreen> {
  late Future<List<BodyWeeklyWeightReport>> _loadFuture;

  @override
  void initState() {
    super.initState();

    _loadFuture = widget.service.loadWeeklyReports(anchorDate: DateTime.now());
  }

  Future<void> _reload() async {
    setState(() {
      _loadFuture = widget.service.loadWeeklyReports(
        anchorDate: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyWeightProgressTitle)),
      body: FutureBuilder<List<BodyWeeklyWeightReport>>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _BodyWeightProgressMessage(
              title: l10n.bodyWeightProgressLoadErrorTitle,
              body: l10n.bodyWeightProgressLoadErrorBody,
              actionLabel: l10n.bodyWeightProgressRetryButton,
              onActionPressed: _reload,
            );
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return _BodyWeightProgressMessage(
              title: l10n.bodyWeightProgressEmptyTitle,
              body: l10n.bodyWeightProgressEmptyBody,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.bodyWeightProgressSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                BodyWeightWeeklyAverageChart(reports: reports),
                const SizedBox(height: 16),
                for (final report in reports) ...[
                  _BodyWeightWeeklyReportCard(report: report),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BodyWeightWeeklyReportCard extends StatelessWidget {
  const _BodyWeightWeeklyReportCard({required this.report});

  final BodyWeeklyWeightReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    final weekRange =
        '${materialL10n.formatMediumDate(report.weekStartDate)}'
        ' – ${materialL10n.formatMediumDate(report.weekEndDate)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weekRange,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _BodyWeightReportRow(
              label: l10n.bodyWeightWeeklyAverage,
              value: _weightValue(l10n, report.averageWeightKg),
              delta: _deltaValue(l10n, report.averageWeightDeltaKg),
            ),
            const SizedBox(height: 8),
            _BodyWeightReportRow(
              label: l10n.bodyWeightWeeklyMinimum,
              value: _weightValue(l10n, report.minWeightKg),
              delta: _deltaValue(l10n, report.minWeightDeltaKg),
            ),
            const SizedBox(height: 8),
            _BodyWeightReportRow(
              label: l10n.bodyWeightWeeklyDays,
              value:
                  '${report.weighedDaysCount}/'
                  '${BodyWeeklyWeightReport.totalDaysCount}',
              delta: null,
            ),
            if (report.skippedDaysCount > 0) ...[
              const SizedBox(height: 8),
              _BodyWeightReportRow(
                label: l10n.bodyWeightProgressSkippedDays,
                value: report.skippedDaysCount.toString(),
                delta: null,
              ),
            ],
            if (report.missingDaysCount > 0) ...[
              const SizedBox(height: 8),
              _BodyWeightReportRow(
                label: l10n.bodyWeightProgressMissingDays,
                value: report.missingDaysCount.toString(),
                delta: null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _weightValue(AppLocalizations l10n, double? weight) {
    if (weight == null) {
      return l10n.bodyWeightNoData;
    }

    return l10n.bodyWeightKgValue(_formatWeight(weight));
  }

  String? _deltaValue(AppLocalizations l10n, double? delta) {
    if (delta == null) {
      return null;
    }

    final formattedDelta = _formatWeight(delta.abs());

    if (delta > 0) {
      return l10n.bodyWeightProgressDeltaUp(
        l10n.bodyWeightKgValue(formattedDelta),
      );
    }

    if (delta < 0) {
      return l10n.bodyWeightProgressDeltaDown(
        l10n.bodyWeightKgValue(formattedDelta),
      );
    }

    return l10n.bodyWeightProgressDeltaSame;
  }

  String _formatWeight(double weight) {
    final fixed = weight.toStringAsFixed(2);

    if (fixed.endsWith('00')) {
      return weight.toStringAsFixed(0);
    }

    if (fixed.endsWith('0')) {
      return weight.toStringAsFixed(1);
    }

    return fixed;
  }
}

class _BodyWeightReportRow extends StatelessWidget {
  const _BodyWeightReportRow({
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final String value;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    final deltaText = delta;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (deltaText != null)
              Text(
                deltaText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BodyWeightProgressMessage extends StatelessWidget {
  const _BodyWeightProgressMessage({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final currentActionLabel = actionLabel;
    final currentOnActionPressed = onActionPressed;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(body, textAlign: TextAlign.center),
                if (currentActionLabel != null &&
                    currentOnActionPressed != null) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: currentOnActionPressed,
                    child: Text(currentActionLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
