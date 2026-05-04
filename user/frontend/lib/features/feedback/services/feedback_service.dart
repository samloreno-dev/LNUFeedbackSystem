import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  static const String baseUrl = 'http://localhost:8080/api'; // Adjust as needed for web

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> submitFeedback({
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'message': message.trim()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      }
      final error = json.decode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Failed to submit feedback'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> getOffices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/offices'), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
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
