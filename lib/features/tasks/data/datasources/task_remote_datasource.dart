import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/task_model.dart';

/// Remote data source for Task operations.
///
/// Handles all HTTP requests to fetch, create, update, and delete tasks.
/// This abstraction allows the repository to remain agnostic about
/// the actual data source implementation. It can easily be mocked
/// for testing or swapped with a different implementation.
///
/// **Uses DioClient for:**
/// - Centralized HTTP client with interceptors
/// - Automatic error handling
/// - Logging and debugging
/// - Consistent configuration
class TaskRemoteDataSource {
  final DioClient _dioClient;

  TaskRemoteDataSource() : _dioClient = DioClient();

  /// Fetch all tasks from the server
  ///
  /// Performs a GET request to retrieve all tasks.
  /// Returns a list of TaskModel instances.
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.getTasksEndpoint(),
      );
      final dynamic tasksJson = response.data ?? <dynamic>[];
      final List<dynamic> jsonList = tasksJson as List<dynamic>;
      return jsonList
          .map<TaskModel>((dynamic json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch tasks: ${e.toString()}', null);
    }
  }

  /// Fetch a specific task by ID
  ///
  /// Performs a GET request to retrieve a single task by its ID.
  /// Returns a TaskModel instance.
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.getTaskByIdEndpoint(id),
      );
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch task: ${e.toString()}', null);
    }
  }

  /// Create a new task on the server
  ///
  /// Performs a POST request to create a new task.
  /// Returns the created TaskModel with server-generated ID.
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      // Convert to JSON for debugging
      final jsonData = task.toJson();

      // Make the POST request
      final response = await _dioClient.post(
        ApiConstants.getTasksEndpoint(),
        jsonData,
      );

      // Handle response data
      if (response.data == null) {
        throw NetworkException(
          'Server returned null response',
          response.statusCode,
        );
      }

      // Parse response
      if (response.data is Map<String, dynamic>) {
        return TaskModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        // Try to parse as string
        throw NetworkException(
          'Unexpected response format: ${response.data.runtimeType}',
          response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      // Enhanced error logging
      throw NetworkException(
        'Failed to create task: $e',
        null,
      );
    }
  }

  /// Update an existing task
  ///
  /// Performs a PUT request to update an existing task.
  /// Returns the updated TaskModel.
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await _dioClient.put<Map<String, dynamic>>(
        ApiConstants.getTaskByIdEndpoint(task.id),
        data: task.toJson(),
      );
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update task: ${e.toString()}', null);
    }
  }

  /// Delete a task
  ///
  /// Performs a DELETE request to remove a task from the server.
  Future<void> deleteTask(String id) async {
    try {
      await _dioClient.delete<Map<String, dynamic>>(
        ApiConstants.getTaskByIdEndpoint(id),
      );
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to delete task: ${e.toString()}', null);
    }
  }
}
