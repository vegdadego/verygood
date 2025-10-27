import '../entities/task.dart';

/// Repository interface for Task operations.
///
/// This abstract class defines the contract for task data operations
/// without specifying the implementation. The domain layer depends on
/// this abstraction, allowing different implementations (API, database, cache)
/// to be swapped without changing the business logic. This follows the
/// Dependency Inversion Principle and makes the code more testable.
abstract class TaskRepository {
  /// Fetch all tasks
  Future<List<Task>> getTasks();

  /// Fetch a specific task by ID
  Future<Task> getTaskById(String id);

  /// Create a new task
  Future<Task> createTask(Task task);

  /// Update an existing task
  Future<Task> updateTask(Task task);

  /// Delete a task
  Future<void> deleteTask(String id);
}

