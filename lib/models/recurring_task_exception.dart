import '../shared/planner_dates.dart';

class RecurringTaskException {
  RecurringTaskException({
    required this.id,
    required this.ruleId,
    required DateTime date,
    required this.createdAt,
  }) : date = dateOnly(date);

  final String id;
  final String ruleId;
  final DateTime date;
  final DateTime createdAt;

  bool matches({required String ruleId, required DateTime date}) {
    return this.ruleId == ruleId && this.date == dateOnly(date);
  }

  RecurringTaskException copyWith({
    String? id,
    String? ruleId,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return RecurringTaskException(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
