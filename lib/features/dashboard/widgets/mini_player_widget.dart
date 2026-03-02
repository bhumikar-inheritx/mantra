import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/audio_provider.dart';
import '../../../shared/providers/muhurta_provider.dart';

class DeepMantraMiniPlayer extends StatelessWidget {
  const DeepMantraMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final muhurta = Provider.of<MuhurtaProvider>(context);

    // Only show if audio is playing or has a valid source
    if (!audioProvider.isPlaying &&
        audioProvider.player.processingState == ProcessingState.idle) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  muhurta.accentColor.withValues(alpha: 0.2),
                  (muhurta.isDarkPhase ? Colors.black : Colors.white)
                      .withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Icon / Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: muhurta.accentColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.music_note_rounded,
                    color: muhurta.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Track Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SACRED MANTRA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        audioProvider.currentMode == AudioMode.listen
                            ? "Listening: ${audioProvider.currentLoopCount}/${audioProvider.targetLoopCount}"
                            : "Manual Practice",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Indicator (Mini)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value:
                        audioProvider.player.position.inMilliseconds /
                        (audioProvider.player.duration?.inMilliseconds ?? 1),
                    strokeWidth: 2,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      muhurta.accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Play/Pause Control
                GestureDetector(
                  onTap: () => audioProvider.togglePlay(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: muhurta.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),

                // Close button
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 18,
                  ),
                  onPressed: () => audioProvider.stop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
