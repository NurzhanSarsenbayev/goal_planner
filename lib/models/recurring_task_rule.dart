import '../shared/planner_dates.dart';

const _unset = Object();

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
      RecurrenceType.monthly => _matchesMonthlyDate(normalizedDate),
    };
  }

  bool _matchesMonthlyDate(DateTime date) {
    final day = monthDay;

    if (day == null || day < 1 || day > 31) {
      return false;
    }

    final lastDayOfMonth = _lastDayOfMonth(date);
    final targetDay = day > lastDayOfMonth ? lastDayOfMonth : day;

    return date.day == targetDay;
  }

  int _lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  RecurringTaskRule copyWith({
    String? id,
    String? title,
    String? description,
    Object? goalId = _unset,
    Object? milestoneId = _unset,
    RecurrenceType? recurrenceType,
    List<int>? weekdays,
    Object? monthDay = _unset,
    DateTime? startDate,
    Object? endDate = _unset,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringTaskRule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goalId: identical(goalId, _unset) ? this.goalId : goalId as String?,
      milestoneId: identical(milestoneId, _unset)
          ? this.milestoneId
          : milestoneId as String?,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      weekdays: weekdays ?? this.weekdays,
      monthDay: identical(monthDay, _unset) ? this.monthDay : monthDay as int?,
      startDate: startDate ?? this.startDate,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
