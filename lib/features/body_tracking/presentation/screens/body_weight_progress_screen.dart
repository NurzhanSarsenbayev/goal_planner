import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/body_weight_tracking_service.dart';
import '../../domain/body_weekly_weight_report.dart';
import '../../application/body_measurement_tracking_service.dart';
import '../../domain/body_weekly_measurement_report.dart';
import '../widgets/body_weight_weekly_average_chart.dart';
import '../../application/body_profile_tracking_service.dart';
import '../widgets/body_profile_progress_card.dart';
import '../../domain/body_metrics.dart';

class BodyWeightProgressScreen extends StatefulWidget {
  const BodyWeightProgressScreen({
    super.key,
    required this.service,
    required this.measurementService,
    required this.profileService,
  });

  final BodyWeightTrackingService service;
  final BodyMeasurementTrackingService measurementService;
  final BodyProfileTrackingService profileService;

  @override
  State<BodyWeightProgressScreen> createState() =>
      _BodyWeightProgressScreenState();
}

class _BodyWeightProgressScreenState extends State<BodyWeightProgressScreen> {
  late Future<_BodyProgressData> _loadFuture;

  @override
  void initState() {
    super.initState();

    _loadFuture = _loadProgressData();
  }

  Future<_BodyProgressData> _loadProgressData() async {
    final anchorDate = DateTime.now();
    final weightReportsFuture = widget.service.loadWeeklyReports(
      anchorDate: anchorDate,
    );
    final measurementReportsFuture = widget.measurementService
        .loadWeeklyReports(anchorDate: anchorDate);
    final currentMetricsFuture = widget.profileService.loadCurrentMetrics();

    return _BodyProgressData(
      weightReports: await weightReportsFuture,
      measurementReports: await measurementReportsFuture,
      currentMetrics: await currentMetricsFuture,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _loadFuture = _loadProgressData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyWeightProgressTitle)),
      body: FutureBuilder<_BodyProgressData>(
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

          final progressData = snapshot.data ?? const _BodyProgressData.empty();
          final weightReports = progressData.weightReports;
          final measurementReports = progressData.measurementReports;
          final currentMetrics = progressData.currentMetrics;

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                BodyProfileProgressCard(
                  service: widget.profileService,
                  onProfileChanged: _reload,
                ),
                const SizedBox(height: 16),
                _BodyCurrentMetricsCard(metrics: currentMetrics),
                if (progressData.hasNoReports) ...[
                  const SizedBox(height: 16),
                  _BodyProgressEmptyCard(
                    title: l10n.bodyWeightProgressEmptyTitle,
                    body: l10n.bodyWeightProgressEmptyBody,
                  ),
                ],
                if (weightReports.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.bodyWeightProgressSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BodyWeightWeeklyAverageChart(reports: weightReports),
                  const SizedBox(height: 16),
                  for (final report in weightReports) ...[
                    _BodyWeightWeeklyReportCard(report: report),
                    const SizedBox(height: 12),
                  ],
                ],
                if (measurementReports.isNotEmpty) ...[
                  if (weightReports.isNotEmpty) const SizedBox(height: 8),
                  Text(
                    l10n.bodyMeasurementsProgressSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.bodyMeasurementsProgressSectionSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final report in measurementReports) ...[
                    _BodyMeasurementsWeeklyReportCard(report: report),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BodyProgressData {
  const _BodyProgressData({
    required this.weightReports,
    required this.measurementReports,
    required this.currentMetrics,
  });

  const _BodyProgressData.empty()
    : weightReports = const [],
      measurementReports = const [],
      currentMetrics = const BodyMetrics(
        bmi: null,
        estimatedBodyFatPercent: null,
      );

  final List<BodyWeeklyWeightReport> weightReports;
  final List<BodyWeeklyMeasurementReport> measurementReports;
  final BodyMetrics currentMetrics;

  bool get hasNoReports => weightReports.isEmpty && measurementReports.isEmpty;
}

class _BodyCurrentMetricsCard extends StatelessWidget {
  const _BodyCurrentMetricsCard({required this.metrics});

  final BodyMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monitor_weight_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.bodyCurrentMetricsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.bodyCurrentMetricsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _BodyCurrentMetricRow(
              label: l10n.bodyCurrentMetricsBmiLabel,
              value: _bmiValue(l10n, metrics.bmi),
              isMissing: metrics.bmi == null,
            ),
            const SizedBox(height: 8),
            _BodyCurrentMetricRow(
              label: l10n.bodyCurrentMetricsBodyFatLabel,
              value: _bodyFatValue(l10n, metrics.estimatedBodyFatPercent),
              isMissing: metrics.estimatedBodyFatPercent == null,
            ),
          ],
        ),
      ),
    );
  }

  String _bmiValue(AppLocalizations l10n, double? value) {
    if (value == null) {
      return l10n.bodyCurrentMetricsBmiMissing;
    }

    return _formatMetric(value);
  }

  String _bodyFatValue(AppLocalizations l10n, double? value) {
    if (value == null) {
      return l10n.bodyCurrentMetricsBodyFatMissing;
    }

    return l10n.bodyCurrentMetricsBodyFatValue(_formatMetric(value));
  }

  String _formatMetric(double value) {
    return value.toStringAsFixed(1);
  }
}

class _BodyCurrentMetricRow extends StatelessWidget {
  const _BodyCurrentMetricRow({
    required this.label,
    required this.value,
    required this.isMissing,
  });

  final String label;
  final String value;
  final bool isMissing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isMissing ? colorScheme.onSurfaceVariant : null,
              fontWeight: isMissing ? null : FontWeight.w700,
            ),
          ),
        ),
      ],
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

class _BodyMeasurementsWeeklyReportCard extends StatelessWidget {
  const _BodyMeasurementsWeeklyReportCard({required this.report});

  final BodyWeeklyMeasurementReport report;

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
            if (report.neckCm != null) ...[
              const SizedBox(height: 12),
              _BodyWeightReportRow(
                label: l10n.bodyMeasurementsNeckLabel,
                value: _measurementValue(l10n, report.neckCm),
                delta: _deltaValue(l10n, report.neckDeltaCm),
              ),
            ],
            if (report.waistCm != null) ...[
              const SizedBox(height: 12),
              _BodyWeightReportRow(
                label: l10n.bodyMeasurementsWaistLabel,
                value: _measurementValue(l10n, report.waistCm),
                delta: _deltaValue(l10n, report.waistDeltaCm),
              ),
            ],
            if (report.hipsCm != null) ...[
              const SizedBox(height: 12),
              _BodyWeightReportRow(
                label: l10n.bodyMeasurementsHipsLabel,
                value: _measurementValue(l10n, report.hipsCm),
                delta: _deltaValue(l10n, report.hipsDeltaCm),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _measurementValue(AppLocalizations l10n, double? value) {
    if (value == null) {
      return l10n.bodyWeightNoData;
    }

    return '${_formatMeasurement(value)} ${l10n.bodyMeasurementsCmSuffix}';
  }

  String? _deltaValue(AppLocalizations l10n, double? delta) {
    if (delta == null) {
      return null;
    }

    final formattedDelta =
        '${_formatMeasurement(delta.abs())} ${l10n.bodyMeasurementsCmSuffix}';

    if (delta > 0) {
      return l10n.bodyWeightProgressDeltaUp(formattedDelta);
    }

    if (delta < 0) {
      return l10n.bodyWeightProgressDeltaDown(formattedDelta);
    }

    return l10n.bodyWeightProgressDeltaSame;
  }

  String _formatMeasurement(double value) {
    final fixed = value.toStringAsFixed(1);

    if (fixed.endsWith('.0')) {
      return value.toStringAsFixed(0);
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

class _BodyProgressEmptyCard extends StatelessWidget {
  const _BodyProgressEmptyCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
