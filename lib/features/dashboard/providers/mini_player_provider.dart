import 'package:flutter/material.dart';
import '../../../shared/providers/audio_player_provider.dart';
import '../../chanting/providers/audio_chant_provider.dart';
import '../../chanting/providers/practice_session_provider.dart';
import '../../../core/theme/app_sizes.dart';

class MiniPlayerProvider extends ChangeNotifier {
  static double get height => AppSizes.miniPlayerHeight;
  bool _isPracticeModeActive = false;
  bool _isForceHidden = false;
  double _bottomOffset = 0.0;

  bool get isPracticeModeActive => _isPracticeModeActive;
  bool get isForceHidden => _isForceHidden;
  double get bottomOffset => _bottomOffset;

  bool showMiniPlayer(
    AudioPlayerProvider audio,
    AudioChantProvider chant,
    PracticeSessionProvider practice,
  ) {
    if (_isForceHidden) return false;
    
    final bool isPracticing = chant.isPlaying ||
        chant.currentCount > 0 ||
        practice.isSessionActive;
        
    return audio.currentTrack != null && !isPracticing;
  }

  void setPracticeMode(bool isActive) {
    if (_isPracticeModeActive != isActive) {
      _isPracticeModeActive = isActive;
      notifyListeners();
    }
  }

  void setForceHidden(bool hidden) {
    if (_isForceHidden != hidden) {
      _isForceHidden = hidden;
      notifyListeners();
    }
  }

  void setBottomOffset(double offset) {
    if (_bottomOffset != offset) {
      _bottomOffset = offset;
      notifyListeners();
    }
  }

  void show() {
    setPracticeMode(false);
    setForceHidden(false);
  }

  void hide() {
    setPracticeMode(true);
  }
}
