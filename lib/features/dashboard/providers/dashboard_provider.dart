import 'dart:math';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int _streak = 5; // Placeholder
  int _totalChants = 1250; // Placeholder
  String _dailyInsight = "Quiet the mind, and the soul will speak.";

  final List<String> _insights = [
    "Quiet the mind, and the soul will speak.",
    "Your breath is the bridge between body and spirit.",
    "Peace comes from within. Do not seek it without.",
    "The mantra is not just words; it is a vibration of the universe.",
    "Consistency in Sadhana is the key to transformation.",
    "Every chant is a step towards your higher self.",
  ];

  int get streak => _streak;
  int get totalChants => _totalChants;
  String get dailyInsight => _dailyInsight;

  void refreshInsight() {
    final random = Random();
    _dailyInsight = _insights[random.nextInt(_insights.length)];
    notifyListeners();
  }

  void incrementChants(int count) {
    _totalChants += count;
    notifyListeners();
  }
}
