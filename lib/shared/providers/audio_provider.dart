import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

enum AudioMode { listen, practice }

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final StreamController<int> _countController = StreamController<int>.broadcast();
  
  AudioMode _currentMode = AudioMode.practice;
  int _targetLoopCount = 108;
  int _currentLoopCount = 0;
  bool _isPlaying = false;
  String? _currentAudioUrl;

  AudioPlayer get player => _player;
  Stream<int> get countStream => _countController.stream;
  AudioMode get currentMode => _currentMode;
  int get targetLoopCount => _targetLoopCount;
  int get currentLoopCount => _currentLoopCount;
  bool get isPlaying => _isPlaying;

  AudioProvider() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleTrackCompletion();
      }
      notifyListeners();
    });

    _player.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });
  }

  void setMode(AudioMode mode) {
    _currentMode = mode;
    if (mode == AudioMode.practice) {
      stop();
    }
    notifyListeners();
  }

  void setTargetCount(int count) {
    _targetLoopCount = count;
    notifyListeners();
  }

  Future<void> playMantra(String url, {bool loop = false}) async {
    try {
      if (_currentAudioUrl != url) {
        _currentAudioUrl = url;
        await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      }
      
      _currentLoopCount = 0;
      if (loop) {
        await _player.setLoopMode(LoopMode.one);
      } else {
        await _player.setLoopMode(LoopMode.off);
      }
      
      await _player.play();
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _handleTrackCompletion() {
    if (_currentMode == AudioMode.listen) {
      _currentLoopCount++;
      _countController.add(_currentLoopCount);
      if (_currentLoopCount >= _targetLoopCount) {
        stop();
      } else {
        _player.seek(Duration.zero);
        _player.play();
      }
    }
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentLoopCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
