import 'package:flutter/material.dart';

import '../features/admin/pages/admin_login_page.dart';
import '../features/admin/pages/admin_dashboard_page.dart';
import '../features/admin/pages/manage_offices_page.dart';
import '../features/admin/pages/admin_settings_page.dart';

class AppRoutes {
  static const String adminLogin = "/admin-login";
  static const String adminDashboard = "/admin-dashboard";
  static const String manageOffices = "/manage-offices";
  static const String adminSettings = "/admin-settings";

  static Map<String, WidgetBuilder> routes = {
    adminLogin: (context) => const AdminLoginPage(),

    /// ✅ FIXED: receive email from login
    adminDashboard: (context) {
      final email =
          ModalRoute.of(context)!.settings.arguments as String;

      return AdminDashboardPage(
        adminEmail: email,
      );
    },

    manageOffices: (context) => const ManageOfficesPage(),

    /// ⚠️ Settings CANNOT be const anymore
    adminSettings: (context) {
      final email =
          ModalRoute.of(context)!.settings.arguments as String;

      return AdminSettingsPage(
        adminEmail: email,
      );
    },
  };
}