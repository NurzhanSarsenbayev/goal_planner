import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/body_weekly_weight_report.dart';

class BodyWeightWeeklyAverageChart extends StatelessWidget {
  const BodyWeightWeeklyAverageChart({super.key, required this.reports});

  final List<BodyWeeklyWeightReport> reports;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chartReports = reports
        .where((report) => report.averageWeightKg != null)
        .toList(growable: false)
        .reversed
        .toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bodyWeightProgressAverageChartTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.bodyWeightProgressAverageChartSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (chartReports.isEmpty)
              _BodyWeightAverageChartEmpty(
                message: l10n.bodyWeightProgressAverageChartEmpty,
              )
            else
              SizedBox(
                height: 170,
                width: double.infinity,
                child: CustomPaint(
                  painter: _BodyWeightAverageChartPainter(
                    reports: chartReports,
                    lineColor: Theme.of(context).colorScheme.primary,
                    pointColor: Theme.of(context).colorScheme.primary,
                    gridColor: Theme.of(context).colorScheme.outlineVariant,
                    labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _BodyWeightAverageChartEmpty extends StatelessWidget {
  const _BodyWeightAverageChartEmpty({required this.message});

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

class _BodyWeightAverageChartPainter extends CustomPainter {
  _BodyWeightAverageChartPainter({
    required this.reports,
    required this.lineColor,
    required this.pointColor,
    required this.gridColor,
    required this.labelColor,
    required this.textStyle,
  });

  final List<BodyWeeklyWeightReport> reports;
  final Color lineColor;
  final Color pointColor;
  final Color gridColor;
  final Color labelColor;
  final TextStyle? textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final values = reports
        .map((report) => report.averageWeightKg)
        .whereType<double>()
        .toList(growable: false);

    if (values.isEmpty) {
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

    final minValue = values.reduce((first, second) {
      return first < second ? first : second;
    });
    final maxValue = values.reduce((first, second) {
      return first > second ? first : second;
    });
    final valueRange = maxValue - minValue;
    final safeRange = valueRange == 0 ? 1.0 : valueRange;
    final bottomValue = valueRange == 0 ? minValue - 0.5 : minValue;
    final topValue = valueRange == 0 ? maxValue + 0.5 : maxValue;

    _drawGrid(canvas, chartRect);
    _drawValueLabel(canvas, chartRect.topLeft, topValue);
    _drawValueLabel(canvas, chartRect.bottomLeft, bottomValue);

    final points = <Offset>[];

    for (var index = 0; index < values.length; index += 1) {
      final x = values.length == 1
          ? chartRect.center.dx
          : chartRect.left + chartRect.width * index / (values.length - 1);
      final normalizedValue = valueRange == 0
          ? 0.5
          : (values[index] - minValue) / safeRange;
      final y = chartRect.bottom - chartRect.height * normalizedValue;

      points.add(Offset(x, y));
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
      ..color = pointColor
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
        text: _formatWeight(value),
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

  String _formatWeight(double weight) {
    final fixed = weight.toStringAsFixed(1);

    if (fixed.endsWith('0')) {
      return weight.toStringAsFixed(0);
    }

    return fixed;
  }

  @override
  bool shouldRepaint(covariant _BodyWeightAverageChartPainter oldDelegate) {
    return oldDelegate.reports != reports ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointColor != pointColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.textStyle != textStyle;
  }
}
