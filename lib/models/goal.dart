enum GoalStatus {
  active,
  paused,
  completed,
}

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final GoalStatus status;
  final DateTime createdAt;
}