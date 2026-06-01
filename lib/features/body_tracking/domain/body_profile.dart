const defaultBodyProfileId = 'default';

enum BodyFatFormula { usNavyFemale, usNavyMale }

class BodyProfile {
  const BodyProfile({
    required this.id,
    required this.heightCm,
    required this.bodyFatFormula,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(heightCm > 0, 'heightCm must be positive.');

  final String id;
  final double heightCm;
  final BodyFatFormula bodyFatFormula;
  final DateTime createdAt;
  final DateTime updatedAt;

  BodyProfile copyWith({
    String? id,
    double? heightCm,
    BodyFatFormula? bodyFatFormula,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BodyProfile(
      id: id ?? this.id,
      heightCm: heightCm ?? this.heightCm,
      bodyFatFormula: bodyFatFormula ?? this.bodyFatFormula,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String bodyFatFormulaToStorage(BodyFatFormula formula) {
  return switch (formula) {
    BodyFatFormula.usNavyFemale => 'us_navy_female',
    BodyFatFormula.usNavyMale => 'us_navy_male',
  };
}

BodyFatFormula bodyFatFormulaFromStorage(String value) {
  return switch (value) {
    'us_navy_female' => BodyFatFormula.usNavyFemale,
    'us_navy_male' => BodyFatFormula.usNavyMale,
    _ => throw ArgumentError.value(
      value,
      'value',
      'Unsupported body fat formula.',
    ),
  };
}
