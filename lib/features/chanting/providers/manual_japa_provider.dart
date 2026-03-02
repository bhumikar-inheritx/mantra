import 'package:flutter/material.dart';
import '../services/haptic_service.dart';

class ManualJapaProvider extends ChangeNotifier {
  final HapticService _hapticService;
  
  int _currentCount = 0;
  int _targetCount = 108;
  int _totalReps = 0;
  int _cycleCount = 0;
  bool _isCompleted = false;
  
  ManualJapaProvider(this._hapticService);

  int get currentCount => _currentCount;
  int get targetCount => _targetCount;
  int get totalReps => _totalReps;
  int get cycleCount => _cycleCount;
  bool get isCompleted => _isCompleted;
  double get progressPercentage => _currentCount / (_targetCount > 0 ? _targetCount : 1);

  void initialize(int target) {
    _targetCount = target;
    _currentCount = 0;
    _totalReps = 0;
    _cycleCount = 0;
    _isCompleted = false;
    notifyListeners();
  }

  Future<void> incrementCount() async {
    _currentCount++;
    _totalReps++;
    
    await _hapticService.lightImpact();

    if (_currentCount >= _targetCount) {
      _currentCount = 0;
      _cycleCount++;
      await _hapticService.success(); // Stronger feedback on cycle completion
    }
    
    notifyListeners();
  }

  void reset() {
    _currentCount = 0;
    _isCompleted = false;
    notifyListeners();
  }
}
