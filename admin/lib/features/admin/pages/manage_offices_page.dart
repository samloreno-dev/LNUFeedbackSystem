import 'package:flutter/material.dart';

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

  Future<void> _handleAddOffice(String name) async {
    await officeStore.addOffice(name);
    await officeStore.fetchOffices();
  }

  Future<void> _handleDeleteOffice(String officeName) async {
    await officeStore.deleteOffice(officeName);
    await officeStore.fetchOffices();
  }

  void _addDialog() {
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
                decoration: const InputDecoration(hintText: 'Office name'),
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
                          final name = controller.text.trim();
                          if (name.isEmpty) return;

                          setState(() => submitting = true);
                          await _handleAddOffice(name);

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
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
            children: [
              ElevatedButton(
                onPressed: _addDialog,
                child: const Text('Add Office'),
              ),
              const SizedBox(height: 20),

              if (officeStore.isLoading)
                const CircularProgressIndicator(),

              if (officeStore.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    officeStore.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              ...offices.map((o) {
                final name = o['name'].toString();

                return ListTile(
                  title: Text(name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _handleDeleteOffice(name),
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

