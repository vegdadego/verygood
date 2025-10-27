/// API endpoint constants for the application.
///
/// Centralizes all API endpoint paths in one location.
/// This makes it easy to update URLs across the entire app
/// and ensures consistency in API endpoint usage.
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';

  // Task-related endpoints
  static const String tasks = '/tasks';
  static const String taskById = '/tasks/:id';

  // Example helper method to build full URL
  static String getTasksEndpoint() => tasks;
  static String getTaskByIdEndpoint(String id) => taskById.replaceAll(':id', id);
}

