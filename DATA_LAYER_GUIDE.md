# Data Layer Implementation Guide

## Overview

The data layer for the Tasks feature has been implemented using **Freezed** and **json_serializable** for type-safe JSON serialization. This guide explains how the repository pattern isolates the UI from data sources.

---

## Architecture Components

### 1. Task Model (`lib/features/tasks/data/models/task_model.dart`)

**What it is:**
- Data Transfer Object (DTO) with JSON serialization
- Uses Freezed for immutability and code generation
- Uses json_serializable for automatic JSON conversion

**Key Features:**
```dart
@Freezed(toJson: true, fromJson: true)
class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    required bool completed,
  }) = _TaskModel;

  // Automatic JSON conversion
  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  // Map to domain entity
  Task toEntity() { ... }

  // Map from domain entity
  factory TaskModel.fromEntity(Task task) { ... }
}
```

**Benefits:**
- ✅ **Immutability**: All properties are final
- ✅ **Type Safety**: Compile-time JSON schema validation
- ✅ **Code Generation**: Automatic `copyWith`, `==`, `hashCode`, `toString`
- ✅ **JSON Conversion**: Automatic `fromJson`/`toJson` methods

---

### 2. Remote Data Source (`lib/features/tasks/data/datasources/task_remote_datasource.dart`)

**What it does:**
- Performs HTTP requests using DioClient
- Handles JSON serialization/deserialization
- Catches and converts errors to NetworkException

**Methods:**
```dart
class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks() { ... }
  Future<TaskModel> getTaskById(String id) { ... }
  Future<TaskModel> createTask(TaskModel task) { ... }
  Future<TaskModel> updateTask(TaskModel task) { ... }
  Future<void> deleteTask(String id) { ... }
}
```

**Implementation Notes:**
- Uses DioClient singleton for centralized HTTP client
- All methods return `TaskModel` (data layer)
- Errors are automatically converted to NetworkException
- JSON serialization happens automatically

---

### 3. Repository Implementation (`lib/features/tasks/data/repositories/task_repository_impl.dart`)

**What it does:**
- **Maps between data and domain layers**
- Implements the domain repository interface
- Provides a clean abstraction for business logic

**Key Responsibility - Model-to-Entity Mapping:**

```dart
// Domain layer works with Task (entity)
// Data layer works with TaskModel (model)

// Converting from API to domain
Future<List<Task>> getTasks() async {
  final taskModels = await _remoteDataSource.getTasks();
  return taskModels.map((model) => model.toEntity()).toList();
  // ↑ TaskModel          ↑ Task
}

// Converting from domain to API
Future<Task> createTask(Task task) async {
  final taskModel = TaskModel.fromEntity(task);  // Domain → Data
  final createdModel = await _remoteDataSource.createTask(taskModel);
  return createdModel.toEntity();                // Data → Domain
}
```

---

## How the Repository Isolates UI from Data Sources

### 1. **Abstraction Layer**

**The repository creates an abstraction between the UI and data sources:**

```
┌─────────────────────────────────────────────┐
│           UI / Presentation Layer            │
│  (Widgets, Cubits, State Management)       │
│                                              │
│  "I need all tasks"                          │
└───────────────────┬──────────────────────────┘
                    │
                    │ Calls: repository.getTasks()
                    │
┌───────────────────┴──────────────────────────┐
│           Repository (Abstraction)           │
│  - Converts data models to entities          │
│  - Handles data source coordination          │
│  - Provides clean interface to domain        │
└───────────────────┬──────────────────────────┘
                    │
                    │ Does NOT expose:
                    │ - HTTP implementation details
                    │ - JSON serialization
                    │ - Network errors
                    │
┌───────────────────┴──────────────────────────┐
│           Data Source Layer                 │
│  - Makes HTTP requests                       │
│  - Handles JSON serialization                │
│  - Converts errors                           │
└──────────────────────────────────────────────┘
```

---

### 2. **The UI Doesn't Know About HTTP**

**Without Repository Pattern:**
```dart
// ❌ BAD: UI directly depends on HTTP implementation
class TaskCubit extends Cubit<TaskState> {
  final Dio _dio;  // UI knows about Dio!

  Future<void> loadTasks() async {
    final response = await _dio.get('/posts');
    final json = response.data;
    // Complex JSON parsing logic in UI layer!
  }
}
```

**With Repository Pattern:**
```dart
// ✅ GOOD: UI only knows about domain entities
class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase _useCase;  // Clean!

  Future<void> loadTasks() async {
    final tasks = await _useCase();
    // Simple, clean, no HTTP knowledge
  }
}
```

---

### 3. **Data Sources Can Be Swapped**

**The repository allows changing data sources without affecting UI:**

**Using API:**
```dart
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  // Uses HTTP API
}
```

**Using Local Database:**
```dart
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;
  // Uses SQLite, SharedPreferences, etc.
}
```

**Using Cache:**
```dart
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  
  Future<List<Task>> getTasks() async {
    // Try cache first, then API
    try {
      return await _localDataSource.getTasks();
    } catch (e) {
      final tasks = await _remoteDataSource.getTasks();
      await _localDataSource.saveTasks(tasks);
      return tasks;
    }
  }
}
```

**The UI doesn't need to know which data source is used!**

---

### 4. **Error Handling Abstraction**

**The repository converts technical errors to domain errors:**

```dart
// Data layer throws: NetworkException
// UI receives: Clean error messages

// Repository converts:
try {
  await _remoteDataSource.getTasks();
} catch (e) {
  // Network error → user-friendly message
  throw RepositoryException('Unable to fetch tasks');
}
```

---

### 5. **Testing Benefits**

**Easy to mock for testing:**

```dart
// In tests, create a mock repository
class MockTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getTasks() async {
    return [
      Task(id: '1', title: 'Test', description: 'Test', completed: false),
    ];
  }
}

// Use it in tests
final cubit = TaskCubit(
  getTasksUseCase: GetTasksUseCase(MockTaskRepository()),
);

// Test without making real HTTP requests!
```

---

## Data Flow Example

**Creating a Task:**

```
1. User inputs title and description
   ↓
2. TaskCubit.createTask(title, description)
   ↓
3. CreateTaskUseCase.call()
   - Creates Task entity
   - Generates ID
   ↓
4. TaskRepository.createTask(entity)
   ↓
5. TaskRepositoryImpl.createTask(entity)
   - Converts Task → TaskModel (fromEntity)
   ↓
6. TaskRemoteDataSource.createTask(model)
   - Converts TaskModel → JSON
   - Makes HTTP POST request
   ↓
7. Server responds with JSON
   ↓
8. Response JSON → TaskModel (fromJson)
   ↓
9. TaskModel → Task entity (toEntity)
   ↓
10. Returns to UI as Task entity
```

**Key Point:** The UI only deals with `Task` entities, never with:
- JSON
- HTTP requests
- Network errors (handled automatically)
- Data source implementations

---

## Benefits for Scalability

| Benefit | Description |
|---------|-------------|
| **Flexibility** | Change data sources without UI changes |
| **Testability** | Mock repositories for easy testing |
| **Maintainability** | Clear separation of concerns |
| **Type Safety** | Compile-time validation with Freezed |
| **Error Handling** | Centralized, consistent error processing |
| **Code Reuse** | Repository can be used by multiple features |

---

## Code Examples

### Using the Repository

```dart
// In your cubit or use case
class TaskCubit extends Cubit<TaskState> {
  final CreateTaskUseCase _createTaskUseCase;

  Future<void> createTask({
    required String title,
    required String description,
  }) async {
    try {
      // The use case handles:
      // 1. Creating the Task entity
      // 2. Calling repository
      // 3. Repository converts to model
      // 4. Data source makes HTTP request
      // 5. Response converted back to entity
      final task = await _createTaskUseCase(title: title, description: description);
      
      // UI receives clean Task entity
      emit(TaskLoaded([...currentTasks, task]));
    } catch (e) {
      // Clean error handling
      emit(TaskError(e.message));
    }
  }
}
```

### Repository Internals

```dart
// Repository handles the conversion
class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<List<Task>> getTasks() async {
    // 1. Get data from remote source (TaskModel)
    final taskModels = await _remoteDataSource.getTasks();
    
    // 2. Convert models to entities
    return taskModels.map((model) => model.toEntity()).toList();
    
    // UI receives List<Task>, not List<TaskModel>
  }
}
```

---

## Freezed Benefits

**Automatic Code Generation:**
```dart
// Automatically generated:
- copyWith() method
- equality operator (==)
- hashCode
- toString()
- freezed_union support
- pattern matching

// Example usage:
final task1 = const TaskModel(
  id: '1',
  title: 'Task',
  description: 'Desc',
  completed: false,
);

final task2 = task1.copyWith(completed: true);
// task2 is a new immutable instance with updated completed

final isEqual = task1 == task2;  // Automatically generated
```

---

## Summary

**The repository pattern provides:**

1. ✅ **Clean Separation**: UI doesn't know about HTTP/JSON
2. ✅ **Testability**: Easy to mock for tests
3. ✅ **Flexibility**: Can swap data sources
4. ✅ **Type Safety**: Freezed ensures immutability and type safety
5. ✅ **Error Handling**: Centralized, consistent error processing
6. ✅ **Maintainability**: Changes in data layer don't affect UI
7. ✅ **Scalability**: Easy to add new data sources or features

**The data layer is now production-ready with:**
- ✅ TaskModel with Freezed and json_serializable
- ✅ RemoteDataSource using DioClient
- ✅ Repository implementation with proper mapping
- ✅ Full separation of concerns
- ✅ Type-safe JSON serialization

---

## Next Steps

1. ✅ Data layer implemented
2. ⏭️ Wire up dependency injection
3. ⏭️ Integrate with presentation layer
4. ⏭️ Add local caching for offline support
5. ⏭️ Write unit tests

