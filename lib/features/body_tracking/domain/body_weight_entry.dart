import '../../../shared/planner_dates.dart';

const _unset = Object();

class BodyWeightEntry {
  BodyWeightEntry({
    required this.id,
    required DateTime date,
    required this.createdAt,
    required this.updatedAt,
    this.weightKg,
    this.isSkipped = false,
    this.note = '',
  }) : assert(weightKg == null || weightKg > 0, 'weightKg must be positive.'),
       assert(
         weightKg == null || !isSkipped,
         'Skipped entry cannot have weight.',
       ),
       date = dateOnly(date);

  final String id;
  final DateTime date;
  final double? weightKg;
  final bool isSkipped;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasWeight => weightKg != null;

  bool get hasNoWeightData => weightKg == null && !isSkipped;

  BodyWeightEntry copyWith({
    String? id,
    Object? date = _unset,
    Object? weightKg = _unset,
    bool? isSkipped,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextWeightKg = identical(weightKg, _unset)
        ? this.weightKg
        : weightKg as double?;

    return BodyWeightEntry(
      id: id ?? this.id,
      date: identical(date, _unset) ? this.date : date as DateTime,
      weightKg: nextWeightKg,
      isSkipped: isSkipped ?? this.isSkipped,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
