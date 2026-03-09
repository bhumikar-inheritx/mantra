import 'package:audioplayers/audioplayers.dart';

/// Global audio player service for normal mantra listening and the mini player.
/// Uses the audioplayers package for low-latency play/pause/seek on local assets.
class GlobalAudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get rawPlayer => _player;

  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<Duration?> get durationStream => _player.onDurationChanged;
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  Future<void> setSource(String url) async {
    if (url.startsWith('assets/')) {
      // audioplayers' setSourceAsset automatically prepends 'assets/',
      // so strip it from our path to avoid "assets/assets/..." duplication.
      final assetPath = url.substring('assets/'.length);
      await _player.setSourceAsset(assetPath);
    } else {
      await _player.setSourceUrl(url);
    }
  }

  Future<void> play() async {
    // If playback has already completed, seek back to the beginning so
    // that subsequent "play" actions restart the mantra cleanly.
    if (_player.state == PlayerState.completed) {
      await _player.seek(Duration.zero);
    }

    await _player.resume();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setPlaybackRate(speed);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

