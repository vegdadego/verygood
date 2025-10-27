import 'package:smart_task_manager/app/app.dart';
import 'package:smart_task_manager/bootstrap.dart';

/// Development entry point for Smart Task Manager
///
/// This initializes the app with the development flavor.
Future<void> main() async {
  await bootstrap(() => const SmartTaskManagerApp());
}
