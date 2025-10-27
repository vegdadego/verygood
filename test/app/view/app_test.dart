import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/app/app.dart';
import 'package:smart_task_manager/features/tasks/presentation/pages/task_list_page.dart';

void main() {
  group('SmartTaskManagerApp', () {
    testWidgets('renders TaskListPage', (tester) async {
      await tester.pumpWidget(const SmartTaskManagerApp());
      expect(find.byType(TaskListPage), findsOneWidget);
    });
  });
}
