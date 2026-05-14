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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      officeStore.fetchOffices();
    });
  }



  void _showAddOfficeModal() {
    final controller = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      barrierDismissible: !submitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Office'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Office Name',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                        onPressed: submitting
                      ? null
                      : () async {
                          final officeName = controller.text.trim();
                          if (officeName.isEmpty) return;

                          setState(() => submitting = true);
                        final ok = await officeStore.addOffice(officeName);
                          await officeStore.fetchOffices();

                          if (!dialogContext.mounted) return;

                          if (ok) {
                            Navigator.pop(dialogContext);
                          } else {
                            setState(() => submitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  officeStore.error ??
                                      'Failed to add office. Please try again.',
                                ),
                                backgroundColor: const Color(0xFFB91C1C),
                              ),
                            );
                          }

                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lnuNavy,
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditOfficeModal(String currentOffice) {
    final controller = TextEditingController(text: currentOffice);
    bool submitting = false;

    showDialog(
      context: context,
      barrierDismissible: !submitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Office'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Office Name',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          final newOfficeName = controller.text.trim();
                          if (newOfficeName.isEmpty) return;

                          setState(() => submitting = true);
                          await officeStore.updateOffice(currentOffice, newOfficeName);
                          await officeStore.fetchOffices();

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lnuNavy,
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteOfficeModal(String officeName) {
    bool submitting = false;

    showDialog(
      context: context,
      barrierDismissible: !submitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Office'),
              content:
                  Text('Are you sure you want to delete "$officeName"?'),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          setState(() => submitting = true);
                          await officeStore.deleteOffice(officeName);
                          await officeStore.fetchOffices();

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      pageTitle: 'Manage Offices',
      child: AnimatedBuilder(
        animation: officeStore,
        builder: (context, _) {
          final offices = officeStore.offices;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddOfficeModal,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Office',
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

              if (officeStore.isLoading) const LinearProgressIndicator(),
              if (officeStore.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    officeStore.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              ...offices.map((office) {
                final name = office['name'].toString();

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lnuWhite,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showEditOfficeModal(name),
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: () => _showDeleteOfficeModal(name),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Color(0xFFB91C1C)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}


