import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/mantra_model.dart';

class MantraProvider extends ChangeNotifier {
  List<MantraModel> _mantras = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';

  List<MantraModel> get mantras {
    if (_selectedCategory == 'All') return _mantras;
    return _mantras.where((m) => m.category == _selectedCategory).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _mantras.map((m) => m.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  Future<void> loadMantras() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/data/mantras.json');
      final List<dynamic> data = json.decode(response);
      _mantras = data.map((json) => MantraModel.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = "Failed to load mantras: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
