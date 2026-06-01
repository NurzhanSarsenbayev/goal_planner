import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/body_tracking/domain/body_profile.dart';

void main() {
  group('BodyProfile', () {
    test('copies selected fields', () {
      final createdAt = DateTime(2026, 6, 1, 8);
      final updatedAt = DateTime(2026, 6, 1, 9);
      final profile = BodyProfile(
        id: defaultBodyProfileId,
        heightCm: 168,
        bodyFatFormula: BodyFatFormula.usNavyFemale,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final updatedProfile = profile.copyWith(
        heightCm: 169,
        bodyFatFormula: BodyFatFormula.usNavyMale,
        updatedAt: updatedAt,
      );

      expect(updatedProfile.id, defaultBodyProfileId);
      expect(updatedProfile.heightCm, 169);
      expect(updatedProfile.bodyFatFormula, BodyFatFormula.usNavyMale);
      expect(updatedProfile.createdAt, createdAt);
      expect(updatedProfile.updatedAt, updatedAt);
    });

    test('maps body fat formula to storage and back', () {
      expect(
        bodyFatFormulaToStorage(BodyFatFormula.usNavyFemale),
        'us_navy_female',
      );
      expect(
        bodyFatFormulaToStorage(BodyFatFormula.usNavyMale),
        'us_navy_male',
      );
      expect(
        bodyFatFormulaFromStorage('us_navy_female'),
        BodyFatFormula.usNavyFemale,
      );
      expect(
        bodyFatFormulaFromStorage('us_navy_male'),
        BodyFatFormula.usNavyMale,
      );
    });

    test('throws for unsupported body fat formula storage value', () {
      expect(() => bodyFatFormulaFromStorage('unknown'), throwsArgumentError);
    });
  });
}
