import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class OfficeStore extends ChangeNotifier {
  static final OfficeStore _instance = OfficeStore._internal();
  factory OfficeStore() => _instance;
  OfficeStore._internal();

  final List<Map<String, dynamic>> _offices = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get offices => List.unmodifiable(_offices);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOffices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/offices');
      if (response.statusCode == 200) {
        // Laravel OfficeController@index returns a raw JSON array
        final data = jsonDecode(response.body);
        if (data is List) {
          _offices.clear();
          for (var office in data) {
            _offices.add({
              'id': office['id'],
              'name': office['name'],
            });
          }
        } else {
          _error = 'Invalid offices payload';
        }
      } else {
        _error = 'Failed to load offices';
      }
    } catch (e) {
      _error = 'Network error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addOffice(String officeName) async {
    final trimmed = officeName.trim();
    if (trimmed.isEmpty) return false;
    if (_offices.any((office) => office['name']!.toLowerCase() == trimmed.toLowerCase())) {
      return false;
    }

    try {
      _error = null;

      final response = await ApiService.post(
        '/offices',
        body: {'name': trimmed},
      );

      // Backend should return 201, but accept common variants.
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Laravel OfficeController@store returns the created office object.
        if (decoded is Map<String, dynamic>) {
          final id = decoded['id'];
          final name = decoded['name'];

          // Some proxies/frameworks might return numbers as int or string.
          _offices.add({
            'id': id,
            'name': name ?? trimmed,
          });

          notifyListeners();
          return true;
        }

        // If we got a success code but non-JSON payload, still treat as failure.
        _error = 'Invalid success payload: ${response.body}';
        return false;
      }

      // Capture backend response for debugging (422/401/404/500 etc.)
      _error = 'Add failed: HTTP ${response.statusCode} - ${response.body}';
      return false;
    } catch (e) {
      _error = 'Failed to add office: $e';
      return false;
    }
  }



  Future<bool> updateOffice(String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;

    final index = _offices.indexWhere((office) => office['name'] == oldName);
    if (index == -1) return false;

    final alreadyExists = _offices.any(
      (office) =>
          office['name']!.toLowerCase() == trimmed.toLowerCase() &&
          office['name']!.toLowerCase() != oldName.toLowerCase(),
    );
    if (alreadyExists) return false;

    final id = _offices[index]['id'];

    try {
      final response = await ApiService.put('/offices/$id', body: {'name': trimmed});
      if (response.statusCode == 200) {
        // Laravel OfficeController@update returns the updated office object
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          _offices[index] = {
            'id': id,
            'name': trimmed,
          };
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      _error = 'Failed to update office: $e';
    }

    return false;
  }

  Future<bool> deleteOffice(String officeName) async {
    final index = _offices.indexWhere((office) => office['name'] == officeName);
    if (index == -1) return false;

    final id = _offices[index]['id'];

    try {
      final response = await ApiService.delete('/offices/$id');
      if (response.statusCode == 200) {
        _offices.removeAt(index);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete office: $e';
    }

    return false;
  }

  String? getOfficeNameById(int id) {
    final office = _offices.firstWhere(
      (o) => o['id'] == id,
      orElse: () => {},
    );
    return office.isNotEmpty ? office['name'] : null;
  }
}

