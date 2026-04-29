import '../shared/planner_dates.dart';

const _unset = Object();

class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.goalId,
    this.milestoneId,
    this.recurringRuleId,
    this.scheduledDate,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? goalId;
  final String? milestoneId;
  final String? recurringRuleId;
  final DateTime? scheduledDate;
  final bool isCompleted;
  final DateTime? completedAt;

  bool get isScheduledForToday {
    if (scheduledDate == null) {
      return false;
    }

    return dateOnly(scheduledDate!) == todayDate();
  }

  bool get isStandalone => goalId == null && milestoneId == null;

  bool get isDirectGoalTask => goalId != null && milestoneId == null;

  bool get isMilestoneTask => goalId != null && milestoneId != null;

  PlannerTask toggleCompleted() {
    final nextCompletedState = !isCompleted;

    return copyWith(
      isCompleted: nextCompletedState,
      completedAt: nextCompletedState ? DateTime.now() : null,
    );
  }

  PlannerTask completedOn(DateTime date) {
    return copyWith(isCompleted: true, completedAt: dateOnly(date));
  }

  PlannerTask scheduledToday() {
    return scheduleForDate(DateTime.now());
  }

  PlannerTask scheduleForDate(DateTime date) {
    return copyWith(scheduledDate: dateOnly(date));
  }

  PlannerTask unschedule() {
    return copyWith(scheduledDate: null);
  }

  PlannerTask assignToGoal(String goalId) {
    return copyWith(goalId: goalId, milestoneId: null);
  }

  PlannerTask assignToGoalMilestone({
    required String goalId,
    required String milestoneId,
  }) {
    return copyWith(goalId: goalId, milestoneId: milestoneId);
  }

  PlannerTask assignToMilestone(String milestoneId) {
    return copyWith(milestoneId: milestoneId);
  }

  PlannerTask moveToDirectGoal() {
    return copyWith(milestoneId: null);
  }

  PlannerTask detachFromGoal() {
    return copyWith(goalId: null, milestoneId: null);
  }

  PlannerTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    Object? goalId = _unset,
    Object? milestoneId = _unset,
    Object? recurringRuleId = _unset,
    Object? scheduledDate = _unset,
    bool? isCompleted,
    Object? completedAt = _unset,
  }) {
    return PlannerTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      goalId: identical(goalId, _unset) ? this.goalId : goalId as String?,
      milestoneId: identical(milestoneId, _unset)
          ? this.milestoneId
          : milestoneId as String?,
      recurringRuleId: identical(recurringRuleId, _unset)
          ? this.recurringRuleId
          : recurringRuleId as String?,
      scheduledDate: identical(scheduledDate, _unset)
          ? this.scheduledDate
          : scheduledDate as DateTime?,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }
}
