import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/body_weekly_composition_report.dart';

class BodyCompositionTrendCard extends StatelessWidget {
  const BodyCompositionTrendCard({super.key, required this.reports});

  final List<BodyWeeklyCompositionReport> reports;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chartReports = reports.reversed.toList(growable: false);
    final colorScheme = Theme.of(context).colorScheme;
    final latestReport = reports.isEmpty ? null : reports.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bodyCompositionTrendTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.bodyCompositionTrendSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (latestReport != null) ...[
              _BodyCompositionLatestSummary(report: latestReport),
              const SizedBox(height: 18),
            ],
            const SizedBox(height: 16),
            _BodyCompositionMetricChart(
              title: l10n.bodyCompositionTrendWeightTitle,
              unit: l10n.bodyWeightKgShortSuffix,
              values: chartReports
                  .map((report) => report.averageWeightKg)
                  .toList(growable: false),
              lineColor: colorScheme.primary,
            ),
            const SizedBox(height: 18),
            _BodyCompositionMetricChart(
              title: l10n.bodyCompositionTrendBodyFatTitle,
              unit: l10n.bodyCompositionPercentSuffix,
              values: chartReports
                  .map((report) => report.estimatedBodyFatPercent)
                  .toList(growable: false),
              lineColor: colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyCompositionLatestSummary extends StatelessWidget {
  const _BodyCompositionLatestSummary({required this.report});

  final BodyWeeklyCompositionReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bodyCompositionTrendLatestTitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _BodyCompositionSummaryRow(
              label: l10n.bodyCompositionTrendWeightTitle,
              value: _weightValue(l10n, report.averageWeightKg),
              delta: _weightDelta(l10n, report.averageWeightDeltaKg),
            ),
            const SizedBox(height: 8),
            _BodyCompositionSummaryRow(
              label: l10n.bodyCompositionTrendBodyFatTitle,
              value: _bodyFatValue(l10n, report.estimatedBodyFatPercent),
              delta: _percentDelta(l10n, report.estimatedBodyFatDeltaPercent),
            ),
          ],
        ),
      ),
    );
  }

  String _weightValue(AppLocalizations l10n, double? value) {
    if (value == null) {
      return l10n.bodyCompositionTrendMissingValue;
    }

    return l10n.bodyWeightKgValue(_formatValue(value));
  }

  String _bodyFatValue(AppLocalizations l10n, double? value) {
    if (value == null) {
      return l10n.bodyCompositionTrendMissingValue;
    }

    return l10n.bodyCompositionTrendPercentValue(_formatValue(value));
  }

  String? _weightDelta(AppLocalizations l10n, double? value) {
    if (value == null) {
      return null;
    }

    return _deltaValue(
      l10n,
      l10n.bodyWeightKgValue(_formatValue(value.abs())),
      value,
    );
  }

  String? _percentDelta(AppLocalizations l10n, double? value) {
    if (value == null) {
      return null;
    }

    return _deltaValue(
      l10n,
      l10n.bodyCompositionTrendPercentValue(_formatValue(value.abs())),
      value,
    );
  }

  String _deltaValue(AppLocalizations l10n, String value, double rawValue) {
    if (rawValue > 0) {
      return l10n.bodyCompositionTrendDeltaUp(value);
    }

    if (rawValue < 0) {
      return l10n.bodyCompositionTrendDeltaDown(value);
    }

    return l10n.bodyCompositionTrendDeltaSame;
  }

  String _formatValue(double value) {
    final fixed = value.toStringAsFixed(1);

    if (fixed.endsWith('.0')) {
      return value.toStringAsFixed(0);
    }

    return fixed;
  }
}

class _BodyCompositionSummaryRow extends StatelessWidget {
  const _BodyCompositionSummaryRow({
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
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
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

class _BodyCompositionMetricChart extends StatelessWidget {
  const _BodyCompositionMetricChart({
    required this.title,
    required this.unit,
    required this.values,
    required this.lineColor,
  });

  final String title;
  final String unit;
  final List<double?> values;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chartValues = values.whereType<double>().toList(growable: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (chartValues.isEmpty)
          SizedBox(
            height: 80,
            child: Center(
              child: Text(
                l10n.bodyCompositionTrendMissingData,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _BodyCompositionLineChartPainter(
                values: values,
                unit: unit,
                lineColor: lineColor,
                gridColor: colorScheme.outlineVariant,
                labelColor: colorScheme.onSurfaceVariant,
                textStyle: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
      ],
    );
  }
}

class _BodyCompositionLineChartPainter extends CustomPainter {
  _BodyCompositionLineChartPainter({
    required this.values,
    required this.unit,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
    required this.textStyle,
  });

  final List<double?> values;
  final String unit;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;
  final TextStyle? textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final actualValues = values.whereType<double>().toList(growable: false);

    if (actualValues.isEmpty) {
      return;
    }

    const horizontalPadding = 8.0;
    const topPadding = 12.0;
    const bottomPadding = 24.0;
    final chartRect = Rect.fromLTWH(
      horizontalPadding,
      topPadding,
      size.width - horizontalPadding * 2,
      size.height - topPadding - bottomPadding,
    );

    final minValue = actualValues.reduce((first, second) {
      return first < second ? first : second;
    });
    final maxValue = actualValues.reduce((first, second) {
      return first > second ? first : second;
    });
    final valueRange = maxValue - minValue;
    final safeRange = valueRange == 0 ? 1.0 : valueRange;
    final bottomValue = valueRange == 0 ? minValue - 0.5 : minValue;
    final topValue = valueRange == 0 ? maxValue + 0.5 : maxValue;

    _drawGrid(canvas, chartRect);
    _drawValueLabel(canvas, chartRect.topLeft, topValue);
    _drawValueLabel(canvas, chartRect.bottomLeft, bottomValue);
    _drawLine(canvas, chartRect, bottomValue, safeRange, valueRange);
  }

  void _drawLine(
    Canvas canvas,
    Rect chartRect,
    double bottomValue,
    double safeRange,
    double valueRange,
  ) {
    final points = <Offset>[];

    for (var index = 0; index < values.length; index += 1) {
      final value = values[index];

      if (value == null) {
        continue;
      }

      final x = values.length == 1
          ? chartRect.center.dx
          : chartRect.left + chartRect.width * index / (values.length - 1);
      final normalizedValue = valueRange == 0
          ? 0.5
          : (value - bottomValue) / safeRange;
      final y = chartRect.bottom - chartRect.height * normalizedValue;

      points.add(Offset(x, y));
    }

    if (points.isEmpty) {
      return;
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, linePaint);
    }

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  void _drawGrid(Canvas canvas, Rect chartRect) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    canvas
      ..drawLine(chartRect.topLeft, chartRect.topRight, gridPaint)
      ..drawLine(chartRect.centerLeft, chartRect.centerRight, gridPaint)
      ..drawLine(chartRect.bottomLeft, chartRect.bottomRight, gridPaint);
  }

  void _drawValueLabel(Canvas canvas, Offset position, double value) {
    final painter = TextPainter(
      text: TextSpan(
        text: '${_formatValue(value)} $unit',
        style: (textStyle ?? const TextStyle()).copyWith(color: labelColor),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    painter.paint(
      canvas,
      Offset(position.dx, position.dy - painter.height / 2),
    );
  }

  String _formatValue(double value) {
    final fixed = value.toStringAsFixed(1);

    if (fixed.endsWith('.0')) {
      return value.toStringAsFixed(0);
    }

    return fixed;
  }

  @override
  bool shouldRepaint(covariant _BodyCompositionLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.unit != unit ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.textStyle != textStyle;
  }
}
