import 'dart:async';
import 'package:flutter/services.dart';

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
    // Clear old subscriptions
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    _targetCount = target;
    _currentCount = 0;
    _progressPercentage = 0.0;

    final bool isJustListen = target <= 0;

    AudioSource source;
    if (isJustListen) {
      source = url.startsWith('assets/')
          ? AudioSource.asset(url)
          : AudioSource.uri(Uri.parse(url));
    } else {
      source = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: List.generate(
          target,
          (_) => url.startsWith('assets/')
              ? AudioSource.asset(url)
              : AudioSource.uri(Uri.parse(url)),
        ),
      );
    }

    // Sync playing state from the source of truth
    _subscriptions.add(
      _audioService.player.playingStream.listen((playing) {
        _isPlaying = playing;
        notifyListeners();
      }),
    );

    // Track count via current index
    _subscriptions.add(
      _audioService.player.currentIndexStream.listen((index) {
        if (!isJustListen && index != null) {
          final newCount = index + 1;
          if (newCount != _currentCount) {
            _currentCount = newCount;
            HapticFeedback.lightImpact();
            notifyListeners();
          }
        }
      }),
    );

    // Handle completion
    _subscriptions.add(
      _audioService.player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _currentCount = _targetCount;
          notifyListeners();
        }
      }),
    );

    // Track progress of current bead
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

    await _audioService.setAudioSource(source);
    await _audioService.setLoopMode(isJustListen ? LoopMode.one : LoopMode.off);
    await _audioService.setSpeed(_playbackSpeed);
  }

  Future<void> togglePlay() async {
    if (_audioService.player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    if (_targetCount > 0 && _currentCount >= _targetCount && _audioService.player.processingState == ProcessingState.completed) {
       // Optional: reset or just return
       return;
    }
    await _audioService.play();
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> stop() async {
    await _audioService.stop();
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
    // Don't stop service if it's shared, but here it seems scoped.
    _audioService.stop();
    super.dispose();
  }
}
