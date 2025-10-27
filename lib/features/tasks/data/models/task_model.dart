import '../../domain/entities/task.dart';

/// Data model representing a Task.
///
/// This class extends the domain entity and adds serialization
/// capabilities for JSON conversion. It acts as a bridge between
/// the domain layer (business logic) and the data layer (API/DB).
/// This separation allows the domain layer to remain independent
/// of data source implementations.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.isCompleted,
    required super.createdAt,
  });

  /// Convert JSON map to TaskModel
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert TaskModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

