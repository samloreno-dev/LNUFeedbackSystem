import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

import '../../../core/services/api_service.dart';
import '../services/office_store.dart';
import '../widgets/admin_layout.dart';
import '../widgets/admin_summary_card.dart';

class AdminDashboardPage extends StatefulWidget {
  final String adminEmail;

  const AdminDashboardPage({
    super.key,
    required this.adminEmail,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final OfficeStore officeStore = OfficeStore();

  Timer? _timer;

  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    officeStore.addListener(_refresh);
    officeStore.fetchOffices();

    fetchDashboard();

    // 🔥 AUTO REFRESH EVERY 10 SECONDS
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDashboard();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // stop auto refresh

    officeStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> fetchDashboard() async {
    try {
      if (!mounted) return;

      // Use defensive parsing: guarantees we only accept Map-shaped JSON.
      final data = await ApiService.getJson('/dashboard-summary');

      setState(() {
        dashboardData = data;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        dashboardData = null;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final data = dashboardData ?? {};

    final offices = officeStore.offices;
    final officeError = officeStore.error;

    final dynamic officesRaw = data['offices'];

    final Map<String, dynamic> officeData =
        officesRaw is Map ? Map<String, dynamic>.from(officesRaw) : {};

    int safeInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }


    final int totalFeedback = safeInt(data['total_feedback']);
    final int totalPositive = safeInt(data['positive']);
    final int totalNegative = safeInt(data['negative']);
    final int totalNeutral = safeInt(data['neutral']);



    final String aiSummary =
        data['ai_summary'] ??
        "AI summary is being generated...";

    return AdminLayout(
      pageTitle: "Main Dashboard",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP SUMMARY
            Row(
              children: [
                Expanded(
                  child: AdminSummaryCard(
                    title: "Total",
                    value: totalFeedback.toString(),
                    icon: Icons.feedback_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminSummaryCard(
                    title: "Positive",
                    value: totalPositive.toString(),
                    icon: Icons.thumb_up_alt_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminSummaryCard(
                    title: "Negative",
                    value: totalNegative.toString(),
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// AI SUMMARY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.lnuWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AI Summary",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(aiSummary),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// SENTIMENT SUMMARY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.lnuWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                "Positive: $totalPositive\n"
                "Negative: $totalNegative\n"
                "Neutral: $totalNeutral",
              ),
            ),

            const SizedBox(height: 28),

            /// OFFICE OVERVIEW
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.lnuWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Office Overview",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (officeError != null)
                    Text(officeError)
                  else if (offices.isEmpty)
                    const Text("No offices available.")
                  else
                    Column(
                      children: offices.map((office) {
                        final officeName =
                            office['name']?.toString() ?? 'Unknown';

                        final entry = officeData[officeName];
                        final entryMap = entry is Map ? Map<String, dynamic>.from(entry) : <String, dynamic>{};


                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            "$officeName — ${entryMap['total'] ?? 0} feedback",

                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}