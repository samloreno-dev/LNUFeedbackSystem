import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/office_store.dart';
import '../widgets/admin_layout.dart';

class ManageOfficesPage extends StatefulWidget {
  const ManageOfficesPage({super.key});

  @override
  State<ManageOfficesPage> createState() => _ManageOfficesPageState();
}

class _ManageOfficesPageState extends State<ManageOfficesPage> {
  final OfficeStore officeStore = OfficeStore();

  @override
  void initState() {
    super.initState();
    officeStore.addListener(_refresh);
  }

  @override
  void dispose() {
    officeStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showAddOfficeModal() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Office"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Office Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final officeName = controller.text.trim();
              if (officeName.isNotEmpty) {
                final success = await officeStore.addOffice(officeName);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Office added successfully' : 'Failed to add office'),
                      backgroundColor: success ? const Color(0xFF166534) : const Color(0xFFB91C1C),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lnuNavy,
            ),
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditOfficeModal(String currentOffice) {
    final controller = TextEditingController(text: currentOffice);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Office"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Office Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newOfficeName = controller.text.trim();
              if (newOfficeName.isNotEmpty) {
                final success = await officeStore.updateOffice(currentOffice, newOfficeName);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Office updated successfully' : 'Failed to update office'),
                      backgroundColor: success ? const Color(0xFF166534) : const Color(0xFFB91C1C),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lnuNavy,
            ),
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteOfficeModal(String officeName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Office"),
        content: Text("Are you sure you want to delete \"$officeName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await officeStore.deleteOffice(officeName);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Office deleted successfully' : 'Failed to delete office'),
                    backgroundColor: success ? const Color(0xFF166534) : const Color(0xFFB91C1C),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offices = officeStore.offices;

    return AdminLayout(
      pageTitle: "Manage Offices",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showAddOfficeModal,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Office",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lnuNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...offices.map(
            (office) {
              final officeName = office['name'] as String;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        officeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showEditOfficeModal(officeName),
                      child: const Text("Edit"),
                    ),
                    TextButton(
                      onPressed: () => _showDeleteOfficeModal(officeName),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Color(0xFFB91C1C)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}