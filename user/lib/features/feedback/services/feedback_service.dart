import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  // IMPORTANT:
  // `localhost` works only when Flutter runs on the same machine as the API.
  // For Android emulator use 10.0.2.2; for physical devices use your PC LAN IP.
  static const String baseUrl = 'http://10.0.2.2:8082/api'; // user backend


  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> submitFeedback({
    required String message,
    int? officeId,
    int? typeId,
    String? captchaToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'message': message.trim(),
          if (officeId != null) 'officeId': officeId,
          if (typeId != null) 'typeId': typeId,
          if (captchaToken != null && captchaToken.trim().isNotEmpty)
            'captchaToken': captchaToken.trim(),
        }),
      );

      final decoded = response.body.isNotEmpty ? json.decode(response.body) : null;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend may return { success: true/false, message: '' } or arbitrary data.
        if (decoded is Map<String, dynamic>) {
          final bool success = decoded['success'] == true;
          if (decoded.containsKey('success')) {
            return {
              'success': success,
              'message': decoded['message'] ?? (success ? 'Submitted' : 'Failed to submit feedback'),
              'data': decoded,
            };
          }
          return {'success': true, 'data': decoded};
        }
        return {'success': true, 'data': decoded};
      }

      if (decoded is Map<String, dynamic>) {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to submit feedback'
        };
      }

      return {
        'success': false,
        'message': 'Failed to submit feedback (HTTP ${response.statusCode})'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> getOffices() async {
    // Default offices (fallback) so UI always has options.
    final List<Map<String, dynamic>> fallback = const [
      {'id': 1, 'name': 'Library'},
      {'id': 2, 'name': 'Dormitory'},
      {'id': 3, 'name': 'Registrar'},
    ];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/offices'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> serverData = data['data'] ?? [];

        // Merge: keep fallback offices, and add any new ones returned by server.
        // De-dupe by office name (case-insensitive).
        final Map<String, Map<String, dynamic>> byName = {};

        for (final o in fallback) {
          final name = (o['name'] ?? '').toString().trim();
          if (name.isEmpty) continue;
          byName[name.toLowerCase()] = Map<String, dynamic>.from(o);
        }

        for (final o in serverData) {
          if (o is Map) {
            final name = (o['name'] ?? '').toString().trim();
            if (name.isEmpty) continue;
            byName[name.toLowerCase()] = {
              'id': o['id'],
              'name': name,
            };
          }
        }

        return byName.values.toList();
      }

      // Non-200 => fallback only.
      return fallback;
    } catch (_) {
      // Network/parse failure => fallback only.
      return fallback;
    }
  }

  Future<List<Map<String, dynamic>>> getTypes() async {
    return [
      {'id': 1, 'name': 'Service'},
      {'id': 2, 'name': 'Staff'},
      {'id': 3, 'name': 'Environment'},
      {'id': 4, 'name': 'Others'},
    ];
  }
}
