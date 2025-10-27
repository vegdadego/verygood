import 'package:flutter/material.dart';
import '../../features/tasks/presentation/pages/task_list_page.dart';

/// Smart Task Manager App - Main application widget
///
/// This is the root widget of the application.
/// It sets up the Material app with a light theme and initializes the TaskListPage.
class SmartTaskManagerApp extends StatelessWidget {
  const SmartTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const TaskListPage(),
    );
  }
}

