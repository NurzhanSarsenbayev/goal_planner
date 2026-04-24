class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.goalId,
    this.scheduledDate,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? goalId;
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

  PlannerTask scheduledToday() {
    final now = DateTime.now();

    return copyWith(
      scheduledDate: DateTime(now.year, now.month, now.day),
      completedAt: completedAt,
    );
  }

  PlannerTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? goalId,
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
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt,
    );
  }
}