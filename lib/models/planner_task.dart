class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.goalId,
    this.milestoneId,
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
  final DateTime? scheduledDate;
  final bool isCompleted;
  final DateTime? completedAt;

  bool get isScheduledForToday {
    if (scheduledDate == null) {
      return false;
    }

    final now = DateTime.now();

    return scheduledDate!.year == now.year &&
        scheduledDate!.month == now.month &&
        scheduledDate!.day == now.day;
  }

  PlannerTask toggleCompleted() {
    final nextCompletedState = !isCompleted;

    return copyWith(
      isCompleted: nextCompletedState,
      completedAt: nextCompletedState ? DateTime.now() : null,
    );
  }

  PlannerTask scheduledToday() {
    final now = DateTime.now();

    return copyWith(
      scheduledDate: DateTime(now.year, now.month, now.day),
      completedAt: completedAt,
    );
  }

  PlannerTask moveToDirectGoal() {
    return PlannerTask(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      goalId: goalId,
      milestoneId: null,
      scheduledDate: scheduledDate,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  PlannerTask assignToMilestone(String milestoneId) {
    return PlannerTask(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      goalId: goalId,
      milestoneId: milestoneId,
      scheduledDate: scheduledDate,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  PlannerTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? goalId,
    String? milestoneId,
    DateTime? scheduledDate,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return PlannerTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      goalId: goalId ?? this.goalId,
      milestoneId: milestoneId ?? this.milestoneId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt,
    );
  }
}