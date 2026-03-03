import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> setSource(String url) async {
    if (url.startsWith('assets/')) {
      await _player.setAudioSource(AudioSource.asset(url));
    } else {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    }
  }

  Future<void> setAudioSource(AudioSource source) async {
    await _player.setAudioSource(source);
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
