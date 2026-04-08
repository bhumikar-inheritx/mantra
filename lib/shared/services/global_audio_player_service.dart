import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../data/models/mantra_model.dart';
import 'local_artwork_resolver.dart';

/// Global audio player service for normal mantra listening and the mini player.
/// Uses the just_audio package for background playback and lock screen controls.
class GlobalAudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get rawPlayer => _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> setSource(MantraModel mantra) async {
    final url = mantra.audioUrl;
    final artUri = await LocalArtworkResolver.resolve(
      mantra.imageUrl,
      cacheKey: mantra.id,
    );
    final mediaItem = MediaItem(
      id: mantra.id,
      album: mantra.category,
      title: mantra.title,
      artUri: artUri,
    );

    if (url.startsWith('assets/')) {
      await _player.setAudioSource(
        AudioSource.asset(url, tag: mediaItem),
      );
    } else {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url), tag: mediaItem),
      );
    }
  }

  /// Set source from a raw URL (e.g., onboarding)
  Future<void> setUrlSource(String url, {String? title}) async {
    final mediaItem = MediaItem(
      id: url,
      album: 'Application',
      title: title ?? 'Audio',
    );

    if (url.startsWith('assets/')) {
      await _player.setAudioSource(
        AudioSource.asset(url, tag: mediaItem),
      );
    } else {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url), tag: mediaItem),
      );
    }
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

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

