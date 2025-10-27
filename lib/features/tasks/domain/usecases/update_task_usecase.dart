import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for updating an existing task.
///
/// This use case handles the business logic for updating a task.
/// It ensures data consistency and can include validation rules
/// specific to task updates. By centralizing this logic, we ensure
/// that update operations follow the same business rules throughout
/// the application.
class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  /// Execute the use case to update a task
  Future<Task> call(Task task) async {
    return await _repository.updateTask(task);
  }
}
