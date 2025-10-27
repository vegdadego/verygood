import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/task_model.dart';

/// Remote data source for Task operations.
///
/// Handles all HTTP requests to fetch, create, update, and delete tasks.
/// This abstraction allows the repository to remain agnostic about
/// the actual data source implementation. It can easily be mocked
/// for testing or swapped with a different implementation.
class TaskRemoteDataSource {
  final Dio _dio;

  TaskRemoteDataSource(this._dio);

  /// Fetch all tasks from the server
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.getTasksEndpoint(),
      );
      final tasksJson = response.data ?? [];
      return tasksJson.map((json) => TaskModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Fetch a specific task by ID
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.getTaskByIdEndpoint(id),
      );
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Create a new task on the server
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.getTasksEndpoint(),
        data: task.toJson(),
      );
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Update an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.getTaskByIdEndpoint(task.id),
        data: task.toJson(),
      );
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        ApiConstants.getTaskByIdEndpoint(id),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}

