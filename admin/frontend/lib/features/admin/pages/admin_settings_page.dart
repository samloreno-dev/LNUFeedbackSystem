import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/theme_service.dart';
import '../widgets/admin_layout.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final TextEditingController _emailController =
      TextEditingController(text: 'admin@DSB.com');

  final TextEditingController _displayNameController =
      TextEditingController(text: 'System Administrator');

  final _formKey = GlobalKey<FormState>();
  String _selectedLanguage = 'English';
  final ThemeService _themeService = ThemeService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_refresh);
  }

  @override
  void dispose() {
    _themeService.removeListener(_refresh);
    _emailController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await ApiService.post('/settings', body: {
        'settings': {
          'admin_email': _emailController.text.trim(),
          'display_name': _displayNameController.text.trim(),
          'language': _selectedLanguage,
          'dark_mode': _themeService.isDarkMode.toString(),
        },
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save settings.'),
              backgroundColor: Color(0xFFB91C1C),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: const Color(0xFFB91C1C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: "Settings",
      child: Form(
        key: _formKey,
        child: _SettingsContent(
          emailController: _emailController,
          displayNameController: _displayNameController,
          selectedLanguage: _selectedLanguage,
          isDarkMode: _themeService.isDarkMode,
          isSaving: _isSaving,
          onLanguageChanged: (value) {
            setState(() {
              _selectedLanguage = value;
            });
          },
          onDarkModeChanged: (value) {
            _themeService.setDarkMode(value);
          },
          onSave: _saveSettings,
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController displayNameController;
  final String selectedLanguage;
  final bool isDarkMode;
  final bool isSaving;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onSave;

  const _SettingsContent({
    required this.emailController,
    required this.displayNameController,
    required this.selectedLanguage,
    required this.isDarkMode,
    required this.isSaving,
    required this.onLanguageChanged,
    required this.onDarkModeChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsCard(
          title: "Account Settings",
          icon: Icons.person_outline,
          child: Column(
            children: [
              _OutlinedInputField(
                label: "Admin Email",
                icon: Icons.email_outlined,
                controller: emailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _OutlinedInputField(
                label: "Display Name",
                icon: Icons.person_outline,
                controller: displayNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Display name is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SettingsCard(
          title: "Display & Language",
          icon: Icons.palette_outlined,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.language_outlined,
                    color: AppColors.lnuNavy,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Language",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lnuWhite,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        borderRadius: BorderRadius.circular(12),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "English",
                            child: Text("English"),
                          ),
                          DropdownMenuItem(
                            value: "Filipino",
                            child: Text("Filipino"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            onLanguageChanged(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dark Mode",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Enable dark theme for dashboard",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: onDarkModeChanged,
                    activeColor: AppColors.lnuWhite,
                    activeTrackColor: AppColors.lnuNavy,
                    inactiveThumbColor: const Color(0xFF8F8A99),
                    inactiveTrackColor: const Color(0xFFE7E2EC),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(
              isSaving ? "Saving..." : "Save Changes",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lnuNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lnuWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: AppColors.lnuNavy, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _OutlinedInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _OutlinedInputField({
    required this.label,
    required this.icon,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.lnuWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF9CA3AF),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                icon,
                color: const Color(0xFF4B5563),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    errorStyle: TextStyle(height: 0.01, color: Colors.transparent),
                  ),
                  validator: validator,
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
        Positioned(
          left: 12,
          top: -9,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: AppColors.lnuWhite,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

