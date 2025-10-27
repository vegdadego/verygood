import 'package:dio/dio.dart';

/// Custom exception class for network-related errors.
///
/// This class provides a unified way to handle and communicate
/// network errors throughout the application. It categorizes
/// errors into specific types (timeout, server error, etc.)
/// for better error handling and user feedback.
///
/// **Benefits:**
/// - **User-Friendly Messages**: Converts technical errors to readable text
/// - **Type Safety**: Strongly typed error handling
/// - **Status Code Handling**: Provides HTTP status codes for conditional handling
/// - **Centralized Error Handling**: All network errors processed in one place
class NetworkException implements Exception {
  /// Human-readable error message
  final String message;
  
  /// HTTP status code (if available)
  final int? statusCode;
  
  /// Original Dio exception type
  final DioExceptionType? errorType;
  
  /// Full error details from the server response
  final dynamic errorData;

  const NetworkException(
    this.message,
    this.statusCode, {
    this.errorType,
    this.errorData,
  });

  /// Create exception from Dio error
  /// 
  /// This factory method extracts meaningful information from Dio's
  /// exception and converts it into a user-friendly NetworkException.
  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
          null,
          errorType: error.type,
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          'Failed to send request. The request took too long.',
          null,
          errorType: error.type,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Server is taking too long to respond. Please try again.',
          null,
          errorType: error.type,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        return NetworkException(
          _getErrorMessageForStatusCode(statusCode),
          statusCode,
          errorType: error.type,
          errorData: error.response?.data,
        );

      case DioExceptionType.cancel:
        return const NetworkException(
          'Request was cancelled.',
          null,
          errorType: DioExceptionType.cancel,
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network settings.',
          null,
          errorType: DioExceptionType.connectionError,
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'SSL certificate error. Please try again later.',
          null,
          errorType: DioExceptionType.badCertificate,
        );

      default:
        return NetworkException(
          error.message ?? 'An unexpected network error occurred.',
          error.response?.statusCode,
          errorType: error.type,
          errorData: error.response?.data,
        );
    }
  }

  /// Get user-friendly error message based on HTTP status code
  static String _getErrorMessageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Authentication failed. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found. The requested item does not exist.';
      case 408:
        return 'Request timeout. Please try again.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Internal server error. Our servers are experiencing issues.';
      case 502:
        return 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. The server is temporarily down.';
      case 504:
        return 'Gateway timeout. The server is taking too long to respond.';
      default:
        if (statusCode >= 500) {
          return 'Server error ($statusCode). Please try again later.';
        } else if (statusCode >= 400) {
          return 'Client error ($statusCode). Please check your request.';
        } else {
          return 'An error occurred ($statusCode).';
        }
    }
  }

  /// Check if this is a server error (5xx status codes)
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if this is a client error (4xx status codes)
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Check if this is a network connectivity error
  bool get isConnectivityError =>
      errorType == DioExceptionType.connectionError ||
      errorType == DioExceptionType.connectionTimeout;

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException');
    buffer.write(': $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (errorType != null) {
      buffer.write(' [Type: $errorType]');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode &&
          errorType == other.errorType;

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode ^ errorType.hashCode;
}
