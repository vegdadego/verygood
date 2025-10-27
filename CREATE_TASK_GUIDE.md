# CreateTaskPage - Implementation Guide

## Overview

The `CreateTaskPage` demonstrates modern Flutter UI best practices with:
- ✅ Form validation with TextFormField
- ✅ Loading states with CircularProgressIndicator  
- ✅ Error handling with SnackBar
- ✅ Clean, modern visual design
- ✅ Proper async state management with BLoC

---

## UI Features

### 1. **Modern Visual Design**

- **Soft shadows** for depth
- **Rounded corners** (12px radius)
- **Gradient backgrounds** (Colors.blue.shade50)
- **Floating snackbars** for messages
- **Clean spacing** and padding

### 2. **Form Validation**

```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter a task title';
  }
  if (value.trim().length < 3) {
    return 'Title must be at least 3 characters';
  }
  return null;
}
```

- **Real-time validation** as user types
- **Custom error messages** for different conditions
- **Prevents submission** until valid

### 3. **Loading State Management**

```dart
bool _isLoading = false;

// Set loading state
setState(() {
  _isLoading = true;
});

// Button shows loading indicator
_isLoading
    ? Row(
        children: [
          CircularProgressIndicator(...),
          Text('Creating...'),
        ],
      )
    : Row(
        children: [
          Icon(Icons.add_circle_outline),
          Text('Create Task'),
        ],
      )
```

### 4. **Success/Error Feedback**

**Success SnackBar:**
```dart
SnackBar(
  content: Row([
    Icon(Icons.check_circle),
    Text('Task created successfully!'),
  ]),
  backgroundColor: Colors.green.shade600,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
)
```

**Error SnackBar:**
```dart
SnackBar(
  content: Row([
    Icon(Icons.error),
    Text(error),
  ]),
  backgroundColor: Colors.red.shade600,
  duration: Duration(seconds: 4),
)
```

---

## Managing Async API Calls with BLoC

### How Async Management Works

**In CreateTaskPage:**

```dart
Future<void> _submitTask() async {
  // 1. Validate form
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // 2. Show loading
  setState(() => _isLoading = true);

  try {
    // 3. Call cubit method (async)
    await context.read<TaskCubit>().createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    // 4. Show success
    ScaffoldMessenger.of(context).showSnackBar(...);
    
    // 5. Navigate back
    Navigator.of(context).pop();
    
  } catch (e) {
    // 6. Handle error
    ScaffoldMessenger.of(context).showSnackBar(...);
  } finally {
    // 7. Hide loading
    setState(() => _isLoading = false);
  }
}
```

**Key Points:**
1. **Try-Catch Block**: Catches errors from async operations
2. **Loading State**: Set before/after the call
3. **UI Feedback**: Shows success/error messages
4. **Navigation**: Handles page navigation

---

## Using Riverpod (Alternative)

The project currently uses **BLoC**, but if you prefer **Riverpod**, here's how:

### 1. **Create a Riverpod Provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.watch(createTaskUseCaseProvider));
});
```

### 2. **Create a StateNotifier**

```dart
class TaskNotifier extends StateNotifier<TaskState> {
  final CreateTaskUseCase _createTaskUseCase;

  TaskNotifier(this._createTaskUseCase) : super(TaskInitial());

  Future<void> createTask({
    required String title,
    required String description,
  }) async {
    state = TaskLoading();
    
    try {
      await _createTaskUseCase(title: title, description: description);
      state = TaskSuccess();
    } catch (e) {
      state = TaskError(e.toString());
    }
  }
}
```

### 3. **Use in Widget**

```dart
class CreateTaskPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskNotifierProvider);
    final notifier = ref.read(taskNotifierProvider.notifier);

    return Scaffold(
      body: ElevatedButton(
        onPressed: () async {
          await notifier.createTask(
            title: 'Title',
            description: 'Description',
          );
          
          if (taskState is TaskSuccess) {
            // Navigate back
          }
        },
        child: taskState is TaskLoading
            ? CircularProgressIndicator()
            : Text('Create Task'),
      ),
    );
  }
}
```

### 4. **Wrap App with ProviderScope**

```dart
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

## BLoC vs Riverpod Comparison

### BLoC (Current Implementation)

**Pros:**
- ✅ Explicit state management
- ✅ Clear separation of concerns
- ✅ Built-in observer for debugging
- ✅ Mature ecosystem

**Cons:**
- ❌ More boilerplate
- ❌ Need BlocProvider and context.read

### Riverpod (Alternative)

**Pros:**
- ✅ Less boilerplate
- ✅ Built-in dependency injection
- ✅ Automatic rebuilds
- ✅ Type-safe providers

**Cons:**
- ❌ Different mental model
- ❌ Requires learning curve

---

## Integration Example

### 1. **Update Your Main App**

```dart
// lib/app/view/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_task_manager/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:smart_task_manager/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:smart_task_manager/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:smart_task_manager/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:smart_task_manager/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/task_list_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => TaskCubit(
          getTasksUseCase: GetTasksUseCase(/* inject repository */),
          createTaskUseCase: CreateTaskUseCase(/* inject repository */),
          updateTaskUseCase: UpdateTaskUseCase(/* inject repository */),
          deleteTaskUseCase: DeleteTaskUseCase(/* inject repository */),
        ),
        child: const TaskListPage(),
      ),
    );
  }
}
```

### 2. **Navigate to Create Page**

```dart
// In TaskListPage or any other page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider.value(
      value: BlocProvider.of<TaskCubit>(context),
      child: const CreateTaskPage(),
    ),
  ),
);
```

---

## Testing

### Mock the Cubit for Testing

```dart
class MockTaskCubit extends Mock implements TaskCubit {
  @override
  Future<void> createTask({
    required String title,
    required String description,
  }) => Future.value();
}

testWidgets('should show loading indicator when creating task', (tester) async {
  final mockCubit = MockTaskCubit();
  
  await tester.pumpWidget(
    BlocProvider<TaskCubit>.value(
      value: mockCubit,
      child: const CreateTaskPage(),
    ),
  );
  
  // Enter text
  await tester.enterText(find.byType(TextFormField).first, 'Test Title');
  await tester.enterText(find.byType(TextFormField).last, 'Test Description');
  
  // Tap submit
  await tester.tap(find.text('Create Task'));
  await tester.pump();
  
  // Verify loading indicator appears
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

---

## Key Takeaways

### 1. **Async Pattern**
```dart
try {
  await asyncOperation();
  showSuccess();
} catch (e) {
  showError(e);
}
```

### 2. **Loading State**
- Always show loading indicator during async operations
- Disable buttons to prevent multiple submissions
- Use `setState` to update UI

### 3. **Error Handling**
- Catch all errors
- Show user-friendly messages
- Don't expose technical details

### 4. **Navigation**
- Only navigate on success
- Use `mounted` check before navigation

---

## Summary

The `CreateTaskPage` demonstrates:
- ✅ **Modern Flutter UI** with clean design
- ✅ **Form validation** with real-time feedback
- ✅ **Loading states** with CircularProgressIndicator
- ✅ **Error handling** with SnackBar messages
- ✅ **Async management** with try-catch-finally pattern
- ✅ **BLoC integration** for state management

Ready to use! Just provide the TaskCubit via BlocProvider and navigate to the page.

