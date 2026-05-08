import 'package:flutter/material.dart';
import '../features/feedback/pages/feedback_page.dart';
import '../features/feedback/pages/thankyou_page.dart';

class AppRoutes {
  static const String feedback = "/";
  static const String thankyou = "/thankyou";

  static Map<String, WidgetBuilder> routes = {
    feedback: (context) => const FeedbackPage(),
    thankyou: (context) => const ThankYouPage(),
  };
}
