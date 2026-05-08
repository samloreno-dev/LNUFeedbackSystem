import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_admin/main.dart';
import 'package:frontend_admin/core/services/theme_service.dart';

void main() {
  testWidgets('Admin app builds', (WidgetTester tester) async {
    final themeService = ThemeService();

    await tester.pumpWidget(AdminApp(themeService: themeService));

    expect(find.byType(AdminApp), findsOneWidget);
  });
}

