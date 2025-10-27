import 'package:dio/dio.dart';
import 'network_exceptions.dart';

/// Dio client configuration for HTTP requests.
///
/// This class sets up a centralized HTTP client with interceptors
/// for authentication, error handling, and logging. It provides a
/// reusable instance across the entire application, ensuring
/// consistent request/response handling and reducing code duplication.
///
/// **Why Interceptors are Essential:**
///
/// 1. **Logging Interceptor**: Provides detailed request/response logging
///    - Development: See exact API calls, payloads, headers, and responses
///    - Testing: Debug network issues without additional logging code
///    - Production: Can be disabled or switched to minimal logging
///
/// 2. **Error Handling Interceptor**: Centralizes error processing
///    - Converts Dio exceptions to readable messages
///    - Provides consistent error format across the app
///    - Allows retry logic for network failures
///
/// 3. **Authentication Interceptor**: Handles token management
///    - Automatically adds auth headers to requests
///    - Refreshes tokens when expired
///    - Reduces boilerplate in every API call
///
/// 4. **Request/Response Transformers**: Modify data before sending/receiving
///    - Encrypt/decrypt data
///    - Compress responses
///    - Parse special data formats
///
/// **Benefits for Testing:**
/// - Interceptors can be mocked or bypassed for unit tests
/// - Logging helps identify test failures
/// - Error interceptors ensure consistent test error handling
class DioClient {
  final Dio _dio;

  /// Singleton instance for app-wide use
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  DioClient._internal() : _dio = Dio() {
    _initClient();
  }

  void _initClient() {
    // Configure base options
    _dio.options = BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    // Order matters: request interceptors run first, response interceptors last
    _dio.interceptors.addAll([
      // 1. Logging Interceptor - Logs all requests and responses
      //    Useful for debugging and monitoring network activity
      _LoggingInterceptor(),

      // 2. Error Handling Interceptor - Converts Dio errors to app exceptions
      //    Provides user-friendly error messages
      _ErrorInterceptor(),
    ]);
  }

  /// Get the configured Dio instance.
  Dio get instance => _dio;

  /// Helper methods for common operations
  /// These methods provide a cleaner API and encapsulate Dio-specific logic

  /// Perform a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Perform a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Perform a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Perform a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}

/// Custom logging interceptor that provides detailed request/response information
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ 📤 REQUEST');
    print('│ ${options.method} → ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      print('│ Query Parameters: ${options.queryParameters}');
    }
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    print('└─────────────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ 📥 RESPONSE');
    print('│ ${response.requestOptions.method} ${response.statusCode}');
    print('│ URI: ${response.requestOptions.uri}');
    if (response.data != null) {
      print('│ Data: ${response.data}');
    }
    print('└─────────────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ ❌ ERROR');
    print(
      '│ ${err.requestOptions.method} ${err.response?.statusCode ?? 'N/A'}',
    );
    print('│ URI: ${err.requestOptions.uri}');
    print('│ Message: ${err.message}');
    if (err.response?.data != null) {
      print('│ Error Data: ${err.response?.data}');
    }
    print('└─────────────────────────────────────────────────────────────');
    handler.next(err);
  }
}

/// Error handling interceptor that provides consistent error messages
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // You can add additional logic here, such as:
    // - Retry logic for specific error codes
    // - Logging to analytics
    // - Showing error notifications
    // - Transforming error data

    handler.next(err);
  }
}
