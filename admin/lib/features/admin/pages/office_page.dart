import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/admin_layout.dart';
import '../widgets/admin_summary_card.dart';

class OfficePage extends StatelessWidget {
  final String officeName;

  const OfficePage({super.key, required this.officeName});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? officeData = _getOfficeData(officeName);

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
    // Keep existing mock-based behavior.
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
          ],
        }
      },
      "Dormitory": {
        "total": 31,
        "positive": 14,
        "negative": 11,
        "neutral": 6,
        "aiSummary":
            "Dormitory feedback is mixed. Residents appreciate cleanliness improvements...",
        "categories": {
          "Service": [
            {
              "message": "Requests are acknowledged, but action sometimes takes too long.",
              "date": "2026-04-20",
              "time": "8:45 AM",
            }
          ],
        }
      },
      "Registrar": {
        "total": 55,
        "positive": 34,
        "negative": 15,
        "neutral": 6,
        "aiSummary":
            "Registrar feedback is mostly positive, especially regarding transaction completion...",
        "categories": {
          "Service": [
            {
              "message": "The process is clear, but waiting in line takes too long.",
              "date": "2026-04-21",
              "time": "9:30 AM",
            }
          ],
        }
      },
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
    final rawCategories = officeData['categories'];

    // ✅ safe parsing (prevents crash)
    final Map<String, List<Map<String, String>>> categories = {};
    if (rawCategories is Map) {
      rawCategories.forEach((key, value) {
        if (value is List) {
          categories[key.toString()] = value.whereType<Map>().map((item) {
            return item.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
          }).toList();
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stackTopCards = constraints.maxWidth < 980;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stackTopCards)
              Column(
                children: [
                  AdminSummaryCard(
                    title: 'Total',
                    value: officeData['total'].toString(),
                    icon: Icons.feedback_outlined,
                  ),
                  const SizedBox(height: 16),
                  _SentimentMetricCard(
                    title: 'Positive',
                    value: officeData['positive'].toString(),
                    color: const Color(0xFF166534),
                    backgroundColor: const Color(0xFFDCFCE7),
                    icon: Icons.thumb_up_alt_rounded,
                  ),
                  const SizedBox(height: 16),
                  _SentimentMetricCard(
                    title: 'Negative',
                    value: officeData['negative'].toString(),
                    color: const Color(0xFFB91C1C),
                    backgroundColor: const Color(0xFFFEE2E2),
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AdminSummaryCard(
                      title: 'Total',
                      value: officeData['total'].toString(),
                      icon: Icons.feedback_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SentimentMetricCard(
                      title: 'Positive',
                      value: officeData['positive'].toString(),
                      color: const Color(0xFF166534),
                      backgroundColor: const Color(0xFFDCFCE7),
                      icon: Icons.thumb_up_alt_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SentimentMetricCard(
                      title: 'Negative',
                      value: officeData['negative'].toString(),
                      color: const Color(0xFFB91C1C),
                      backgroundColor: const Color(0xFFFEE2E2),
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

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
                    'AI Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    officeData['aiSummary']?.toString() ?? 'No summary available.',
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Categorized Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),

            ...categories.entries.map(
              (entry) => _CategoryFeedbackCard(
                category: entry.key,
                feedbackList: entry.value,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OfficeEmptyState extends StatelessWidget {
  final String officeName;

  const _OfficeEmptyState({required this.officeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.lnuWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.lnuNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.apartment_outlined,
              size: 34,
              color: AppColors.lnuNavy,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            officeName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'No feedback data is available for this office yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const _SentimentMetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
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
      case 'Service':
        return AppColors.lnuNavy;
      case 'Staff':
        return const Color(0xFFEA580C);
      case 'Environment':
        return const Color(0xFF059669);
      default:
        return AppColors.lnuGold;
    }
  }

  IconData _categoryIcon() {
    switch (category) {
      case 'Service':
        return Icons.miscellaneous_services_outlined;
      case 'Staff':
        return Icons.groups_outlined;
      case 'Environment':
        return Icons.park_outlined;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.lnuWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 108,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${feedbackList.length} raw feedback entr${feedbackList.length == 1 ? 'y' : 'ies'}',
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: color.withValues(alpha: 0.55)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

