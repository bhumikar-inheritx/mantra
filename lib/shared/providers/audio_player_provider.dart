import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/mantra_model.dart';
import '../../features/chanting/services/audio_player_service.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;

  MantraModel? _currentTrack;
  bool _isPlaying = false;

  AudioPlayerProvider(this._audioService) {
    _init();
  }

  MantraModel? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  AudioPlayer get player => _audioService.player;

  void _init() {
    _audioService.player.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _audioService.player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _isPlaying = false;
        notifyListeners();
      }
    });
  }

  Future<void> playTrack(MantraModel track) async {
    _currentTrack = track;
    notifyListeners();
    await playUrl(track.audioUrl);
  }

  Future<void> playUrl(String url) async {
    await _audioService.stop();
    await _audioService.setSource(url);
    await _audioService.setLoopMode(LoopMode.off);
    await _audioService.play();
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      if (_currentTrack != null) {
        await _audioService.play();
      }
    }
  }

  Future<void> stop() async {
    await _audioService.stop();
    _currentTrack = null;
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
