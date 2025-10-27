import 'package:smart_task_manager/app/app.dart';
import 'package:smart_task_manager/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
