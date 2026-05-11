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
    /// LOGIN
    adminLogin: (context) => const AdminLoginPage(),

    /// DASHBOARD (SAFE ARG HANDLING)
    adminDashboard: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;

      final email = args is String ? args : "admin@system.com";

      return AdminDashboardPage(
        adminEmail: email,
      );
    },

    /// MANAGE OFFICES
    manageOffices: (context) => const ManageOfficesPage(),

    /// SETTINGS (SAFE ARG HANDLING)
    adminSettings: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;

      final email = args is String ? args : "admin@system.com";

      return AdminSettingsPage(
        adminEmail: email,
      );
    },
  };
}