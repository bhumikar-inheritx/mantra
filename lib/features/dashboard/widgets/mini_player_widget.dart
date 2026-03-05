import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../shared/providers/audio_player_provider.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../../../shared/widgets/normal_media_player_screen.dart';
import '../../chanting/providers/audio_chant_provider.dart';
import '../../chanting/providers/practice_session_provider.dart';
import '../providers/mini_player_provider.dart';

class DeepMantraMiniPlayer extends StatelessWidget {
  const DeepMantraMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final miniPlayerProvider = Provider.of<MiniPlayerProvider>(context);
    final chantProvider = Provider.of<AudioChantProvider>(context);
    final practiceSession = Provider.of<PracticeSessionProvider>(context);
    final muhurta = Provider.of<MuhurtaProvider>(context);

    // Use centralized logic from provider
    final bool shouldShow = miniPlayerProvider.showMiniPlayer(
      audioProvider,
      chantProvider,
      practiceSession,
    );

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final track = audioProvider.currentTrack;

    if (track == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NormalMediaPlayerScreen(track: track!),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingSm),
        height: AppSizes.miniPlayerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.r, sigmaY: 10.r),
            child: Container(
              decoration: BoxDecoration(
                color: (muhurta.isDarkPhase ? Colors.black87 : Colors.white)
                    .withValues(alpha: 0.9),
                border: Border.all(
                  color: (muhurta.isDarkPhase ? Colors.white : Colors.black)
                      .withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Artwork Thumbnail
                        Container(
                          width: AppSizes.iconXl,
                          height: AppSizes.iconXl,
                          margin: EdgeInsets.only(
                            left: AppSizes.paddingSm,
                            right: 12.w,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                            child: Image.asset(
                              track!.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Title and Subtitle
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track!.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: muhurta.primaryTextColor,
                                  fontSize: AppSizes.fontBody,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                track!.deity,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: muhurta.secondaryTextColor,
                                  fontSize: AppSizes.fontSm,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Play / Pause Button
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            audioProvider.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: muhurta.primaryTextColor,
                            size: AppSizes.iconLg,
                          ),
                          onPressed: () => audioProvider.togglePlay(),
                        ),

                        // Close Button
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: muhurta.secondaryTextColor,
                            size: AppSizes.iconMd,
                          ),
                          onPressed: () => audioProvider.stop(),
                        ),
                        SizedBox(width: 4.w),
                      ],
                    ),
                  ),

                  // Thin Progress Bar
                  StreamBuilder<Duration>(
                    stream: audioProvider.player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration =
                          audioProvider.player.duration ?? Duration.zero;

                      double progress = 0.0;
                      if (duration.inMilliseconds > 0) {
                        progress =
                            position.inMilliseconds / duration.inMilliseconds;
                        progress = progress.clamp(0.0, 1.0);
                      }

                      return LinearProgressIndicator(
                        value: progress,
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          muhurta.accentColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
