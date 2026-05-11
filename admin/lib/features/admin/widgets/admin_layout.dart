import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../pages/office_page.dart';
import '../services/office_store.dart';

class AdminLayout extends StatefulWidget {
  final String pageTitle;
  final Widget child;

  const AdminLayout({
    super.key,
    required this.pageTitle,
    required this.child,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final OfficeStore officeStore = OfficeStore();

  @override
  void initState() {
    super.initState();

    officeStore.addListener(_refresh);

    Future.microtask(() async {
      await officeStore.fetchOffices();
    });
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    officeStore.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offices = officeStore.offices;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 270,
            color: AppColors.lnuNavy,
            child: Column(
              children: [
                Container(
                  height: 84,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/lnu_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leyte Normal University',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Feedback System',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _SidebarItem(
                  title: "Main Dashboard",
                  icon: Icons.dashboard_outlined,
                  isActive: widget.pageTitle == "Main Dashboard",
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.adminDashboard,
                    );
                  },
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "OFFICES",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: offices.length,
                    itemBuilder: (context, index) {
                      final office = offices[index];
                      final officeName = office['name'].toString();

                      return _SidebarItem(
                        title: officeName,
                        icon: Icons.apartment_outlined,
                        isActive: widget.pageTitle == officeName,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OfficePage(
                                officeName: officeName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: _SidebarItem(
                    title: "Manage Offices",
                    icon: Icons.settings_outlined,
                    isActive: widget.pageTitle == "Manage Offices",
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.manageOffices,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                _AdminHeader(pageTitle: widget.pageTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// HEADER
class _AdminHeader extends StatelessWidget {
  final String pageTitle;

  const _AdminHeader({required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.lnuWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'settings') {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.adminSettings,
                );
              }

              if (value == 'logout') {
                await AuthService.logout();

                if (!context.mounted) return;

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.adminLogin,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 10),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 18),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Admin',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SIDEBAR ITEM
class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.lnuGold.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.lnuGold : Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}