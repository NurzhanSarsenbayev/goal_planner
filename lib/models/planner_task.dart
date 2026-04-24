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
}