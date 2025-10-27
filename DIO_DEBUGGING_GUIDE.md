# Dio POST Request Debugging Guide

## Current Configuration Analysis

### DioClient Setup
```dart
baseUrl: 'https://jsonplaceholder.typicode.com'
Content-Type: 'application/json'
Accept: 'application/json'
```

### TaskRemoteDataSource POST Implementation
```dart
Future<TaskModel> createTask(TaskModel task) async {
  try {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.getTasksEndpoint(), // '/posts'
      data: task.toJson(),
    );
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  } on NetworkException {
    rethrow;
  } catch (e) {
    throw NetworkException('Failed to create task: ${e.toString()}', null);
  }
}
```

---

## Common Dio POST Issues & Solutions

### Issue 1: JSON Serialization Error

**Error:** `type '(int, String)' is not a subtype of type 'Map<String, dynamic>'`

**Cause:** Freezed-generated `toJson()` might not be working correctly with `@Freezed(toJson: true, fromJson: true)`

**Solution:** Ensure proper JSON serialization

```dart
// Add explicit JSON serialization
@override
Map<String, dynamic> toJson() => {
  'id': id,
  'title': title,
  'description': description,
  'completed': completed,
};
```

**Fix:**
1. Check if `task_model.g.dart` is generated properly
2. Run: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Ensure `toJson()` method exists in generated files

---

### Issue 2: Content-Type Header Problem

**Error:** `FormatException: Invalid JSON`

**Cause:** Server expects JSON but receives form-data

**Solution:** Ensure Dio sends JSON correctly

```dart
// In DioClient, ensure proper JSON encoding
_dio.options.headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

// Or use a custom transformer
final transformer = BackgroundTransformer()..jsonDecodeCallback = parseJson;
_dio.transformer = transformer;
```

---

### Issue 3: Null Response Data

**Error:** `NullPointerException: response.data is null`

**Cause:** JSONPlaceholder returns the created object directly

**Solution:** Handle null data properly

```dart
Future<TaskModel> createTask(TaskModel task) async {
  try {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.getTasksEndpoint(),
      data: task.toJson(),
    );
    
    // Handle null response
    if (response.data == null) {
      throw NetworkException('Server returned null response', response.statusCode);
    }
    
    return TaskModel.fromJson(response.data!);
  } on NetworkException {
    rethrow;
  } catch (e) {
    throw NetworkException('Failed to create task: ${e.toString()}', null);
  }
}
```

---

### Issue 4: TaskModel.toJson() Not Working

**Error:** `toJson() not found` or similar

**Cause:** Generated code not building properly

**Fix:**

```bash
# Clean build
flutter clean
flutter pub get

# Rebuild code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Verify generated files exist
ls lib/features/tasks/data/models/task_model.g.dart
ls lib/features/tasks/data/models/task_model.freezed.dart
```

---

### Issue 5: JSON Format Mismatch

**Error:** API returns unexpected format

**Solution:** Check actual JSON response

```dart
// Add debugging to see actual response
final response = await _dioClient.post<dynamic>(
  ApiConstants.getTasksEndpoint(),
  data: task.toJson(),
);

print('Response status: ${response.statusCode}');
print('Response data: ${response.data}');
print('Response data type: ${response.data.runtimeType}');

// Then convert appropriately
final Map<String, dynamic> jsonData = response.data as Map<String, dynamic>;
return TaskModel.fromJson(jsonData);
```

---

## Proactive Debugging Checklist

### ✅ Before Making POST Requests

**1. Verify TaskModel.toJson() Works**
```dart
void test() {
  final task = const TaskModel(
    id: '1',
    title: 'Test',
    description: 'Test desc',
    completed: false,
  );
  
  print(task.toJson()); // Should print: {id: 1, title: Test, ...}
  
  // Verify it can be re-parsed
  final json = task.toJson();
  final recreated = TaskModel.fromJson(json);
  print(recreated); // Should match original
}
```

**2. Check DioClient Configuration**
```dart
final dioClient = DioClient();
print('Base URL: ${dioClient.instance.options.baseUrl}');
print('Headers: ${dioClient.instance.options.headers}');
```

**3. Enable Network Logging**
- Check console for request/response logs
- Verify request body matches expected format
- Verify Content-Type header is sent correctly

**4. Test with Simple Data First**
```dart
// Test with hardcoded data
final testJson = {'title': 'Test', 'body': 'Test desc', 'userId': 1};
final response = await dioClient.post('/posts', data: testJson);
print('Success: ${response.data}');
```

**5. Verify API Endpoint**
```dart
// Test endpoint directly
final response = await dioClient.get('/posts');
if (response.statusCode == 200) {
  print('API is accessible');
}
```

---

### ✅ During Development

**1. Use Interceptor Logging**
```dart
// Already implemented in _LoggingInterceptor
// Check console for:
// - Request method, URI, body
// - Response status, data
// - Error details
```

**2. Add Temporary Debugging**
```dart
Future<TaskModel> createTask(TaskModel task) async {
  print('🔍 Creating task: ${task.toJson()}');
  
  try {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.getTasksEndpoint(),
      data: task.toJson(),
    );
    
    print('✅ Success: ${response.data}');
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  } catch (e, stack) {
    print('❌ Error: $e');
    print('Stack: $stack');
    rethrow;
  }
}
```

**3. Test JSON Serialization**
```dart
// Add unit test
test('TaskModel serialization', () {
  final task = const TaskModel(
    id: '1',
    title: 'Test',
    description: 'Desc',
    completed: false,
  );
  
  final json = task.toJson();
  expect(json, isA<Map<String, dynamic>>());
  expect(json['id'], '1');
  
  final recreated = TaskModel.fromJson(json);
  expect(recreated.id, task.id);
});
```

**4. Monitor Network Traffic**
- Use browser DevTools for web
- Use Charles/Fiddler for mobile
- Check server logs

---

## Tests to Prevent Issues

### 1. **Unit Test: TaskModel Serialization**

```dart
// test/features/tasks/data/models/task_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';

void main() {
  group('TaskModel', () {
    test('toJson converts to Map correctly', () {
      final task = const TaskModel(
        id: '123',
        title: 'Test Task',
        description: 'Test Description',
        completed: false,
      );

      final json = task.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['id'], '123');
      expect(json['title'], 'Test Task');
      expect(json['description'], 'Test Description');
      expect(json['completed'], false);
    });

    test('fromJson creates TaskModel correctly', () {
      final json = {
        'id': '123',
        'title': 'Test Task',
        'description': 'Test Description',
        'completed': false,
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, '123');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.completed, false);
    });

    test('toJson and fromJson are symmetric', () {
      final original = const TaskModel(
        id: '123',
        title: 'Test',
        description: 'Desc',
        completed: true,
      );

      final json = original.toJson();
      final recreated = TaskModel.fromJson(json);

      expect(recreated.id, original.id);
      expect(recreated.title, original.title);
      expect(recreated.description, original.description);
      expect(recreated.completed, original.completed);
    });
  });
}
```

### 2. **Unit Test: RemoteDataSource**

```dart
// test/features/tasks/data/datasources/task_remote_datasource_test.dart
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_task_manager/core/network/dio_client.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';
import 'package:test/test.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late TaskRemoteDataSource dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = TaskRemoteDataSource();
  });

  group('createTask', () {
    final task = const TaskModel(
      id: '123',
      title: 'Test Task',
      description: 'Test Description',
      completed: false,
    );

    test('should create task successfully', () async {
      // Arrange
      when(() => mockDioClient.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: task.toJson(),
          statusCode: 201,
        ),
      );

      // Act
      final result = await dataSource.createTask(task);

      // Assert
      expect(result.id, task.id);
      expect(result.title, task.title);
      verify(() => mockDioClient.post<Map<String, dynamic>>(
            any(),
            data: task.toJson(),
          )).called(1);
    });

    test('should throw NetworkException on error', () async {
      // Arrange
      when(() => mockDioClient.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => dataSource.createTask(task),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

### 3. **Integration Test: Full Flow**

```dart
// test/features/tasks/data/repositories/task_repository_impl_test.dart
import 'package:mocktail/mocktail.dart';
import 'package:smart_task_manager/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';
import 'package:smart_task_manager/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:test/test.dart';

class MockRemoteDataSource extends Mock implements TaskRemoteDataSource {}

void main() {
  late TaskRepositoryImpl repository;
  late MockRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockRemoteDataSource();
    repository = TaskRepositoryImpl(mockDataSource);
  });

  test('createTask maps correctly from entity to model and back', () async {
    // Arrange
    final task = const TaskModel(
      id: '123',
      title: 'Test',
      description: 'Desc',
      completed: false,
    );

    when(() => mockDataSource.createTask(any()))
        .thenAnswer((_) async => task);

    // Act
    final result = await repository.createTask(task.toEntity());

    // Assert
    expect(result.id, '123');
    verify(() => mockDataSource.createTask(any())).called(1);
  });
}
```

### 4. **Widget Test: Error Handling**

```dart
// test/features/tasks/presentation/pages/create_task_page_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_task_manager/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/create_task_page.dart';

class MockTaskCubit extends MockCubit<TaskState> implements TaskCubit {}

void main() {
  testWidgets('CreateTaskPage shows error on failed creation', (tester) async {
    // Arrange
    final mockCubit = MockTaskCubit();
    when(() => mockCubit.createTask(
          title: any(named: 'title'),
          description: any(named: 'description'),
        )).thenThrow(Exception('Network error'));

    // Act
    await tester.pumpWidget(
      BlocProvider<TaskCubit>.value(
        value: mockCubit,
        child: MaterialApp(home: CreateTaskPage()),
      ),
    );

    // Enter data
    await tester.enterText(find.byType(TextFormField).first, 'Test Title');
    await tester.enterText(find.byType(TextFormField).last, 'Test Desc');
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.textContaining('error'), findsOneWidget);
  });
}
```

---

## Quick Fix Recommendations

### Immediate Actions

1. **Verify Code Generation**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

2. **Add Null Safety Check**
```dart
final response = await _dioClient.post<dynamic>(
  ApiConstants.getTasksEndpoint(),
  data: task.toJson(),
);

if (response.data == null) {
  throw NetworkException('Server returned null', response.statusCode);
}

final jsonData = response.data as Map<String, dynamic>;
return TaskModel.fromJson(jsonData);
```

3. **Enable Extended Logging**
```dart
// Already implemented in _LoggingInterceptor
// Check console output for detailed request/response
```

---

## Summary Checklist

Before committing changes:

✅ Run code generation: `flutter pub run build_runner build`
✅ Write unit tests for serialization
✅ Write integration tests for data flow
✅ Test with real API if possible
✅ Check console logs for errors
✅ Verify TaskModel.toJson() works
✅ Test error handling paths
✅ Verify network status codes

---

## Getting Help

If the error persists:
1. Share the full error message and stack trace
2. Share the console output from the logging interceptor
3. Share the TaskModel.toJson() output
4. Share the actual server response

This will help identify the specific issue quickly.

