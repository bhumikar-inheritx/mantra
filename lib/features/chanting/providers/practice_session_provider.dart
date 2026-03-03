import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chanting_session_model.dart';
import '../../../data/models/mantra_model.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';

class PracticeSessionProvider extends ChangeNotifier {
  MantraModel? _selectedMantra;
  int _targetCount = 108;
  String? _selectedSankalp;
  ChantMode _selectedMode = ChantMode.audio;
  DateTime? _sessionStartTime;
  bool _isSessionActive = false;
  Duration _sessionDuration = Duration.zero;
  Timer? _timer;

  MantraModel? get selectedMantra => _selectedMantra;
  int get targetCount => _targetCount;
  String? get selectedSankalp => _selectedSankalp;
  ChantMode get selectedMode => _selectedMode;
  DateTime? get sessionStartTime => _sessionStartTime;
  bool get isSessionActive => _isSessionActive;
  Duration get sessionDuration => _sessionDuration;

  void selectMantra(MantraModel mantra) {
    _selectedMantra = mantra;
    notifyListeners();
  }

  void setSankalp(String sankalp) {
    _selectedSankalp = sankalp;
    notifyListeners();
  }

  void setMode(ChantMode mode) {
    _selectedMode = mode;
    notifyListeners();
  }

  void setTargetCount(int count) {
    _targetCount = count;
    notifyListeners();
  }

  void startSession() {
    _sessionStartTime = DateTime.now();
    _isSessionActive = true;
    _sessionDuration = Duration.zero;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void completeSession(BuildContext context, int totalChants) {
    _isSessionActive = false;
    _timer?.cancel();
    
    // Save to dashboard
    context.read<DashboardProvider>().addChantsForToday(totalChants);
    
    notifyListeners();
  }

  void resetSession() {
    _isSessionActive = false;
    _sessionStartTime = null;
    _sessionDuration = Duration.zero;
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

extension TimeFormatting on Duration {
  String formatMMSS() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
