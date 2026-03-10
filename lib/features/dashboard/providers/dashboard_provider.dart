import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/insight_model.dart';
import '../../../core/utils/insight_engine.dart';

class DashboardProvider extends ChangeNotifier {
  int _streak = 5; 
  int _totalChants = 1250;
  
  // History: "YYYY-MM-DD" -> count
  final Map<String, int> _history = {
    "2026-03-01": 108,
    "2026-02-28": 216,
    "2026-02-27": 108,
    "2026-02-25": 108,
    "2026-02-24": 324,
  };
  
  SpiritualInsight _currentInsight = const SpiritualInsight(
    title: "Inner Peace",
    titleHindi: "आंतरिक शांति",
    verse: "अशान्तस्य कुतः सुखम्।",
    translation: "For one who is not peaceful, how can there be happiness?",
    translationHindi: "अशांत व्यक्ति को सुख कहाँ मिल सकता है?",
    context: "Prioritize your inner stillness above all external goals.",
    contextHindi: "सभी बाहरी लक्ष्यों से ऊपर अपनी आंतरिक स्थिरता को प्राथमिकता दें।",
  );

  int get streak => _streak;
  int get totalChants => _totalChants;
  SpiritualInsight get dailyInsight => _currentInsight;
  Map<String, int> get history => _history;

  void refreshInsight(String? mood, String? goal, String? deity) {
    _currentInsight = InsightEngine.getInsight(mood, goal, deity);
    notifyListeners();
  }

  void addChantsForToday(int count) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _history[today] = (_history[today] ?? 0) + count;
    _totalChants += count;
    
    // In a real app, logic for streak calculation would go here
    notifyListeners();
  }

  /// Returns activity for the last 30 days
  List<int> getRecentActivity() {
    final List<int> activity = [];
    final now = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      activity.add(_history[dateStr] ?? 0);
    }
    return activity;
  }
}
