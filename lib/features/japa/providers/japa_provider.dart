import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JapaProvider extends ChangeNotifier {
  int _currentCount = 0;
  int _totalReps = 0;
  int _targetReps = 108;
  String? _currentSankalp;
  bool _isSessionActive = false;
  
  Timer? _timer;
  int _sessionSeconds = 0;

  int get currentCount => _currentCount;
  int get totalReps => _totalReps;
  int get targetReps => _targetReps;
  String? get currentSankalp => _currentSankalp;
  bool get isSessionActive => _isSessionActive;
  int get sessionSeconds => _sessionSeconds;

  void startSession(String sankalp, int target) {
    _currentSankalp = sankalp;
    _targetReps = target;
    _currentCount = 0;
    _totalReps = 0;
    _sessionSeconds = 0;
    _isSessionActive = true;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionSeconds++;
      notifyListeners();
    });
  }

  void incrementCount() {
    if (!_isSessionActive) return;
    
    _currentCount++;
    _totalReps++;
    
    // Simulate haptic feedback
    HapticFeedback.lightImpact();

    if (_currentCount >= _targetReps) {
      _currentCount = 0;
      HapticFeedback.heavyImpact(); // Stronger feedback on completion of a cycle
    }
    
    notifyListeners();
  }

  void stopSession() {
    _isSessionActive = false;
    _timer?.cancel();
    notifyListeners();
  }

  String get formattedTime {
    final minutes = (_sessionSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_sessionSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
