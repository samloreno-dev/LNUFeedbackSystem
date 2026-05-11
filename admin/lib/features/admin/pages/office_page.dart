import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/admin_layout.dart';
import '../widgets/admin_summary_card.dart';

class OfficePage extends StatelessWidget {
  final String officeName;

  const OfficePage({super.key, required this.officeName});

  @override
  Widget build(BuildContext context) {
    final officeData = _getOfficeData(officeName);

    return AdminLayout(
      pageTitle: officeName,
      child: officeData == null
          ? _OfficeEmptyState(officeName: officeName)
          : _OfficeContent(
              officeName: officeName,
              officeData: officeData,
            ),
    );
  }

  Map<String, dynamic>? _getOfficeData(String officeName) {
    final mock = <String, Map<String, dynamic>>{
      "Library": {
        "total": 42,
        "positive": 26,
        "negative": 10,
        "neutral": 6,
        "aiSummary":
            "Feedback for the Library is generally positive...",
        "categories": {
          "Service": [
            {
              "message": "Borrowing and returning books was easy.",
              "date": "2026-04-20",
              "time": "10:32 AM",
            }
          ]
        }
      }
    };

    return mock[officeName];
  }
}

class _OfficeContent extends StatelessWidget {
  final String officeName;
  final Map<String, dynamic> officeData;

  const _OfficeContent({
    required this.officeName,
    required this.officeData,
  });

  @override
  Widget build(BuildContext context) {
    final rawCategories = officeData["categories"];

    final Map<String, List<Map<String, String>>> categories = {};

    // ✅ SAFE PARSING (prevents crash)
    if (rawCategories is Map) {
      rawCategories.forEach((key, value) {
        if (value is List) {
          categories[key.toString()] = value
              .whereType<Map>()
              .map((item) => item.map(
                    (k, v) => MapEntry(
                      k.toString(),
                      v?.toString() ?? "",
                    ),
                  ))
              .toList();
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSummaryCard(
          title: "Total",
          value: (officeData["total"] ?? 0).toString(),
          icon: Icons.feedback_outlined,
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.lnuWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            officeData["aiSummary"]?.toString() ??
                "No summary available.",
          ),
        ),

        const SizedBox(height: 24),

        ...categories.entries.map(
          (entry) => _CategoryFeedbackCard(
            category: entry.key,
            feedbackList: entry.value,
          ),
        ),
      ],
    );
  }
}

class _OfficeEmptyState extends StatelessWidget {
  final String officeName;

  const _OfficeEmptyState({required this.officeName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No data available for $officeName"),
    );
  }
}

class _CategoryFeedbackCard extends StatelessWidget {
  final String category;
  final List<Map<String, String>> feedbackList;

  const _CategoryFeedbackCard({
    required this.category,
    required this.feedbackList,
  });

  Color _categoryColor() {
    switch (category) {
      case "Service":
        return AppColors.lnuNavy;
      case "Staff":
        return const Color(0xFFEA580C);
      case "Environment":
        return const Color(0xFF059669);
      default:
        return AppColors.lnuGold;
    }
  }

  IconData _categoryIcon() {
    switch (category) {
      case "Service":
        return Icons.miscellaneous_services_outlined;
      case "Staff":
        return Icons.groups_outlined;
      case "Environment":
        return Icons.park_outlined;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lnuWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_categoryIcon(), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category),
                Text("${feedbackList.length} entries"),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: color.withValues(alpha: 0.55),
              ),
            ),
            child: const Text("View"),
          ),
        ],
      ),
    );
  }
}