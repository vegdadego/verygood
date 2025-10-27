/// Domain entity representing a Task.
///
/// This is a pure Dart class with no dependencies on external frameworks.
/// It represents the core business object and is independent of how data
/// is stored or displayed. This makes the domain layer portable and
/// testable without infrastructure concerns.
///
/// **Core Properties:**
/// - `id`: Unique identifier for the task
/// - `title`: Task title
/// - `description`: Task description
/// - `completed`: Whether the task is completed
class Task {
  final String id;
  final String title;
  final String description;
  final bool completed;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
  });

  /// Create a copy of this task with updated properties
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          completed == other.completed;

  @override
  int get hashCode => Object.hash(id, title, description, completed);
}
