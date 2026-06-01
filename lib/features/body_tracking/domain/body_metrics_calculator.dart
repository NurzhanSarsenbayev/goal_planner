import 'dart:math' as math;

import 'body_metrics.dart';
import 'body_profile.dart';

class BodyMetricsCalculator {
  const BodyMetricsCalculator();

  BodyMetrics calculate({
    required BodyProfile profile,
    double? weightKg,
    double? neckCm,
    double? waistCm,
    double? hipsCm,
  }) {
    return BodyMetrics(
      bmi: _calculateBmi(weightKg: weightKg, heightCm: profile.heightCm),
      estimatedBodyFatPercent: _calculateEstimatedBodyFatPercent(
        formula: profile.bodyFatFormula,
        heightCm: profile.heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      ),
    );
  }

  double? _calculateBmi({required double? weightKg, required double heightCm}) {
    if (weightKg == null || weightKg <= 0 || heightCm <= 0) {
      return null;
    }

    final heightM = heightCm / 100;

    return weightKg / (heightM * heightM);
  }

  double? _calculateEstimatedBodyFatPercent({
    required BodyFatFormula formula,
    required double heightCm,
    required double? neckCm,
    required double? waistCm,
    required double? hipsCm,
  }) {
    if (heightCm <= 0 || neckCm == null || waistCm == null) {
      return null;
    }

    return switch (formula) {
      BodyFatFormula.usNavyMale => _calculateUsNavyMaleBodyFatPercent(
        heightCm: heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
      ),
      BodyFatFormula.usNavyFemale => _calculateUsNavyFemaleBodyFatPercent(
        heightCm: heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      ),
    };
  }

  double? _calculateUsNavyMaleBodyFatPercent({
    required double heightCm,
    required double neckCm,
    required double waistCm,
  }) {
    final waistMinusNeckCm = waistCm - neckCm;

    if (waistMinusNeckCm <= 0) {
      return null;
    }

    return 495 /
            (1.0324 -
                0.19077 * _log10(waistMinusNeckCm) +
                0.15456 * _log10(heightCm)) -
        450;
  }

  double? _calculateUsNavyFemaleBodyFatPercent({
    required double heightCm,
    required double neckCm,
    required double waistCm,
    required double? hipsCm,
  }) {
    if (hipsCm == null) {
      return null;
    }

    final waistPlusHipsMinusNeckCm = waistCm + hipsCm - neckCm;

    if (waistPlusHipsMinusNeckCm <= 0) {
      return null;
    }

    return 495 /
            (1.29579 -
                0.35004 * _log10(waistPlusHipsMinusNeckCm) +
                0.22100 * _log10(heightCm)) -
        450;
  }

  double _log10(double value) {
    return math.log(value) / math.ln10;
  }
}
