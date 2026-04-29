import '../shared/planner_dates.dart';

enum RecurrenceType { weekly, monthly }

class RecurringTaskRule {
  const RecurringTaskRule({
    required this.id,
    required this.title,
    required this.description,
    required this.recurrenceType,
    required this.weekdays,
    required this.monthDay,
    required this.startDate,
    required this.createdAt,
    this.goalId,
    this.milestoneId,
    this.endDate,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String description;
  final String? goalId;
  final String? milestoneId;
  final RecurrenceType recurrenceType;
  final List<int> weekdays;
  final int? monthDay;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  bool matchesDate(DateTime date) {
    if (!isActive) {
      return false;
    }

    final normalizedDate = dateOnly(date);
    final normalizedStartDate = dateOnly(startDate);

    if (normalizedDate.isBefore(normalizedStartDate)) {
      return false;
    }

    final normalizedEndDate = endDate == null ? null : dateOnly(endDate!);

    if (normalizedEndDate != null &&
        normalizedDate.isAfter(normalizedEndDate)) {
      return false;
    }

    return switch (recurrenceType) {
      RecurrenceType.weekly => weekdays.contains(normalizedDate.weekday),
      RecurrenceType.monthly => monthDay == normalizedDate.day,
    };
  }

  RecurringTaskRule copyWith({
    String? id,
    String? title,
    String? description,
    String? goalId,
    String? milestoneId,
    RecurrenceType? recurrenceType,
    List<int>? weekdays,
    int? monthDay,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringTaskRule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      milestoneId: milestoneId ?? this.milestoneId,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      weekdays: weekdays ?? this.weekdays,
      monthDay: monthDay ?? this.monthDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
