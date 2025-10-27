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
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Task>> getTasks() async {
    try {
      final taskModels = await _remoteDataSource.getTasks();
      return taskModels.map((model) => model as Task).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> getTaskById(String id) async {
    try {
      final taskModel = await _remoteDataSource.getTaskById(id);
      return taskModel as Task;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      final taskModel = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        isCompleted: task.isCompleted,
        createdAt: task.createdAt,
      );
      final createdTask = await _remoteDataSource.createTask(taskModel);
      return createdTask as Task;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      final taskModel = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        isCompleted: task.isCompleted,
        createdAt: task.createdAt,
      );
      final updatedTask = await _remoteDataSource.updateTask(taskModel);
      return updatedTask as Task;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _remoteDataSource.deleteTask(id);
    } catch (e) {
      rethrow;
    }
  }
}

