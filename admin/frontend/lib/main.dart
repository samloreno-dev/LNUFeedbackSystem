import 'package:flutter/material.dart';
import 'core/services/theme_service.dart';
import 'routes/app_routes.dart';

void main() {
  final themeService = ThemeService();
  themeService.loadTheme();
  runApp(const AdminApp());
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LNU Feedback System - Admin',
      themeMode: _themeService.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1B1464),
          secondary: Color(0xFFD4AF37),
          surface: Colors.white,
          background: Color(0xFFF9FAFB),
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
          background: Color(0xFF0F172A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
      ),
      initialRoute: AppRoutes.adminLogin,
      routes: AppRoutes.routes,
    );
  }
}

