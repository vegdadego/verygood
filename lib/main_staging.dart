import 'package:smart_task_manager/app/app.dart';
import 'package:smart_task_manager/bootstrap.dart';

/// Staging entry point for Smart Task Manager
Future<void> main() async {
  await bootstrap(() => const SmartTaskManagerApp());
}
