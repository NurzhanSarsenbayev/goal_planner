import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/domain/body_metrics_calculator.dart';
import 'package:goal_planner/features/body_tracking/domain/body_profile.dart';

void main() {
  group('BodyMetricsCalculator', () {
    const calculator = BodyMetricsCalculator();

    test('calculates BMI when weight and height are available', () {
      final metrics = calculator.calculate(
        profile: _profile(heightCm: 168),
        weightKg: 60,
      );

      expect(metrics.bmi, closeTo(21.26, 0.01));
      expect(metrics.estimatedBodyFatPercent, isNull);
      expect(metrics.hasAnyMetric, isTrue);
    });

    test('returns null BMI when weight is missing', () {
      final metrics = calculator.calculate(profile: _profile(heightCm: 168));

      expect(metrics.bmi, isNull);
      expect(metrics.hasAnyMetric, isFalse);
    });

    test('calculates US Navy female body fat estimate', () {
      final metrics = calculator.calculate(
        profile: _profile(
          heightCm: 168,
          bodyFatFormula: BodyFatFormula.usNavyFemale,
        ),
        neckCm: 34,
        waistCm: 74,
        hipsCm: 101,
      );

      expect(metrics.estimatedBodyFatPercent, closeTo(28.14, 0.01));
      expect(metrics.hasAnyMetric, isTrue);
    });

    test('calculates US Navy male body fat estimate', () {
      final metrics = calculator.calculate(
        profile: _profile(
          heightCm: 180,
          bodyFatFormula: BodyFatFormula.usNavyMale,
        ),
        neckCm: 40,
        waistCm: 88,
      );

      expect(metrics.estimatedBodyFatPercent, closeTo(16.87, 0.01));
      expect(metrics.hasAnyMetric, isTrue);
    });

    test('returns null female body fat estimate when hips are missing', () {
      final metrics = calculator.calculate(
        profile: _profile(
          heightCm: 168,
          bodyFatFormula: BodyFatFormula.usNavyFemale,
        ),
        neckCm: 34,
        waistCm: 74,
      );

      expect(metrics.estimatedBodyFatPercent, isNull);
      expect(metrics.hasAnyMetric, isFalse);
    });

    test(
      'returns null body fat estimate when required measurements are invalid',
      () {
        final metrics = calculator.calculate(
          profile: _profile(
            heightCm: 180,
            bodyFatFormula: BodyFatFormula.usNavyMale,
          ),
          neckCm: 90,
          waistCm: 88,
        );

        expect(metrics.estimatedBodyFatPercent, isNull);
        expect(metrics.hasAnyMetric, isFalse);
      },
    );

    test('can calculate BMI even when body fat estimate is unavailable', () {
      final metrics = calculator.calculate(
        profile: _profile(
          heightCm: 168,
          bodyFatFormula: BodyFatFormula.usNavyFemale,
        ),
        weightKg: 60,
        neckCm: 34,
        waistCm: 74,
      );

      expect(metrics.bmi, closeTo(21.26, 0.01));
      expect(metrics.estimatedBodyFatPercent, isNull);
      expect(metrics.hasAnyMetric, isTrue);
    });
  });
}

BodyProfile _profile({
  double heightCm = 168,
  BodyFatFormula bodyFatFormula = BodyFatFormula.usNavyFemale,
}) {
  final now = DateTime(2026, 6, 1, 8);

  return BodyProfile(
    id: defaultBodyProfileId,
    heightCm: heightCm,
    bodyFatFormula: bodyFatFormula,
    createdAt: now,
    updatedAt: now,
  );
}
