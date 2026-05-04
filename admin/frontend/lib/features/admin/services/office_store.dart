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
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _offices.clear();
          final List<dynamic> officesData = data['data'];
          for (var office in officesData) {
            _offices.add({
              'id': office['id'],
              'name': office['name'],
            });
          }
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
      final response = await ApiService.post('/offices', body: {'name': trimmed});
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _offices.add({
            'id': data['data']['id'],
            'name': data['data']['name'],
          });
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      _error = 'Failed to add office: $e';
    }

    return false;
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
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
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

