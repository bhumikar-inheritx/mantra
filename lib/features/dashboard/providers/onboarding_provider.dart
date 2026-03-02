import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  String? _selectedMood;
  String? _selectedGoal;
  String? _selectedDeity;

  final List<String> _moods = ['Stress', 'Fear', 'Confusion', 'Success', 'Gratitude'];
  final List<String> _goals = ['Health', 'Money', 'Protection', 'Peace', 'Spiritual Growth'];
  final List<String> _deities = ['Shiv', 'Vishnu', 'Ganesh', 'Devi', 'Krishna', 'None'];

  int get currentPage => _currentPage;
  String? get selectedMood => _selectedMood;
  String? get selectedGoal => _selectedGoal;
  String? get selectedDeity => _selectedDeity;

  List<String> get moods => _moods;
  List<String> get goals => _goals;
  List<String> get deities => _deities;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setSelectedMood(String? mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void setSelectedGoal(String? goal) {
    _selectedGoal = goal;
    notifyListeners();
  }

  void setSelectedDeity(String? deity) {
    _selectedDeity = deity;
    notifyListeners();
  }

  bool canGoNext() {
    if (_currentPage == 0) return _selectedMood != null;
    if (_currentPage == 1) return _selectedGoal != null;
    return true;
  }
}
