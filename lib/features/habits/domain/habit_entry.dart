import '../../../shared/planner_dates.dart';
import 'habit_entry_status.dart';

const _unset = Object();

class HabitEntry {
  HabitEntry({
    required this.id,
    required this.habitId,
    required DateTime date,
    required this.status,
    required this.completedCount,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  }) : date = dateOnly(date);

  final String id;
  final String habitId;
  final DateTime date;
  final HabitEntryStatus status;
  final int completedCount;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isMarked => status.isExplicitMark;

  bool get isCompleted => status.countsAsCompletion;

  bool get isFailure => status.countsAsFailure;

  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    HabitEntryStatus? status,
    int? completedCount,
    Object? note = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      status: status ?? this.status,
      completedCount: completedCount ?? this.completedCount,
      note: identical(note, _unset) ? this.note : note as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
