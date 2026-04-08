import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../data/models/mantra_model.dart';
import '../../../shared/services/local_artwork_resolver.dart';
import '../services/audio_player_service.dart';

class AudioChantProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;

  bool _isPlaying = false;
  int _currentCount = 0;
  int _targetCount = 108;
  double _playbackSpeed = 1.0;
  double _progressPercentage = 0.0;
  final List<StreamSubscription> _subscriptions = [];

  double _savedVolume = 1.0;

  // Guard window to ignore stale hardware events right after a user command
  DateTime? _lastCommandTime;
  static const _commandGuardDuration = Duration(milliseconds: 500);

  AudioChantProvider(this._audioService);

  bool get isPlaying => _isPlaying;
  int get currentCount => _currentCount;
  int get targetCount => _targetCount;
  double get playbackSpeed => _playbackSpeed;
  double get progressPercentage => _progressPercentage;

  bool _isGuarded() {
    if (_lastCommandTime == null) return false;
    return DateTime.now().difference(_lastCommandTime!) < _commandGuardDuration;
  }

  void _updateCommandTime() {
    _lastCommandTime = DateTime.now();
  }

  Future<void> initialize(MantraModel mantra, int target) async {
    // Clear old subscriptions
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    final url = mantra.audioUrl;
    _targetCount = target;
    _currentCount = 0;
    _progressPercentage = 0.0;
    _isPlaying = false;

    final bool isJustListen = target <= 0;

    final artUri = await LocalArtworkResolver.resolve(
      mantra.imageUrl,
      cacheKey: mantra.id,
    );
    final mediaItem = MediaItem(
      id: mantra.id,
      album: mantra.category,
      title: mantra.title,
      artist: 'Deep Mantra',
      artUri: artUri,
    );
    debugPrint('Background Audio MediaItem: ${mediaItem.title}, ArtUri: ${mediaItem.artUri}');

    AudioSource source;
    if (isJustListen) {
      source = url.startsWith('assets/')
          ? AudioSource.asset(url, tag: mediaItem)
          : AudioSource.uri(Uri.parse(url), tag: mediaItem);
    } else {
      source = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: List.generate(
          target,
          (_) => url.startsWith('assets/')
              ? AudioSource.asset(url, tag: mediaItem)
              : AudioSource.uri(Uri.parse(url), tag: mediaItem),
        ),
      );
    }

    // Sync playing state from the source of truth
    _subscriptions.add(
      _audioService.player.playingStream.listen((playing) {
        if (_isGuarded()) return;
        if (_isPlaying != playing) {
          _isPlaying = playing;
          notifyListeners();
        }
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
        if (_isGuarded()) return;
        if (state == ProcessingState.completed) {
          _currentCount = _targetCount;
          _isPlaying = false;
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

  /// Toggle play/pause with optimistic UI and fire-and-forget native calls.
  Future<void> togglePlay() async {
    final targetState = !_audioService.player.playing;

    // Immediate UI update
    _updateCommandTime();
    _isPlaying = targetState;
    notifyListeners();

    // Fire native command without blocking the UI
    final player = _audioService.player;

    if (targetState) {
      player.setVolume(_savedVolume);
      unawaited(player.play());
    } else {
      _savedVolume = player.volume;
      player.setVolume(0);
      unawaited(player.pause());
    }
  }

  Future<void> play() async {
    if (_targetCount > 0 &&
        _currentCount >= _targetCount &&
        _audioService.player.processingState == ProcessingState.completed) {
      return;
    }

    _updateCommandTime();
    _isPlaying = true;
    notifyListeners();
    unawaited(_audioService.player.play());
  }

  Future<void> pause() async {
    _updateCommandTime();
    _isPlaying = false;
    notifyListeners();
    unawaited(_audioService.player.pause());
  }

  Future<void> stop() async {
    _updateCommandTime();
    _isPlaying = false;
    _currentCount = 0;
    _progressPercentage = 0.0;

    // Clear subscriptions to prevent trailing stream events (e.g. from currentIndexStream)
    // from incorrectly updating _currentCount or _isPlaying after stop is called.
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    notifyListeners();
    await _audioService.stop();
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
