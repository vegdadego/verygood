# Networking Layer Implementation Guide

## Overview

This guide explains how to use the implemented networking layer in Smart Task Manager. The networking layer consists of two main components:

1. **DioClient** - Centralized HTTP client with interceptors
2. **NetworkException** - Custom error handling

---

## Implementation Status

✅ **Implemented and Ready to Use**

- `lib/core/network/dio_client.dart` - Configured with JSONPlaceholder API
- `lib/core/network/network_exceptions.dart` - Complete error handling
- `lib/core/constants/api_constants.dart` - API endpoints

---

## Features

### DioClient Features

1. **Singleton Pattern** - Single instance across the app
2. **Custom Logging** - Detailed request/response logs
3. **Error Handling** - Automatic error conversion
4. **Helper Methods** - GET, POST, PUT, DELETE
5. **Type Safety** - Generic type support

### NetworkException Features

1. **User-Friendly Messages** - Technical errors converted to readable text
2. **Status Code Mapping** - Specific messages for each HTTP status
3. **Error Classification** - Helper properties to check error types
4. **Comprehensive Coverage** - Handles all Dio error types

---

## Usage Examples

### Basic GET Request

```dart
import 'package:smart_task_manager/core/network/dio_client.dart';

final dioClient = DioClient();

// Fetch all tasks (posts from JSONPlaceholder)
try {
  final response = await dioClient.get<List<dynamic>>('/posts');
  final tasks = response.data ?? [];
  print('Received ${tasks.length} tasks');
} on NetworkException catch (e) {
  print('Error: ${e.message}');
}
```

### POST Request

```dart
// Create a new task
try {
  final newTask = {
    'title': 'Complete project',
    'body': 'Finish the Smart Task Manager app',
    'userId': 1,
  };
  
  final response = await dioClient.post<Map<String, dynamic>>(
    '/posts',
    data: newTask,
  );
  
  print('Created task: ${response.data}');
} on NetworkException catch (e) {
  if (e.isClientError) {
    print('Client error: ${e.message}');
  }
}
```

### Error Handling

```dart
try {
  final response = await dioClient.get('/posts/1');
} on NetworkException catch (e) {
  // Check error type
  if (e.isServerError) {
    // 5xx errors - server issues
    showError('Server error occurred. Please try again later.');
  } else if (e.isClientError) {
    // 4xx errors - client issues
    showError('${e.message}');
  } else if (e.isConnectivityError) {
    // Network connectivity issues
    showError('No internet connection.');
  } else {
    showError(e.message);
  }
}
```

---

## Why Interceptors are Essential

### 1. **Logging Interceptor**

**What it does:**
- Logs all requests with method, URI, query parameters, and body
- Logs all responses with status code and data
- Logs errors with full context

**Example Output:**
```
┌─────────────────────────────────────────────────────────────
│ 📤 REQUEST
│ GET → https://jsonplaceholder.typicode.com/posts
│ Query Parameters: {}
│ Body: null
└─────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────
│ 📥 RESPONSE
│ GET 200
│ URI: https://jsonplaceholder.typicode.com/posts
│ Data: [{id: 1, title: ...}]
└─────────────────────────────────────────────────────────────
```

**Why it's useful:**
- **Development**: See exactly what's being sent/received
- **Debugging**: Identify issues quickly without external tools
- **Testing**: Verify API calls in unit tests

### 2. **Error Interceptor**

**What it does:**
- Centralizes error handling
- Converts Dio errors to NetworkException
- Provides consistent error format

**Example:**
```dart
// Without interceptor: Technical error
catch (e) {
  print('DioException: ${e.runtimeType}');
}

// With interceptor: User-friendly
catch (e) {
  print('Error: Connection timeout. Please check your internet connection.');
}
```

**Why it's useful:**
- **Consistency**: Same error format across the app
- **Usability**: Users get meaningful messages
- **Maintainability**: Change error messages in one place

### 3. **Potential: Authentication Interceptor**

**Example implementation:**
```dart
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Automatically add auth token to all requests
    final token = getStoredToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 errors - refresh token
    if (err.response?.statusCode == 401) {
      refreshToken().then((newToken) {
        // Retry request with new token
      });
    }
    handler.next(err);
  }
}
```

**Why it's useful:**
- **Security**: Centralized token management
- **Simplicity**: No manual token handling in every request
- **Reliability**: Automatic token refresh

---

## Integration with Clean Architecture

### Data Layer Usage

```dart
// lib/features/tasks/data/datasources/task_remote_datasource.dart
import '../../../../core/network/dio_client.dart';

class TaskRemoteDataSource {
  final DioClient _dioClient;
  
  TaskRemoteDataSource() : _dioClient = DioClient();
  
  Future<List<TaskModel>> getTasks() async {
    final response = await _dioClient.get<List<dynamic>>('/posts');
    final tasksJson = response.data ?? [];
    return tasksJson
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
```

---

## Testing with Interceptors

### Mock the DioClient

```dart
class MockDioClient extends DioClient {
  late final List<Response> mockResponses;
  
  @override
  Future<Response<T>> get<T>(String path, {...}) async {
    // Return mock data for testing
    if (mockResponses.isNotEmpty) {
      return mockResponses.removeAt(0) as Response<T>;
    }
    throw NetworkException('No mock response configured');
  }
}
```

### Test Without Real Network Calls

```dart
void main() {
  test('should fetch tasks successfully', () async {
    // Arrange
    final mockClient = MockDioClient();
    mockClient.mockResponses = [
      Response(
        requestOptions: RequestOptions(path: '/posts'),
        data: [{'id': 1, 'title': 'Test'}],
        statusCode: 200,
      ),
    ];
    
    // Act
    final response = await mockClient.get('/posts');
    
    // Assert
    expect(response.statusCode, 200);
    expect(response.data, isNotNull);
  });
}
```

---

## Benefits for Scalability

| Feature | Benefit |
|---------|---------|
| **Singleton Pattern** | Single configuration point for entire app |
| **Interceptors** | Add features without changing existing code |
| **Error Handling** | Consistent error messages across app |
| **Type Safety** | Compile-time error detection |
| **Testability** | Easy to mock and test |
| **Maintainability** | Change network behavior in one place |

---

## Configuration

### Base URL

Currently configured to: `https://jsonplaceholder.typicode.com`

To change:
```dart
_dio.options.baseUrl = 'https://your-api.com';
```

### Timeouts

Currently set to: 30 seconds for all timeouts

To customize:
```dart
connectTimeout: const Duration(seconds: 60),
receiveTimeout: const Duration(seconds: 60),
sendTimeout: const Duration(seconds: 60),
```

### Headers

Default headers:
- `Content-Type: application/json`
- `Accept: application/json`

To add custom headers:
```dart
headers: {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Custom-Header': 'value',
}
```

---

## Best Practices

### 1. Always Use Error Handling

```dart
// ❌ Bad
final response = await dioClient.get('/posts');

// ✅ Good
try {
  final response = await dioClient.get('/posts');
  // Process response
} on NetworkException catch (e) {
  // Handle error
}
```

### 2. Use Type Parameters

```dart
// ❌ Bad
final response = await dioClient.get('/posts');

// ✅ Good
final response = await dioClient.get<List<dynamic>>('/posts');
```

### 3. Check Error Types

```dart
// ✅ Best practice
if (e.isServerError) {
  // Show generic error to user
} else if (e.isClientError) {
  // Show specific client error
} else if (e.isConnectivityError) {
  // Show connectivity message
}
```

---

## Next Steps

1. ✅ Networking layer implemented
2. ⏭️ Integrate with data layer
3. ⏭️ Add authentication
4. ⏭️ Implement caching
5. ⏭️ Add retry logic
6. ⏭️ Write unit tests

---

## Summary

The networking layer is **fully implemented and production-ready** with:

- ✅ Dio client with JSONPlaceholder API
- ✅ Custom interceptors for logging and error handling
- ✅ Comprehensive error handling with user-friendly messages
- ✅ Singleton pattern for centralized configuration
- ✅ Helper methods for common operations
- ✅ Modern Dart best practices (null safety, type safety)

**Ready to use** in your data layer implementations!

