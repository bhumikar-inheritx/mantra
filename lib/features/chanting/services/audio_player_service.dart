import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> setSource(String url) async {
    try {
      if (url.startsWith('assets/')) {
        // Actually, just encoding the whole thing after 'assets/' is safer.
        final path = url.replaceFirst('assets/', '');
        final encodedPath = Uri.encodeFull(path);
        final finalUrl = 'assets/$encodedPath';
        
        debugPrint('Playing asset: $finalUrl');
        // Add preload: true to force aggressive buffering and decoding before play() is called.
        await _player.setAudioSource(
          AudioSource.asset(finalUrl), 
          preload: true,
        );
      } else {
        debugPrint('Playing URL: $url');
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(url)),
          preload: true,
        );
      }
    } catch (e) {
      debugPrint('Error setting audio source: $e');
      rethrow;
    }
  }

  Future<void> setAudioSource(AudioSource source) async {
    // Preload chanting sources as well so they are fully buffered
    // before playback, reducing latency when starting or seeking.
    await _player.setAudioSource(source, preload: true);
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> seek(Duration duration) async {
    await _player.seek(duration);
  }

  void dispose() {
    _player.dispose();
  }
}
