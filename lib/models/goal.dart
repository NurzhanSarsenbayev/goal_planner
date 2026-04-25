enum GoalStatus {
  active,
  completed,
  archived,
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

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalStatus? status,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}