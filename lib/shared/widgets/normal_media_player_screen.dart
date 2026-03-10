import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../data/models/mantra_model.dart';
import '../../features/dashboard/providers/mini_player_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/muhurta_provider.dart';
import '../../../localization/app_localizations.dart';

class NormalMediaPlayerScreen extends StatefulWidget {
  final MantraModel track;

  const NormalMediaPlayerScreen({super.key, required this.track});

  @override
  State<NormalMediaPlayerScreen> createState() =>
      _NormalMediaPlayerScreenState();
}

class _NormalMediaPlayerScreenState extends State<NormalMediaPlayerScreen> {
  double? _dragValue;
  Timer? _sliderTimer;

  @override
  void dispose() {
    _sliderTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Hide mini player immediately to avoid overlap
    // Hero animation captures the source in the first frame, so this is safe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MiniPlayerProvider>().setFullPlayerVisible(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get stationary/less frequent state with Selectors
    final isPlaying = context.select<AudioPlayerProvider, bool>(
      (p) => p.isPlaying,
    );
    final accentColor = context.select<MuhurtaProvider, Color>(
      (p) => p.accentColor,
    );
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<MiniPlayerProvider>().setFullPlayerVisible(false);
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
              child: Hero(
                tag: 'image-${widget.track.id}',
                child: Image.asset(widget.track.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.8), // Solid near-black for performance
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
                    Hero(
                      tag: 'art-${widget.track.id}',
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusLg,
                            ),
                            boxShadow: [
                              BoxShadow(
                                 color: Colors.black.withValues(alpha: 0.3),
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
                    ),
                    SizedBox(height: 48.h),

                    // Track Info
                    Text(
                      (l10n.isHindi ? widget.track.titleHindi : widget.track.title).toUpperCase(),
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
                      l10n.translate(widget.track.deity.toLowerCase()),
                      style: TextStyle(
                        fontSize: AppSizes.fontTitle,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Progress Bar
                    StreamBuilder<Duration>(
                      stream: context.read<AudioPlayerProvider>().positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration =
                            context.read<AudioPlayerProvider>().duration;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: accentColor,
                                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
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
                                value: (_dragValue ??
                                        position.inMilliseconds.toDouble())
                                    .clamp(
                                  0.0,
                                  duration.inMilliseconds.toDouble().clamp(
                                    1.0,
                                    double.infinity,
                                  ),
                                ),
                                max: duration.inMilliseconds.toDouble().clamp(
                                  1.0,
                                  double.infinity,
                                ),
                                 onChanged: (value) {
                                  setState(() {
                                    _dragValue = value;
                                  });
                                  if (value % 1000 < 50) { // Subtle haptic every second equivalent
                                     HapticFeedback.selectionClick();
                                  }
                                },
                                onChangeEnd: (value) {
                                  final targetDuration = Duration(milliseconds: value.toInt());
                                  // Use the provider's seekTo which is fire-and-forget
                                  context.read<AudioPlayerProvider>().seekTo(targetDuration);
                                  HapticFeedback.mediumImpact();

                                  // Keep the drag value for a longer window to ensure the stream 
                                  // has time to catch up and reflect the new position
                                  _sliderTimer?.cancel();
                                  _sliderTimer = Timer(const Duration(milliseconds: 600), () {
                                    if (mounted) {
                                      setState(() => _dragValue = null);
                                    }
                                  });
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
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<AudioPlayerProvider>().togglePlay();
                          },
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                   color: accentColor.withValues(alpha: 0.3),
                                  blurRadius: 20.r,
                                  spreadRadius: 5.r,
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(scale: animation, child: child),
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                key: ValueKey(isPlaying),
                                size: 48.w,
                                color: Colors.black,
                              ),
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
