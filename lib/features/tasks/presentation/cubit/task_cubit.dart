import 'package:bloc/bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';

/// State class for task management
sealed class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);
}

/// Cubit for managing task state and operations.
///
/// This cubit handles all task-related business logic in the presentation layer.
/// It coordinates between use cases and manages the UI state. By separating
/// state management from widgets, we make the code more testable and maintainable.
/// The cubit pattern provides a simple, powerful way to manage application state.
class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  TaskCubit({
    required GetTasksUseCase getTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _createTaskUseCase = createTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(TaskInitial());

  /// Fetch all tasks
  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await _getTasksUseCase();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks: ${e.toString()}'));
    }
  }

  /// Create a new task
  Future<void> createTask({
    required String title,
    required String description,
  }) async {
    try {
      await _createTaskUseCase(title: title, description: description);
      await loadTasks(); // Reload tasks to reflect the new task
    } catch (e) {
      emit(TaskError('Failed to create task: ${e.toString()}'));
    }
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _updateTaskUseCase(task);
      await loadTasks(); // Reload tasks to reflect changes
    } catch (e) {
      emit(TaskError('Failed to update task: ${e.toString()}'));
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _deleteTaskUseCase(id);
      await loadTasks(); // Reload tasks to reflect deletion
    } catch (e) {
      emit(TaskError('Failed to delete task: ${e.toString()}'));
    }
  }
}

