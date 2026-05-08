import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_user/main.dart';

void main() {
  testWidgets('User app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const UserApp());

    expect(find.byType(UserApp), findsOneWidget);
  });
}
