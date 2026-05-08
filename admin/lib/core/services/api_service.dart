import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // Use: --dart-define=API_BASE_URL=http://YOUR_IP:8000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<Map<String, String>> get _authHeaders async {
    final headers = Map<String, String>.from(_headers);

    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// =========================
  /// GET (RAW RESPONSE)
  /// =========================
  static Future<http.Response> get(String endpoint) async {
    final headers = await _authHeaders;

    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  /// =========================
  /// GET (CLEAN JSON PARSED)
  /// USE THIS FOR DASHBOARD
  /// =========================
  static Future<Map<String, dynamic>> getJson(String endpoint) async {
    final response = await get(endpoint);

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception("Invalid JSON format from API");
  }

  /// =========================
  /// POST
  /// =========================
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _authHeaders;

    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// =========================
  /// PUT
  /// =========================
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _authHeaders;

    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// =========================
  /// DELETE
  /// =========================
  static Future<http.Response> delete(String endpoint) async {
    final headers = await _authHeaders;

    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }
}