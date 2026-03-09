import 'dart:async';
import 'package:flutter/material.dart';

enum QuickRitualType { morning, peace, protection, sleep }

class RitualData {
  final String title;
  final String quote;
  final int durationSeconds;
  final Color primaryColor;
  final Color secondaryColor;

  RitualData({
    required this.title,
    required this.quote,
    required this.durationSeconds,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

class QuickRitualProvider extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isActive = false;
  QuickRitualType? _currentRitualType;

  Timer? get timer => _timer;
  int get remainingSeconds => _remainingSeconds;
  bool get isActive => _isActive;
  QuickRitualType? get currentRitualType => _currentRitualType;
  
  // Ritual Data mapping
  final Map<QuickRitualType, RitualData> _ritualDataMap = {
    QuickRitualType.morning: RitualData(
      title: "Morning Awakening",
      quote: "Breathe in the new day. Let go of yesterday.",
      durationSeconds: 3 * 60,
      primaryColor: const Color(0xFFFDB813), // Sun yellow
      secondaryColor: const Color(0xFFFF8C00), // Orange
    ),
    QuickRitualType.peace: RitualData(
      title: "Inner Peace",
      quote: "Find stillness in the breath. You are safe.",
      durationSeconds: 5 * 60,
      primaryColor: const Color(0xFF00CED1), // Dark cyan
      secondaryColor: const Color(0xFF4682B4), // Steel blue
    ),
    QuickRitualType.protection: RitualData(
      title: "Aura of Protection",
      quote: "Visualize a shield of light surrounding you.",
      durationSeconds: 2 * 60,
      primaryColor: const Color(0xFFB22222), // Firebrick red
      secondaryColor: const Color(0xFF8B0000), // Dark red
    ),
    QuickRitualType.sleep: RitualData(
      title: "Restful Sleep",
      quote: "Release your thoughts to the night sky.",
      durationSeconds: 10 * 60,
      primaryColor: const Color(0xFF191970), // Midnight blue
      secondaryColor: const Color(0xFF483D8B), // Dark slate blue
    ),
  };

  RitualData? get currentRitualData => _currentRitualType != null ? _ritualDataMap[_currentRitualType] : null;

  String get formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void startRitual(QuickRitualType type) {
    _currentRitualType = type;
    final data = _ritualDataMap[type]!;
    _remainingSeconds = data.durationSeconds;
    _isActive = true;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        stopRitual();
      }
    });
  }

  void pauseRitual() {
    _isActive = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeRitual() {
    if (_remainingSeconds > 0) {
      _isActive = true;
      _startTimer();
      notifyListeners();
    }
  }

  void stopRitual() {
    _isActive = false;
    _timer?.cancel();
    _currentRitualType = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
