import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LNU Feedback System',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.feedback,
      routes: AppRoutes.routes,
    );
  }
}
