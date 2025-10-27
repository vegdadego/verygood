import 'package:dio/dio.dart';

/// Custom exception class for network-related errors.
///
/// This class provides a unified way to handle and communicate
/// network errors throughout the application. It categorizes
/// errors into specific types (timeout, server error, etc.)
/// for better error handling and user feedback.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, [this.statusCode]);

  /// Create exception from Dio error
  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Request timeout');
      case DioExceptionType.badResponse:
        return NetworkException(
          'Server error: ${error.response?.statusCode}',
          error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      default:
        return const NetworkException('No internet connection');
    }
  }

  @override
  String toString() => 'NetworkException: $message';
}

