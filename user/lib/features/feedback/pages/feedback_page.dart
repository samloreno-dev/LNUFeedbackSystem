import 'package:flutter/material.dart';

import '../widgets/feedback_form.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          SizedBox.expand(
            child: Image.asset(
              "assets/images/lnu_bg.jpg",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0B1F5C),
                      Color(0xFFD4AF37),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          /// DARK OVERLAY (better readability)
          Container(
color: Colors.black.withValues(alpha: 0.45),
          ),

          /// CONTENT
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const SingleChildScrollView(
                      child: FeedbackForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
