/// API endpoint constants for the application.
///
/// Centralizes all API endpoint paths in one location.
/// This makes it easy to update URLs across the entire app
/// and ensures consistency in API endpoint usage.
///
/// **Using JSONPlaceholder for demo purposes:**
/// JSONPlaceholder is a fake REST API for testing and prototyping.
/// It provides endpoints that mimic real APIs without needing a backend.
class ApiConstants {
  // Note: The base URL is configured in DioClient to keep configuration centralized
  // We only define endpoint paths here

  // Task-related endpoints (using JSONPlaceholder's posts endpoint as tasks)
  // In a real app, you would use actual task endpoints like '/tasks'
  static const String tasks = '/posts';
  static const String taskById = '/posts/:id';

  // Example helper method to build full URL
  static String getTasksEndpoint() => tasks;
  static String getTaskByIdEndpoint(String id) =>
      taskById.replaceAll(':id', id);
}
