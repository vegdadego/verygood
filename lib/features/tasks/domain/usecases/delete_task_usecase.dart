import '../repositories/task_repository.dart';

/// Use case for deleting a task.
///
/// This use case handles the business logic for deleting tasks.
/// It can include additional rules like soft-delete, archive operations,
/// or permission checks. Centralizing deletion logic here ensures
/// consistent behavior across the application.
class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  /// Execute the use case to delete a task
  ///
  /// [id] - The unique identifier of the task to delete
  Future<void> call(String id) async {
    return await _repository.deleteTask(id);
  }
}
