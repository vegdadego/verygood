import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for fetching a specific task by ID.
///
/// This use case encapsulates the logic for retrieving a single task.
/// It handles the coordination with the repository and can include
/// additional business rules like authorization checks or data
/// transformation. Keeping this logic separate from the presentation
/// layer makes it reusable and easy to test.
class GetTaskUseCase {
  final TaskRepository _repository;

  GetTaskUseCase(this._repository);

  /// Execute the use case to fetch a task by ID
  ///
  /// [id] - The unique identifier of the task
  Future<Task> call(String id) async {
    return await _repository.getTaskById(id);
  }
}

