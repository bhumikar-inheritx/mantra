import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../data/models/mantra_model.dart';
import '../../../main.dart';
import '../../../shared/providers/audio_player_provider.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../../../shared/widgets/normal_media_player_screen.dart';
import '../providers/mini_player_provider.dart';

class DeepMantraMiniPlayer extends StatelessWidget {
  const DeepMantraMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get stationary state with Selectors to minimize rebuilds
    final track = context.select<AudioPlayerProvider, MantraModel?>(
      (p) => p.currentTrack,
    );
    final isPlaying = context.select<AudioPlayerProvider, bool>(
      (p) => p.isPlaying,
    );
    final muhurta = context.watch<MuhurtaProvider>();

    if (track == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        final miniProvider = context.read<MiniPlayerProvider>();
        // Guard against fast-taps or duplicate pushes
        if (miniProvider.isFullPlayerVisible || miniProvider.isExpanding) {
          return;
        }

        miniProvider.setIsExpanding(true);

        navigatorKey.currentState
            ?.push(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    NormalMediaPlayerScreen(track: track),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOutCubic;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            )
            .then((_) {
              // Reset expanding state if push fails or returns
              miniProvider.setIsExpanding(false);
            });
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
          child: Container(
            decoration: BoxDecoration(
              color: (muhurta.isDarkPhase ? Colors.black : Colors.white)
                  .withValues(alpha: 0.95), // Near-opaque for performance
              border: Border.all(
                color: (muhurta.isDarkPhase ? Colors.white : Colors.black)
                    .withValues(alpha: 0.1),
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
                      Hero(
                        tag: 'art-${track.id}',
                        child: Container(
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
                              track.imageUrl,
                              fit: BoxFit.cover,
                            ),
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
                              track.title,
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
                              track.deity,
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
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            key: ValueKey(isPlaying),
                            color: muhurta.primaryTextColor,
                            size: AppSizes.iconLg,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.read<AudioPlayerProvider>().togglePlay();
                        },
                      ),

                      // Close Button
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: muhurta.secondaryTextColor,
                          size: AppSizes.iconMd,
                        ),
                        onPressed: () =>
                            context.read<AudioPlayerProvider>().stop(),
                      ),
                      SizedBox(width: 4.w),
                    ],
                  ),
                ),

                // Thin Progress Bar
                StreamBuilder<Duration>(
                  stream: context
                      .read<AudioPlayerProvider>()
                      .positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration =
                        context.read<AudioPlayerProvider>().duration;

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
    );
  }
}
