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
    officeStore.fetchOffices();
  }

  @override
  void dispose() {
    officeStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final offices = officeStore.offices;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Container(
            width: 270,
            decoration: const BoxDecoration(
              color: AppColors.lnuNavy,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 84,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/images/lnu_logo.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Leyte Normal University",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Feedback System",
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _SidebarItem(
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
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    "OFFICES",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
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
                      final officeName = office['name'] as String;

                      return _SidebarItem(
                        title: officeName,
                        icon: Icons.apartment_outlined,
                        isActive: widget.pageTitle == officeName,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OfficePage(officeName: officeName),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                  child: Column(
                    children: [
                      Divider(
                        color: Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(height: 10),
                      _SidebarItem(
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
                    ],
                  ),
                ),
              ],
            ),
          ),
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

class _AdminHeader extends StatelessWidget {
  final String pageTitle;

  const _AdminHeader({required this.pageTitle});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text("Log out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textDark),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, AppRoutes.adminLogin);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Log out",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pageTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 52,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.lnuGold,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
          const Spacer(),
          _AdminMenuButton(
            onSettings: () {
              Navigator.pushReplacementNamed(context, AppRoutes.adminSettings);
            },
            onLogout: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

class _AdminMenuButton extends StatefulWidget {
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _AdminMenuButton({
    required this.onSettings,
    required this.onLogout,
  });

  @override
  State<_AdminMenuButton> createState() => _AdminMenuButtonState();
}

class _AdminMenuButtonState extends State<_AdminMenuButton> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isHoveringButton = false;
  bool _isHoveringMenu = false;

  static const double _menuWidth = 180;
  static const double _menuTopSpacing = 10;
  static const double _screenPadding = 12;

  void _showMenu() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final RenderBox overlayBox =
        overlay.context.findRenderObject() as RenderBox;
    final RenderBox buttonBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;

    final Size buttonSize = buttonBox.size;
    final Offset buttonPosition =
        buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);

    double left = buttonPosition.dx + buttonSize.width - _menuWidth;
    double top = buttonPosition.dy + buttonSize.height + _menuTopSpacing;

    final double maxLeft =
        overlayBox.size.width - _menuWidth - _screenPadding;

    if (left < _screenPadding) {
      left = _screenPadding;
    } else if (left > maxLeft) {
      left = maxLeft;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        width: _menuWidth,
        child: MouseRegion(
          onEnter: (_) {
            _isHoveringMenu = true;
          },
          onExit: (_) {
            _isHoveringMenu = false;
            _hideMenuIfNeeded();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    label: "Settings",
                    onTap: () {
                      _removeMenu();
                      widget.onSettings();
                    },
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border.withOpacity(0.8),
                  ),
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: "Log out",
                    isDestructive: true,
                    onTap: () {
                      _removeMenu();
                      widget.onLogout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _hideMenuIfNeeded() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_isHoveringButton && !_isHoveringMenu) {
        _removeMenu();
      }
    });
  }

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _isHoveringButton = true;
        _showMenu();
      },
      onExit: (_) {
        _isHoveringButton = false;
        _hideMenuIfNeeded();
      },
      child: Container(
        key: _buttonKey,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lnuWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFFFF7E0),
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.lnuGold,
              ),
            ),
            SizedBox(width: 8),
            Text(
              "Admin",
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? const Color(0xFFB91C1C)
        : AppColors.textDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hover
                ? (widget.isDestructive
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF9FAFB))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: color),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
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
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool highlight = widget.isActive || _isHovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppColors.lnuGold.withOpacity(0.16)
                  : _isHovering
                      ? Colors.white.withOpacity(0.08)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: widget.isActive
                  ? Border.all(
                      color: AppColors.lnuGold.withOpacity(0.55),
                      width: 1.2,
                    )
                  : _isHovering
                      ? Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1,
                        )
                      : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isActive
                      ? AppColors.lnuGold
                      : highlight
                          ? Colors.white
                          : Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: widget.isActive
                          ? FontWeight.bold
                          : _isHovering
                              ? FontWeight.w600
                              : FontWeight.w500,
                      fontSize: 14,
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