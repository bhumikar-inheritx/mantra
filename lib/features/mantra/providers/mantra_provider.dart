import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/mantra_model.dart';

class MantraProvider extends ChangeNotifier {
  List<MantraModel> _mantras = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _selectedDeity = 'All';
  String _selectedZodiac = 'All';
  String _selectedPlanet = 'All';
  String _selectedTrackType = 'All';
  String _searchQuery = '';

  List<MantraModel> get mantras {
    return _mantras.where((m) {
      final matchesCategory = _selectedCategory == 'All' || m.category == _selectedCategory;
      final matchesDeity = _selectedDeity == 'All' || m.deity == _selectedDeity;
      final matchesZodiac = _selectedZodiac == 'All' || m.zodiac.contains(_selectedZodiac);
      final matchesPlanet = _selectedPlanet == 'All' || m.planet.contains(_selectedPlanet);
      final matchesTrackType = _selectedTrackType == 'All' || m.trackType == _selectedTrackType;
      
      final matchesSearch = _searchQuery.isEmpty || 
          m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.titleHindi.contains(_searchQuery) ||
          m.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.transliteration.toLowerCase().contains(_searchQuery.toLowerCase());
          
      return matchesCategory && matchesDeity && matchesZodiac && 
             matchesPlanet && matchesTrackType && matchesSearch;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get selectedDeity => _selectedDeity;
  String get selectedZodiac => _selectedZodiac;
  String get selectedPlanet => _selectedPlanet;
  String get selectedTrackType => _selectedTrackType;
  String get searchQuery => _searchQuery;

  String get currentFilterValue {
    if (_selectedDeity != 'All') return _selectedDeity;
    if (_selectedCategory != 'All') return _selectedCategory;
    if (_selectedZodiac != 'All') return _selectedZodiac;
    if (_selectedPlanet != 'All') return _selectedPlanet;
    if (_selectedTrackType != 'All') return _selectedTrackType;
    return 'All';
  }

  List<String> get categories {
    final cats = _mantras.map((m) => m.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<String> get deities {
    final deities = _mantras.map((m) => m.deity).toSet().toList();
    deities.sort();
    return ['All', ...deities];
  }

  List<String> get zodiacs {
    final allZodiacs = _mantras.expand((m) => m.zodiac).toSet().toList();
    allZodiacs.sort();
    return ['All', ...allZodiacs];
  }

  List<String> get planets {
    final allPlanets = _mantras.expand((m) => m.planet).toSet().toList();
    allPlanets.sort();
    return ['All', ...allPlanets];
  }

  List<String> get trackTypes {
    final types = _mantras.map((m) => m.trackType).toSet().toList();
    types.sort();
    return ['All', ...types];
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

  void setDeity(String deity) {
    _selectedDeity = deity;
    notifyListeners();
  }

  void setZodiac(String zodiac) {
    _selectedZodiac = zodiac;
    notifyListeners();
  }

  void setPlanet(String planet) {
    _selectedPlanet = planet;
    notifyListeners();
  }

  void setTrackType(String type) {
    _selectedTrackType = type;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _selectedDeity = 'All';
    _selectedZodiac = 'All';
    _selectedPlanet = 'All';
    _selectedTrackType = 'All';
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
