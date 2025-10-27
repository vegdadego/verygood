import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/task_cubit.dart';

/// Main page for displaying and managing tasks.
///
/// This page demonstrates the complete flow of the clean architecture:
/// 1. UI layer calls cubit methods
/// 2. Cubit uses use cases (business logic)
/// 3. Use cases interact with repository interfaces
/// 4. Repository implementations handle data sources
///
/// This separation ensures that UI, business logic, and data access
/// remain independent, making the code testable, maintainable, and scalable.
class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TaskCubit>().loadTasks(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TaskLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.tasks.length,
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.description),
                        trailing: Checkbox(
                          value: task.completed,
                          onChanged: (value) {
                            final updatedTask = task.copyWith(
                              completed: value ?? false,
                            );
                            context.read<TaskCubit>().updateTask(updatedTask);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<TaskCubit>().createTask(
                          title: 'New Task',
                          description: 'Task description',
                        );
                      },
                      child: const Text('Add Task'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.read<TaskCubit>().loadTasks(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            );
          }

          return const Center(child: Text('No tasks yet'));
        },
      ),
    );
  }
}
