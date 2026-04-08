import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/mantra_model.dart';
import '../services/global_audio_player_service.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final GlobalAudioPlayerService _audioService;

  MantraModel? _currentTrack;
  bool _isPlaying = false;
  String?
  _loadedUrl; // Track which URL is currently loaded to avoid redundant setSource
  DateTime? _lastCommandTime;
  static const _commandGuardDuration = Duration(milliseconds: 500);

  // Remember the user's effective volume so we can
  // instantly "mute" on pause without changing it.
  double _savedVolume = 1.0;

  Duration _duration = Duration.zero;

  bool _isGuarded() {
    if (_lastCommandTime == null) return false;
    return DateTime.now().difference(_lastCommandTime!) < _commandGuardDuration;
  }

  void _updateCommandTime() {
    _lastCommandTime = DateTime.now();
  }

  AudioPlayerProvider(this._audioService) {
    _init();
  }

  MantraModel? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;

  Stream<Duration> get positionStream => _audioService.positionStream;

  void _init() {
    // Listen to player state for UI state.
    _audioService.playerStateStream.listen((state) {
      if (_isGuarded()) return;
      final playing = state.playing;
      if (_isPlaying != playing) {
        _isPlaying = playing;
        notifyListeners();
      }
    });

    // Track duration updates.
    _audioService.durationStream.listen((d) {
      if (d != null && d != _duration) {
        _duration = d;
        notifyListeners();
      }
    });
  }

  /// Load and play a new track. Only calls setSource if the URL has changed.
  Future<void> playTrack(MantraModel track) async {
    try {
      final isSameTrack =
          _currentTrack?.audioUrl == track.audioUrl &&
          _loadedUrl == track.audioUrl;
      final processingState = _audioService.rawPlayer.processingState;

      // If the underlying player has completed or been fully stopped,
      // we must reload the source even if it's the same mantra, otherwise
      // Android's MediaPlayer will silently refuse to start again.
      final shouldReload =
          !isSameTrack || processingState == ProcessingState.completed;

      // Optimistically update UI immediately
      _updateCommandTime();
      _currentTrack = track;
      _isPlaying = true;
      notifyListeners();

      if (shouldReload) {
        // Stop the current track cleanly before loading/reloading source
        await _audioService.stop();
        _loadedUrl = null;

        // Load (or reload) the source
        await _audioService.setSource(track);
        _loadedUrl = track.audioUrl;
      }

      // Ensure volume is audible before starting (guard against previous soft-mute).
      final player = _audioService.rawPlayer;
      if (player.volume == 0) {
        player.setVolume(_savedVolume);
      }

      // Now play — this is instant since the source is ready
      unawaited(_audioService.play());
    } catch (e) {
      _isPlaying = false;
      notifyListeners();
      debugPrint('Error playing track: $e');
    }
  }

  /// Play a raw audio URL (no MantraModel — used by onboarding, etc.)
  Future<void> playUrl(String url) async {
    try {
      final isSameUrl = _loadedUrl == url;
      final processingState = _audioService.rawPlayer.processingState;

      final shouldReload =
          !isSameUrl || processingState == ProcessingState.completed;

      _updateCommandTime();
      _isPlaying = true;
      notifyListeners();

      if (shouldReload) {
        await _audioService.stop();
        _loadedUrl = null;
        await _audioService.setUrlSource(url);
        _loadedUrl = url;
      }

      // Ensure volume is audible before starting (guard against previous soft-mute).
      final player = _audioService.rawPlayer;
      if (player.volume == 0) {
        player.setVolume(_savedVolume);
      }

      unawaited(_audioService.play());
    } catch (e) {
      _isPlaying = false;
      notifyListeners();
      debugPrint('Error playing URL $url: $e');
    }
  }

  /// Load a new track without playing it.
  Future<void> loadTrack(MantraModel track) async {
    try {
      final isSameTrack =
          _currentTrack?.audioUrl == track.audioUrl &&
          _loadedUrl == track.audioUrl;

      _updateCommandTime();
      _currentTrack = track;
      _isPlaying = false; // Ensure it stays paused
      notifyListeners();

      if (!isSameTrack) {
        await _audioService.stop();
        _loadedUrl = null;
        await _audioService.setSource(track);
        _loadedUrl = track.audioUrl;
      }

      // Explicitly pause to be sure
      unawaited(_audioService.pause());
    } catch (e) {
      debugPrint('Error loading track: $e');
    }
  }

  /// Load a raw audio URL without playing it.
  Future<void> loadUrl(String url) async {
    try {
      final isSameUrl = _loadedUrl == url;

      _updateCommandTime();
      _isPlaying = false;
      notifyListeners();

      if (!isSameUrl) {
        await _audioService.stop();
        _loadedUrl = null;
        await _audioService.setUrlSource(url);
        _loadedUrl = url;
      }

      unawaited(_audioService.pause());
    } catch (e) {
      debugPrint('Error loading URL $url: $e');
    }
  }

  /// Toggle play/pause with zero UI latency.
  /// The UI updates instantly via optimistic state; the native call is fire-and-forget.
  void togglePlay() {
    if (_currentTrack == null) return;

    final player = _audioService.rawPlayer;
    final targetState = !_isPlaying;

    // Immediately update UI
    _updateCommandTime();
    _isPlaying = targetState;
    notifyListeners();

    // Fire native command — don't await, don't block UI.
    // On pause we "soft mute" immediately so the user hears
    // an instant stop even if the underlying pause is slow.
    if (targetState) {
      // If the player had fully completed or been stopped, do a clean
      // replay via playTrack so the source is reloaded and audio focus
      // is reacquired correctly on Android.
      if (player.processingState == ProcessingState.completed) {
        unawaited(playTrack(_currentTrack!));
        return;
      }

      // Normal resume case: just restore volume and play.
      player.setVolume(_savedVolume);
      unawaited(_audioService.play());
    } else {
      _savedVolume = player.volume;
      player.setVolume(0);
      unawaited(_audioService.pause());
    }
  }

  /// Seek to a position. Instant UI, fire-and-forget native seek.
  void seekTo(Duration position) {
    unawaited(_audioService.seek(position));
  }

  /// Stop playback and clear the current track.
  Future<void> stop() async {
    _updateCommandTime();
    // Restore the user's volume before pausing, so that the next
    // "listen normally" start is not silently muted.
    final player = _audioService.rawPlayer;
    if (player.volume == 0) {
      player.setVolume(_savedVolume);
    } else {
      _savedVolume = player.volume;
    }

    unawaited(_audioService.pause()); // Pause rather than stop for speed
    _currentTrack = null;
    _loadedUrl = null;
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
