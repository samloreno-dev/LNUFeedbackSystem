import 'package:flutter/material.dart';
import 'core/services/theme_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();

  await themeService.loadTheme();

  runApp(AdminApp(themeService: themeService));
}

class AdminApp extends StatelessWidget {
  const AdminApp({
    super.key,
    required this.themeService,
  });

  final ThemeService themeService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeService,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LNU Feedback System - Admin',

          themeMode: themeService.themeMode,

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,

            scaffoldBackgroundColor: const Color(0xFFF9FAFB),

            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B1464),
              secondary: Color(0xFFD4AF37),

              surface: Colors.white,

              onPrimary: Colors.white,
              onSecondary: Colors.white,
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,

            scaffoldBackgroundColor: const Color(0xFF0F172A),

            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              secondary: Color(0xFF1B1464),

              surface: Color(0xFF1E293B),

              onPrimary: Colors.white,
              onSecondary: Colors.white,
            ),
          ),

          initialRoute: AppRoutes.adminLogin,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}