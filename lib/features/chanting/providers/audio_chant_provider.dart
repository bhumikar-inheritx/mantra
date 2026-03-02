import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/audio_player_service.dart';

class AudioChantProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;

  bool _isPlaying = false;
  int _currentCount = 0;
  int _targetCount = 108;
  double _playbackSpeed = 1.0;
  double _progressPercentage = 0.0;
  List<StreamSubscription> _subscriptions = [];

  AudioChantProvider(this._audioService);

  bool get isPlaying => _isPlaying;
  int get currentCount => _currentCount;
  int get targetCount => _targetCount;
  double get playbackSpeed => _playbackSpeed;
  double get progressPercentage => _progressPercentage;

  Future<void> initialize(String url, int target) async {
    // _audioUrl = url;
    _targetCount = target;
    _currentCount = 0;
    _progressPercentage = 0.0;

    await _audioService.setSource(url);
    await _audioService.setLoopMode(
      LoopMode.off,
    ); // Handle looping manually to count reliably

    // Listen to position updates for progress percentage
    _subscriptions.add(
      _audioService.player.positionStream.listen((position) {
        final duration = _audioService.player.duration;
        if (duration != null && duration.inMilliseconds > 0) {
          _progressPercentage =
              (position.inMilliseconds / duration.inMilliseconds).clamp(
                0.0,
                1.0,
              );
          notifyListeners();
        }
      }),
    );

    // Listen to processing state for manual looping
    _subscriptions.add(
      _audioService.player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _handleLoopCompleted();
        }
      }),
    );
  }

  Future<void> _handleLoopCompleted() async {
    _currentCount++;
    if (_currentCount < _targetCount) {
      await _audioService.player.seek(Duration.zero);
      await play();
    } else {
      await pause();
      _currentCount = _targetCount;
    }
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    if (_currentCount >= _targetCount) return;
    await _audioService.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioService.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    _playbackSpeed = speed;
    await _audioService.setSpeed(speed);
    notifyListeners();
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _audioService.stop();
    super.dispose();
  }
}
