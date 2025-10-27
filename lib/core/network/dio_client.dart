import 'package:dio/dio.dart';

/// Dio client configuration for HTTP requests.
///
/// This class sets up a centralized HTTP client with interceptors
/// for authentication, error handling, and logging. It provides a
/// reusable instance across the entire application, ensuring
/// consistent request/response handling and reducing code duplication.
class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    _initClient();
  }

  void _initClient() {
    // Configure base options
    _dio.options.baseUrl = 'https://api.example.com';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors for logging and error handling
    _dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      // Add authentication interceptor here
      // Add error handling interceptor here
    ]);
  }

  /// Get the configured Dio instance.
  Dio get instance => _dio;
}

