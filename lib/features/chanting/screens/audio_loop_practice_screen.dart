import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/core/theme/app_sizes.dart';
import 'package:deep_mantra/features/chanting/providers/audio_chant_provider.dart';
import 'package:deep_mantra/features/chanting/providers/practice_session_provider.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:flutter/material.dart';
import 'package:deep_mantra/localization/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';


import 'practice_summary_screen.dart';

class AudioLoopPracticeScreen extends StatefulWidget {
  const AudioLoopPracticeScreen({super.key});

  @override
  State<AudioLoopPracticeScreen> createState() =>
      _AudioLoopPracticeScreenState();
}

class _AudioLoopPracticeScreenState extends State<AudioLoopPracticeScreen> {
  @override
  void initState() {
    super.initState();
    _initAudioSync();
  }

  void _initAudioSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final session = context.read<PracticeSessionProvider>();
      final audio = context.read<AudioChantProvider>();
      
      if (session.selectedMantra != null) {
        session.startSession();
        audio.initialize(session.selectedMantra!, session.targetCount);
      }

      // Add listener to sync timer with audio playback
      audio.addListener(_onAudioStateChanged);
    });
  }

  void _onAudioStateChanged() {
    if (!mounted) return;
    final audio = context.read<AudioChantProvider>();
    final session = context.read<PracticeSessionProvider>();

    if (audio.isPlaying) {
      session.resumeTimer();
    } else {
      session.pauseTimer();
    }
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    context.read<AudioChantProvider>().removeListener(_onAudioStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final session = Provider.of<PracticeSessionProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<AudioChantProvider>().stop();
          context.read<PracticeSessionProvider>().resetSession();
        }
      },
      child: Scaffold(
        body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: muhurta.themeGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, session, muhurta, l10n),
              const Spacer(),
              _buildProgressCircle(muhurta, l10n),
              SizedBox(height: 24.h),
              Text(
                session.sessionDuration.formatMMSS(),
                style: TextStyle(
                  color: muhurta.secondaryTextColor,
                  fontSize: AppSizes.fontTitle,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              _buildControls(muhurta),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    PracticeSessionProvider session,
    MuhurtaProvider muhurta,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: muhurta.primaryTextColor,
              size: AppSizes.iconMd,
            ),
            onPressed: () => _showExitConfirmation(context, l10n),
          ),
          Column(
            children: [
              Text(
                session.selectedMantra?.title ?? l10n.translate("mantra_fallback"),
                style: TextStyle(
                  color: muhurta.primaryTextColor,
                  fontSize: AppSizes.fontTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.translate("guided_audio_small"),
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: AppSizes.fontXs,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(width: AppSizes.iconXl),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, AppLocalizations l10n) {
    final session = context.read<PracticeSessionProvider>();
    final audio = context.read<AudioChantProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final m = Provider.of<MuhurtaProvider>(dialogContext, listen: false);
        return AlertDialog(
          backgroundColor: m.isDarkPhase
              ? Colors.grey[900]
              : AppColors.sandalwoodLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Text(
            l10n.translate("finish_session_title"),
            style: TextStyle(color: m.primaryTextColor),
          ),
          content: Text(
            l10n.translate("finish_session_desc"),
            style: TextStyle(color: m.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.translate("cancel"),
                style: TextStyle(color: m.secondaryTextColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: m.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              onPressed: () {
                final finalCount = audio.currentCount;
                final duration = session.sessionDuration;
                final mantraTitle = session.selectedMantra?.title ?? l10n.translate("mantra_fallback");

                // Stop audio
                audio.stop();

                Navigator.pop(dialogContext); // Close dialog

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PracticeSummaryScreen(
                      finalCount: finalCount,
                      duration: duration,
                      mantraTitle: mantraTitle,
                    ),
                  ),
                );
              },
              child: Text(
                l10n.translate("finish"),
                style: TextStyle(
                  color: m.onAccentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressCircle(MuhurtaProvider muhurta, AppLocalizations l10n) {
    return Consumer<AudioChantProvider>(
      builder: (context, audio, child) {
        final bool isJustListen = audio.targetCount <= 0;
        final totalProgress = !isJustListen && audio.targetCount > 0
            ? (audio.currentCount - 1 + audio.progressPercentage) /
                  audio.targetCount
            : 0.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow
            Container(
              width: 220.w,
              height: 220.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: muhurta.accentColor.withValues(alpha: 0.15),
                    blurRadius: 40.r,
                    spreadRadius: 10.r,
                  ),
                ],
              ),
            ),
            // Outer Ring (Total Progress)
            if (!isJustListen)
              SizedBox(
                width: 260.w,
                height: 260.w,
                child: CircularProgressIndicator(
                  value: totalProgress.clamp(0.0, 1.0),
                  strokeWidth: 4.w,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    muhurta.accentColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            // Inner Ring (Current Repetition Progress)
            SizedBox(
              width: 230.w,
              height: 230.w,
              child: CircularProgressIndicator(
                value: audio.progressPercentage,
                strokeWidth: 12.w,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(muhurta.accentColor),
              ),
            ),
            // Counter Text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isJustListen ? "∞" : "${audio.currentCount}",
                  style: TextStyle(
                    color: muhurta.primaryTextColor,
                    fontSize: 72.sp,
                    fontWeight: FontWeight.w200, // Thinner, more elegant
                    fontFamily: 'serif',
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: muhurta.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusCircular,
                    ),
                  ),
                  child: Text(
                    isJustListen ? l10n.translate("continuous").toUpperCase() : "${l10n.translate("of").toUpperCase()} ${audio.targetCount}",
                    style: TextStyle(
                      color: muhurta.accentColor,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(MuhurtaProvider muhurta) {
    return Consumer<AudioChantProvider>(
      builder: (context, audio, child) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSpeedButton("0.5x", audio, 0.5, muhurta),
                SizedBox(width: 16.w),
                _buildSpeedButton("1x", audio, 1.0, muhurta),
                SizedBox(width: 16.w),
                _buildSpeedButton("1.5x", audio, 1.5, muhurta),
                SizedBox(width: 16.w),
                _buildSpeedButton("2x", audio, 2.0, muhurta),
              ],
            ),
            SizedBox(height: 48.h),
            GestureDetector(
              onTap: audio.togglePlay,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: muhurta.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: muhurta.accentColor.withValues(alpha: 0.3),
                      blurRadius: 20.r,
                      spreadRadius: 5.r,
                    ),
                  ],
                ),
                child: Icon(
                  audio.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 40.w,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpeedButton(
    String label,
    AudioChantProvider audio,
    double speed,
    MuhurtaProvider muhurta,
  ) {
    final isSelected = audio.playbackSpeed == speed;
    return GestureDetector(
      onTap: () => audio.setSpeed(speed),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? muhurta.accentColor
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : muhurta.primaryTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: AppSizes.fontSm,
          ),
        ),
      ),
    );
  }
}
