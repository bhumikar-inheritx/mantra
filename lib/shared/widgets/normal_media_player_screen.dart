import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../data/models/mantra_model.dart';
import '../../features/dashboard/providers/mini_player_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/muhurta_provider.dart';

class NormalMediaPlayerScreen extends StatefulWidget {
  final MantraModel track;

  const NormalMediaPlayerScreen({super.key, required this.track});

  @override
  State<NormalMediaPlayerScreen> createState() =>
      _NormalMediaPlayerScreenState();
}

class _NormalMediaPlayerScreenState extends State<NormalMediaPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Hide mini player when full player is open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MiniPlayerProvider>().setForceHidden(true);
    });
  }

  @override
  void dispose() {
    // Show mini player again when leaving full player
    // Note: This needs to happen on a mounted context or we can use another approach
    // But since it's a provider, we can try to get it from the last known context or
    // better, use a PopScope in the build method.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final muhurta = Provider.of<MuhurtaProvider>(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<MiniPlayerProvider>().setForceHidden(false);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: AppSizes.iconLg,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: AppSizes.iconMd,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background Image with Blur
            Positioned.fill(
              child: Image.asset(widget.track.imageUrl, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),

            // Player Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album Art
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30.r,
                              offset: Offset(0, 15.h),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                          child: Image.asset(
                            widget.track.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 48.h),

                    // Track Info
                    Text(
                      widget.track.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: AppSizes.fontHeading2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.track.deity,
                      style: TextStyle(
                        fontSize: AppSizes.fontTitle,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Progress Bar
                    StreamBuilder<Duration>(
                      stream: audioProvider.player.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration =
                            audioProvider.player.duration ?? Duration.zero;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: muhurta.accentColor,
                                inactiveTrackColor: Colors.white.withOpacity(
                                  0.2,
                                ),
                                thumbColor: Colors.white,
                                trackHeight: 4.h,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 6.r,
                                ),
                                overlayShape: RoundSliderOverlayShape(
                                  overlayRadius: 12.r,
                                ),
                              ),
                              child: Slider(
                                value: position.inMilliseconds.toDouble().clamp(
                                  0.0,
                                  duration.inMilliseconds.toDouble().clamp(
                                    0.01,
                                    double.infinity,
                                  ),
                                ),
                                max: duration.inMilliseconds.toDouble().clamp(
                                  0.01,
                                  double.infinity,
                                ),
                                onChanged: (value) {
                                  audioProvider.player.seek(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingMd,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: AppSizes.fontSm,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: AppSizes.fontSm,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            size: 28.w,
                            color: Colors.white54,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            size: 48.w,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        GestureDetector(
                          onTap: () => audioProvider.togglePlay(),
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: muhurta.accentColor.withOpacity(0.3),
                                  blurRadius: 20.r,
                                  spreadRadius: 5.r,
                                ),
                              ],
                            ),
                            child: Icon(
                              audioProvider.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 48.w,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.skip_next_rounded,
                            size: 48.w,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.repeat_rounded,
                            size: 28.w,
                            color: Colors.white54,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
