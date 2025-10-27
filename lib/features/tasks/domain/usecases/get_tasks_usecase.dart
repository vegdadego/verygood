import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for fetching all tasks.
///
/// Use cases encapsulate specific business operations in the domain layer.
/// They represent what the application can do, independent of the user interface
/// or data sources. This makes the business logic reusable and testable.
/// Use cases are single-responsibility, making the code more maintainable.
class GetTasksUseCase {
  final TaskRepository _repository;

  GetTasksUseCase(this._repository);

  /// Execute the use case and return all tasks
  Future<List<Task>> call() async {
    return await _repository.getTasks();
  }
}

