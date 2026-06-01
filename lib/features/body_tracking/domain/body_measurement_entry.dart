import '../../../shared/planner_dates.dart';

const _unset = Object();

class BodyMeasurementEntry {
  BodyMeasurementEntry({
    required this.id,
    required DateTime date,
    required this.createdAt,
    required this.updatedAt,
    this.neckCm,
    this.waistCm,
    this.hipsCm,
    this.note = '',
  }) : assert(neckCm == null || neckCm > 0, 'neckCm must be positive.'),
       assert(waistCm == null || waistCm > 0, 'waistCm must be positive.'),
       assert(hipsCm == null || hipsCm > 0, 'hipsCm must be positive.'),
       assert(
         neckCm != null || waistCm != null || hipsCm != null,
         'At least one measurement must be provided.',
       ),
       date = dateOnly(date);

  final String id;
  final DateTime date;
  final double? neckCm;
  final double? waistCm;
  final double? hipsCm;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasAnyMeasurement {
    return neckCm != null || waistCm != null || hipsCm != null;
  }

  BodyMeasurementEntry copyWith({
    String? id,
    Object? date = _unset,
    Object? neckCm = _unset,
    Object? waistCm = _unset,
    Object? hipsCm = _unset,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BodyMeasurementEntry(
      id: id ?? this.id,
      date: identical(date, _unset) ? this.date : date as DateTime,
      neckCm: identical(neckCm, _unset)
          ? this.neckCm
          : _nullableDoubleFromObject(neckCm, 'neckCm'),
      waistCm: identical(waistCm, _unset)
          ? this.waistCm
          : _nullableDoubleFromObject(waistCm, 'waistCm'),
      hipsCm: identical(hipsCm, _unset)
          ? this.hipsCm
          : _nullableDoubleFromObject(hipsCm, 'hipsCm'),
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

double? _nullableDoubleFromObject(Object? value, String fieldName) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  throw ArgumentError.value(value, fieldName, 'must be a number or null.');
}
