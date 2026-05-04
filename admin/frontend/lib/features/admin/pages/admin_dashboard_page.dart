import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/office_store.dart';
import '../widgets/admin_layout.dart';
import '../widgets/admin_summary_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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

  Map<String, Map<String, dynamic>> getMockOfficeData() {
    return {
      "Library": {
        "total": 42,
        "positive": 26,
        "negative": 10,
        "neutral": 6,
      },
      "Dormitory": {
        "total": 31,
        "positive": 14,
        "negative": 11,
        "neutral": 6,
      },
      "Registrar": {
        "total": 55,
        "positive": 34,
        "negative": 15,
        "neutral": 6,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final officeData = getMockOfficeData();
    final offices = officeStore.offices;

    final int totalFeedback = officeData.values.fold(
      0,
      (sum, item) => sum + ((item["total"] as int?) ?? 0),
    );

    final int totalPositive = officeData.values.fold(
      0,
      (sum, item) => sum + ((item["positive"] as int?) ?? 0),
    );

    final int totalNegative = officeData.values.fold(
      0,
      (sum, item) => sum + ((item["negative"] as int?) ?? 0),
    );

    final int totalNeutral = officeData.values.fold(
      0,
      (sum, item) => sum + ((item["neutral"] as int?) ?? 0),
    );

    const String aiSummary =
        "Overall feedback shows appreciation for staff courtesy and organized service delivery, while recurring concerns are concentrated around waiting time and response delays during peak hours.";

    return AdminLayout(
      pageTitle: "Main Dashboard",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool stackAnalytics = constraints.maxWidth < 1120;
          final bool stackOffices = constraints.maxWidth < 960;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    child: _MetricCard(
                      title: "Positive",
                      value: totalPositive.toString(),
                      icon: Icons.thumb_up_alt_rounded,
                      color: const Color(0xFF166534),
                      backgroundColor: const Color(0xFFDCFCE7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: "Negative",
                      value: totalNegative.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFB91C1C),
                      backgroundColor: const Color(0xFFFEE2E2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              if (stackAnalytics)
                Column(
                  children: [
                    _AiSummaryCard(summary: aiSummary),
                    const SizedBox(height: 16),
                    _SentimentCard(
                      positive: totalPositive,
                      negative: totalNegative,
                      neutral: totalNeutral,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _AiSummaryCard(summary: aiSummary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SentimentCard(
                        positive: totalPositive,
                        negative: totalNegative,
                        neutral: totalNeutral,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.lnuWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
                    if (offices.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          "No offices available.",
                          style: TextStyle(
                            color: AppColors.mutedText,
                          ),
                        ),
                      )
                    else if (stackOffices)
                      Column(
                      children: offices.map((office) {
                          final officeName = office['name'] as String;
                          final data = officeData[officeName];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OfficeCard(
                              officeName: officeName,
                              count: data?["total"] ?? 0,
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Row(
                        children: offices.asMap().entries.map((entry) {
                          final index = entry.key;
                          final officeName = entry.value['name'] as String;
                          final data = officeData[officeName];

                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index != offices.length - 1 ? 12 : 0,
                              ),
                              child: _OfficeCard(
                                officeName: officeName,
                                count: data?["total"] ?? 0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.70),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
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

class _AiSummaryCard extends StatelessWidget {
  final String summary;

  const _AiSummaryCard({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 264,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.lnuWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Summary",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.lnuGold,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(
                color: AppColors.mutedText,
                height: 1.7,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentCard extends StatelessWidget {
  final int positive;
  final int negative;
  final int neutral;

  const _SentimentCard({
    required this.positive,
    required this.negative,
    required this.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final int total = positive + negative + neutral;
    final double positiveRatio = total == 0 ? 0 : positive / total;
    final double negativeRatio = total == 0 ? 0 : negative / total;
    final double neutralRatio = total == 0 ? 0 : neutral / total;

    return Container(
      height: 264,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.lnuWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sentiment",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 18),
          _SentimentBar(
            label: "Positive",
            value: positive,
            ratio: positiveRatio,
            color: const Color(0xFF166534),
          ),
          const SizedBox(height: 16),
          _SentimentBar(
            label: "Negative",
            value: negative,
            ratio: negativeRatio,
            color: const Color(0xFFB91C1C),
          ),
          const SizedBox(height: 16),
          _SentimentBar(
            label: "Neutral",
            value: neutral,
            ratio: neutralRatio,
            color: const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  final String label;
  final int value;
  final double ratio;
  final Color color;

  const _SentimentBar({
    required this.label,
    required this.value,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              value.toString(),
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            color: color,
            backgroundColor: const Color(0xFFE5E7EB),
          ),
        ),
      ],
    );
  }
}

class _OfficeCard extends StatelessWidget {
  final String officeName;
  final int count;

  const _OfficeCard({
    required this.officeName,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lnuNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.apartment_outlined,
              color: AppColors.lnuNavy,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            officeName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            count > 0 ? "$count feedback" : "No data yet",
            style: const TextStyle(
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}