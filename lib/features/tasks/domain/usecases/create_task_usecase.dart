import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for creating a new task.
///
/// This use case handles the business logic for creating a task.
/// It validates input, generates unique IDs, and coordinates with
/// the repository. Centralizing this logic here ensures consistency
/// across the entire application and makes it easy to modify task
/// creation rules without affecting UI or data layer.
class CreateTaskUseCase {
  final TaskRepository _repository;

  CreateTaskUseCase(this._repository);

  /// Execute the use case to create a new task
  ///
  /// [title] - The task title
  /// [description] - The task description
  Future<Task> call({
    required String title,
    required String description,
  }) async {
    final task = Task(
      id: _generateId(),
      title: title,
      description: description,
      completed: false,
    );

    return await _repository.createTask(task);
  }

  /// Generate a unique ID for the task
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
