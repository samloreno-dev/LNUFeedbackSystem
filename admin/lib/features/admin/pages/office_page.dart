import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/admin_layout.dart';
import '../widgets/admin_summary_card.dart';

class OfficePage extends StatelessWidget {
  final String officeName;

  const OfficePage({
    super.key,
    required this.officeName,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? officeData = _getOfficeData(officeName);
    final bool hasData = officeData != null;

    return AdminLayout(
      pageTitle: officeName,
      child: hasData
          ? _OfficeContent(
              officeName: officeName,
              officeData: officeData,
            )
          : _OfficeEmptyState(
              officeName: officeName,
            ),
    );
  }

  Map<String, dynamic>? _getOfficeData(String officeName) {
    final Map<String, Map<String, dynamic>> mockOfficeData = {
      "Library": {
        "total": 42,
        "positive": 26,
        "negative": 10,
        "neutral": 6,
        "aiSummary":
            "Feedback for the Library is generally positive. Students appreciate the quiet study environment and organized facilities, though some recurring concerns mention seating availability and occasional waiting time during peak periods.",
        "categories": {
          "Service": [
            {
              "message":
                  "Borrowing and returning books was easy and organized.",
              "date": "2026-04-20",
              "time": "10:32 AM"
            },
            {
              "message":
                  "The process is good but queueing takes time during busy hours.",
              "date": "2026-04-19",
              "time": "2:15 PM"
            },
          ],
          "Staff": [
            {
              "message": "Staff were approachable and polite.",
              "date": "2026-04-18",
              "time": "9:10 AM"
            },
            {
              "message":
                  "One staff member was not very responsive to questions.",
              "date": "2026-04-18",
              "time": "1:42 PM"
            },
          ],
          "Environment": [
            {
              "message":
                  "The study area is clean, quiet, and conducive for reading.",
              "date": "2026-04-17",
              "time": "11:00 AM"
            },
          ],
          "Others": [
            {
              "message":
                  "It would be better if there were more charging stations.",
              "date": "2026-04-16",
              "time": "4:20 PM"
            },
          ],
        }
      },
      "Dormitory": {
        "total": 31,
        "positive": 14,
        "negative": 11,
        "neutral": 6,
        "aiSummary":
            "Dormitory feedback is mixed. Residents appreciate cleanliness improvements and some staff responsiveness, but common concerns include maintenance response time and room-related issues.",
        "categories": {
          "Service": [
            {
              "message":
                  "Requests are acknowledged, but action sometimes takes too long.",
              "date": "2026-04-20",
              "time": "8:45 AM"
            },
          ],
          "Staff": [
            {
              "message": "Some staff are helpful and respectful.",
              "date": "2026-04-19",
              "time": "6:20 PM"
            },
          ],
          "Environment": [
            {
              "message": "The hallways are cleaner now than before.",
              "date": "2026-04-18",
              "time": "3:10 PM"
            },
          ],
          "Others": [
            {
              "message":
                  "Maintenance requests should be addressed faster.",
              "date": "2026-04-17",
              "time": "1:05 PM"
            },
          ],
        }
      },
      "Registrar": {
        "total": 55,
        "positive": 34,
        "negative": 15,
        "neutral": 6,
        "aiSummary":
            "Registrar feedback is mostly positive, especially regarding transaction completion and staff courtesy. The most common issues involve long queues and response time during enrollment periods.",
        "categories": {
          "Service": [
            {
              "message":
                  "The process is clear, but waiting in line takes too long.",
              "date": "2026-04-21",
              "time": "9:30 AM"
            },
            {
              "message":
                  "The transaction was completed successfully and efficiently.",
              "date": "2026-04-20",
              "time": "2:40 PM"
            },
          ],
          "Staff": [
            {
              "message": "Staff were courteous and helpful.",
              "date": "2026-04-19",
              "time": "11:20 AM"
            },
          ],
          "Environment": [
            {
              "message":
                  "The office is organized, but the waiting area gets crowded.",
              "date": "2026-04-18",
              "time": "10:05 AM"
            },
          ],
          "Others": [
            {
              "message":
                  "More service windows would help during enrollment.",
              "date": "2026-04-17",
              "time": "4:50 PM"
            },
          ],
        }
      },
    };

    return mockOfficeData[officeName];
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
    final Map<String, List<Map<String, String>>> categories =
        (officeData["categories"] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .map((item) => Map<String, String>.from(item as Map))
            .toList(),
      ),
    );

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
                    title: "Total",
                    value: officeData["total"].toString(),
                    icon: Icons.feedback_outlined,
                  ),
                  const SizedBox(height: 16),
                  _SentimentMetricCard(
                    title: "Positive",
                    value: officeData["positive"].toString(),
                    color: const Color(0xFF166534),
                    backgroundColor: const Color(0xFFDCFCE7),
                    icon: Icons.thumb_up_alt_rounded,
                  ),
                  const SizedBox(height: 16),
                  _SentimentMetricCard(
                    title: "Negative",
                    value: officeData["negative"].toString(),
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
                      title: "Total",
                      value: officeData["total"].toString(),
                      icon: Icons.feedback_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SentimentMetricCard(
                      title: "Positive",
                      value: officeData["positive"].toString(),
                      color: const Color(0xFF166534),
                      backgroundColor: const Color(0xFFDCFCE7),
                      icon: Icons.thumb_up_alt_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SentimentMetricCard(
                      title: "Negative",
                      value: officeData["negative"].toString(),
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
                  Row(
                    children: [
                      const Text(
                        "AI Summary",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "AI summary sent to $officeName (mock).",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.send_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Send to Office",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lnuNavy,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    officeData["aiSummary"].toString(),
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
              "Categorized Feedback",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            ...categories.entries.map((entry) {
              return _CategoryFeedbackCard(
                category: entry.key,
                feedbackList: entry.value,
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class _OfficeEmptyState extends StatelessWidget {
  final String officeName;

  const _OfficeEmptyState({
    required this.officeName,
  });

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
              color: AppColors.lnuNavy.withOpacity(0.08),
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
            "No feedback data is available for this office yet.",
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

  void _showRawFeedbackModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 860,
              maxHeight: 640,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lnuWhite,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _categoryColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _categoryIcon(),
                        color: _categoryColor(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$category Raw Feedback",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${feedbackList.length} feedback entr${feedbackList.length == 1 ? 'y' : 'ies'}",
                            style: const TextStyle(
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: feedbackList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final feedback = feedbackList[index];

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feedback["message"] ?? "",
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_outlined,
                                  size: 16,
                                  color: AppColors.mutedText,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${feedback["date"] ?? ""} • ${feedback["time"] ?? ""}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      color: color.withOpacity(0.12),
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
                          "${feedbackList.length} raw feedback entr${feedbackList.length == 1 ? 'y' : 'ies'}",
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
                    onPressed: () => _showRawFeedbackModal(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: color.withOpacity(0.55)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      "View Raw Feedback",
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