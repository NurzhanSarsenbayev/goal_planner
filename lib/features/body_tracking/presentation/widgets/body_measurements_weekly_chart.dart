import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/body_weekly_measurement_report.dart';

class BodyMeasurementsWeeklyChart extends StatelessWidget {
  const BodyMeasurementsWeeklyChart({super.key, required this.reports});

  final List<BodyWeeklyMeasurementReport> reports;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chartReports = reports
        .where((report) => report.hasMeasurements)
        .toList(growable: false)
        .reversed
        .toList(growable: false);

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bodyMeasurementsProgressChartTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.bodyMeasurementsProgressChartSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _BodyMeasurementChartLegendItem(
                  label: l10n.bodyMeasurementsNeckLabel,
                  color: colorScheme.primary,
                ),
                _BodyMeasurementChartLegendItem(
                  label: l10n.bodyMeasurementsWaistLabel,
                  color: colorScheme.secondary,
                ),
                _BodyMeasurementChartLegendItem(
                  label: l10n.bodyMeasurementsHipsLabel,
                  color: colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (chartReports.isEmpty)
              _BodyMeasurementsChartEmpty(
                message: l10n.bodyMeasurementsProgressChartEmpty,
              )
            else
              SizedBox(
                height: 190,
                width: double.infinity,
                child: CustomPaint(
                  painter: _BodyMeasurementsChartPainter(
                    reports: chartReports,
                    neckColor: colorScheme.primary,
                    waistColor: colorScheme.secondary,
                    hipsColor: colorScheme.tertiary,
                    gridColor: colorScheme.outlineVariant,
                    labelColor: colorScheme.onSurfaceVariant,
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BodyMeasurementChartLegendItem extends StatelessWidget {
  const _BodyMeasurementChartLegendItem({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox(width: 10, height: 10),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _BodyMeasurementsChartEmpty extends StatelessWidget {
  const _BodyMeasurementsChartEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _BodyMeasurementsChartPainter extends CustomPainter {
  _BodyMeasurementsChartPainter({
    required this.reports,
    required this.neckColor,
    required this.waistColor,
    required this.hipsColor,
    required this.gridColor,
    required this.labelColor,
    required this.textStyle,
  });

  final List<BodyWeeklyMeasurementReport> reports;
  final Color neckColor;
  final Color waistColor;
  final Color hipsColor;
  final Color gridColor;
  final Color labelColor;
  final TextStyle? textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final allValues = <double>[
      for (final report in reports) ...[
        if (report.neckCm != null) report.neckCm!,
        if (report.waistCm != null) report.waistCm!,
        if (report.hipsCm != null) report.hipsCm!,
      ],
    ];

    if (allValues.isEmpty) {
      return;
    }

    const horizontalPadding = 8.0;
    const topPadding = 12.0;
    const bottomPadding = 28.0;
    final chartRect = Rect.fromLTWH(
      horizontalPadding,
      topPadding,
      size.width - horizontalPadding * 2,
      size.height - topPadding - bottomPadding,
    );

    final minValue = allValues.reduce((first, second) {
      return first < second ? first : second;
    });
    final maxValue = allValues.reduce((first, second) {
      return first > second ? first : second;
    });
    final valueRange = maxValue - minValue;
    final bottomValue = valueRange == 0 ? minValue - 1 : minValue;
    final topValue = valueRange == 0 ? maxValue + 1 : maxValue;
    final safeRange = topValue - bottomValue;

    _drawGrid(canvas, chartRect);
    _drawValueLabel(canvas, chartRect.topLeft, topValue);
    _drawValueLabel(canvas, chartRect.bottomLeft, bottomValue);

    _drawMeasurementLine(
      canvas: canvas,
      chartRect: chartRect,
      values: reports.map((report) => report.neckCm).toList(growable: false),
      bottomValue: bottomValue,
      safeRange: safeRange,
      color: neckColor,
    );
    _drawMeasurementLine(
      canvas: canvas,
      chartRect: chartRect,
      values: reports.map((report) => report.waistCm).toList(growable: false),
      bottomValue: bottomValue,
      safeRange: safeRange,
      color: waistColor,
    );
    _drawMeasurementLine(
      canvas: canvas,
      chartRect: chartRect,
      values: reports.map((report) => report.hipsCm).toList(growable: false),
      bottomValue: bottomValue,
      safeRange: safeRange,
      color: hipsColor,
    );
  }

  void _drawMeasurementLine({
    required Canvas canvas,
    required Rect chartRect,
    required List<double?> values,
    required double bottomValue,
    required double safeRange,
    required Color color,
  }) {
    final points = <Offset>[];

    for (var index = 0; index < values.length; index += 1) {
      final value = values[index];

      if (value == null) {
        continue;
      }

      final x = values.length == 1
          ? chartRect.center.dx
          : chartRect.left + chartRect.width * index / (values.length - 1);
      final normalizedValue = (value - bottomValue) / safeRange;
      final y = chartRect.bottom - chartRect.height * normalizedValue;

      points.add(Offset(x, y));
    }

    if (points.isEmpty) {
      return;
    }

    final linePaint = Paint()
      ..color = color
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
      ..color = color
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
        text: _formatMeasurement(value),
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

  String _formatMeasurement(double value) {
    final fixed = value.toStringAsFixed(1);

    if (fixed.endsWith('.0')) {
      return value.toStringAsFixed(0);
    }

    return fixed;
  }

  @override
  bool shouldRepaint(covariant _BodyMeasurementsChartPainter oldDelegate) {
    return oldDelegate.reports != reports ||
        oldDelegate.neckColor != neckColor ||
        oldDelegate.waistColor != waistColor ||
        oldDelegate.hipsColor != hipsColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.textStyle != textStyle;
  }
}
