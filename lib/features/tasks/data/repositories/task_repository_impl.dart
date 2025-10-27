import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

/// Implementation of the TaskRepository.
///
/// This class implements the repository interface defined in the domain layer.
/// It coordinates between data sources and provides a clean interface for
/// the domain layer. This implementation can be easily swapped or extended
/// without affecting the domain layer, following the dependency inversion principle.
///
/// **Key Responsibilities:**
/// 1. **Model-to-Entity Mapping**: Converts TaskModel (data layer) to Task (domain entity)
/// 2. **Entity-to-Model Mapping**: Converts Task (domain entity) to TaskModel (data layer)
/// 3. **Error Propagation**: Forwards errors from data layer to domain layer
/// 4. **Abstraction**: Hides implementation details from domain layer
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  /// Fetch all tasks from the data source
  ///
  /// Maps TaskModel list to Task entity list, isolating the
  /// domain layer from data layer implementation details.
  @override
  Future<List<Task>> getTasks() async {
    final taskModels = await _remoteDataSource.getTasks();
    return taskModels.map((model) => model.toEntity()).toList();
  }

  /// Fetch a specific task by ID
  ///
  /// Retrieves a single task by ID and converts it from
  /// TaskModel to Task entity.
  @override
  Future<Task> getTaskById(String id) async {
    final taskModel = await _remoteDataSource.getTaskById(id);
    return taskModel.toEntity();
  }

  /// Create a new task
  ///
  /// Converts Task entity to TaskModel, creates it via data source,
  /// then converts the response back to Task entity.
  @override
  Future<Task> createTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    final createdModel = await _remoteDataSource.createTask(taskModel);
    return createdModel.toEntity();
  }

  /// Update an existing task
  ///
  /// Converts Task entity to TaskModel, updates it via data source,
  /// then converts the response back to Task entity.
  @override
  Future<Task> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    final updatedModel = await _remoteDataSource.updateTask(taskModel);
    return updatedModel.toEntity();
  }

  /// Delete a task
  ///
  /// Forwards the delete operation to the data source.
  @override
  Future<void> deleteTask(String id) async {
    await _remoteDataSource.deleteTask(id);
  }
}
