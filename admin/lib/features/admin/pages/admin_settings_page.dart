import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/theme_service.dart';
import '../widgets/admin_layout.dart';

class AdminSettingsPage extends StatefulWidget {
  final String? adminEmail; // ✅ FIXED: nullable safety

  const AdminSettingsPage({
    super.key,
    this.adminEmail,
  });

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  late final TextEditingController _emailController;

  final TextEditingController _displayNameController =
      TextEditingController(text: 'System Administrator');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedLanguage = 'English';

  final ThemeService _themeService = ThemeService();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // ✅ FIXED: null-safe email fallback
    _emailController = TextEditingController(
      text: widget.adminEmail ?? '',
    );

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
      final response = await ApiService.post(
        '/settings',
        body: {
          'settings': {
            'admin_email': _emailController.text.trim(),
            'display_name': _displayNameController.text.trim(),
            'language': _selectedLanguage,
            'dark_mode': _themeService.isDarkMode,
          },
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200
                ? 'Settings saved successfully.'
                : 'Failed to save settings.',
          ),
          backgroundColor: response.statusCode == 200
              ? null
              : const Color(0xFFB91C1C),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: "Settings",
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: _SettingsContent(
            emailController: _emailController,
            displayNameController: _displayNameController,
            selectedLanguage: _selectedLanguage,
            isDarkMode: _themeService.isDarkMode,
            isSaving: _isSaving,
            onLanguageChanged: (value) {
              setState(() => _selectedLanguage = value);
            },
            onDarkModeChanged: (value) {
              _themeService.setDarkMode(value);
            },
            onSave: _saveSettings,
          ),
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

                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                      .hasMatch(value.trim())) {
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
                  const Icon(Icons.language_outlined,
                      color: AppColors.lnuNavy),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("Language")),

                  DropdownButton<String>(
                    value: selectedLanguage,
                    items: const [
                      DropdownMenuItem(
                          value: "en", child: Text("English")),
                      DropdownMenuItem(
                          value: "tl", child: Text("Tagalog")),
                    ],
                    onChanged: (value) {
                      if (value != null) onLanguageChanged(value);
                    },
                  ),
                ],
              ),

              const Divider(),


              Row(
                children: [
                  const Expanded(child: Text("Dark Mode")),

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

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save Changes"),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lnuWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.lnuNavy),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
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
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}