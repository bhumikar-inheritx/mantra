import 'package:flutter/material.dart';
import '../../../shared/providers/audio_player_provider.dart';
import '../../chanting/providers/audio_chant_provider.dart';
import '../../chanting/providers/practice_session_provider.dart';
import '../../../core/theme/app_sizes.dart';

class MiniPlayerProvider extends ChangeNotifier {
  static double get height => AppSizes.miniPlayerHeight;
  bool _isPracticeModeActive = false;
  bool _isForceHidden = false;
  bool _isFullPlayerVisible = false;
  bool _isExpanding = false;

  bool get isPracticeModeActive => _isPracticeModeActive;
  bool get isForceHidden => _isForceHidden;
  bool get isFullPlayerVisible => _isFullPlayerVisible;
  bool get isExpanding => _isExpanding;

  bool showMiniPlayer(
    AudioPlayerProvider audio,
    AudioChantProvider chant,
    PracticeSessionProvider practice,
  ) {
    if (_isForceHidden || _isFullPlayerVisible) return false;
    
    final bool isPracticing = chant.isPlaying ||
        chant.currentCount > 0 ||
        practice.isSessionActive;
    
    // Only show the mini player when the global audio player is actively
    // playing and no chanting/practice session is running. This avoids
    // showing the bar on onboarding/home when audio is merely preloaded.
    return audio.isPlaying && !isPracticing;
  }

  void setIsExpanding(bool expanding) {
    if (_isExpanding != expanding) {
      _isExpanding = expanding;
      notifyListeners();
    }
  }

  void setFullPlayerVisible(bool visible) {
    if (_isFullPlayerVisible != visible) {
      _isFullPlayerVisible = visible;
      _isExpanding = false; // Reset expanding when visibility is confirmed
      notifyListeners();
    }
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


  void show() {
    setPracticeMode(false);
    setForceHidden(false);
  }

  void hide() {
    setPracticeMode(true);
  }
}
