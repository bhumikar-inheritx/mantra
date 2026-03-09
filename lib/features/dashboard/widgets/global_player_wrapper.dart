import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/audio_player_provider.dart';
import '../../chanting/providers/audio_chant_provider.dart';
import '../../chanting/providers/practice_session_provider.dart';
import '../providers/mini_player_provider.dart';
import 'mini_player_widget.dart';

class GlobalMiniPlayerWrapper extends StatelessWidget {
  final Widget child;

  const GlobalMiniPlayerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Builder(
              builder: (context) {
                final audio = context.read<AudioPlayerProvider>();
                final chant = context.watch<AudioChantProvider>();
                final practice = context.watch<PracticeSessionProvider>();
                final miniPlayer = context.watch<MiniPlayerProvider>();

                // We use context.select for the most frequent state (audio track)
                // but actually, after the provider fix, this will already be much faster.
                // Let's use context.select for the track specifically.
                final hasTrack = context.select<AudioPlayerProvider, bool>(
                  (p) => p.currentTrack != null,
                );

                final bool shouldShow = miniPlayer.showMiniPlayer(
                  audio,
                  chant,
                  practice,
                ) && hasTrack;

                if (!shouldShow) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(bottom: miniPlayer.bottomOffset),
                  child: const DeepMantraMiniPlayer(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
