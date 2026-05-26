enum Priority { high, medium, low }

enum FilterMode { all, active, done }

class Task {
  final String id;
  String title;
  String? note;
  bool isDone;
  Priority priority;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.note,
    this.isDone = false,
    this.priority = Priority.medium,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? note,
    bool? isDone,
    Priority? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }
}
