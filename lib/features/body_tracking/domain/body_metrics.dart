class BodyMetrics {
  const BodyMetrics({required this.bmi, required this.estimatedBodyFatPercent});

  final double? bmi;
  final double? estimatedBodyFatPercent;

  bool get hasAnyMetric => bmi != null || estimatedBodyFatPercent != null;
}
