import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RecaptchaWidget extends StatefulWidget {
  final Function(String token) onVerified;

  const RecaptchaWidget({
    super.key,
    required this.onVerified,
  });

  @override
  State<RecaptchaWidget> createState() => _RecaptchaWidgetState();
}

class _RecaptchaWidgetState extends State<RecaptchaWidget> {
  StreamSubscription<html.MessageEvent>? _messageSubscription;
  late final String _viewId;

  @override
  void initState() {
    super.initState();

    _viewId = 'recaptcha-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = 'recaptcha.html'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '120px';

          return iframe;
        },
      );

      _messageSubscription = html.window.onMessage.listen((event) {
        try {
          final data = event.data;

          if (data is String) {
            final decoded = jsonDecode(data);

            if (decoded is Map &&
                decoded['type'] == 'recaptcha-success' &&
                decoded['token'] != null) {
              widget.onVerified(decoded['token'].toString());
            }
          }
        } catch (_) {
          // Ignore unrelated postMessage events.
        }
      });
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Text('reCAPTCHA is only available on web.');
    }

    return SizedBox(
      height: 120,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
