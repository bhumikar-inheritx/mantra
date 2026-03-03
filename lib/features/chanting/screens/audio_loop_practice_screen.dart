import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:deep_mantra/features/chanting/providers/practice_session_provider.dart';
import 'package:deep_mantra/features/chanting/providers/audio_chant_provider.dart';
import 'practice_summary_screen.dart';

class AudioLoopPracticeScreen extends StatefulWidget {
  const AudioLoopPracticeScreen({super.key});

  @override
  State<AudioLoopPracticeScreen> createState() => _AudioLoopPracticeScreenState();
}

class _AudioLoopPracticeScreenState extends State<AudioLoopPracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<PracticeSessionProvider>();
      final audio = context.read<AudioChantProvider>();
      if (session.selectedMantra != null) {
        session.startSession();
        audio.initialize(
          session.selectedMantra!.audioUrl,
          session.targetCount,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final session = Provider.of<PracticeSessionProvider>(context);

    return Scaffold(
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
              _buildHeader(context, session, muhurta),
              const Spacer(),
              _buildProgressCircle(muhurta),
              const SizedBox(height: 24),
              Text(
                session.sessionDuration.formatMMSS(),
                style: TextStyle(
                  color: muhurta.secondaryTextColor,
                  fontSize: 18,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              _buildControls(muhurta),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PracticeSessionProvider session, MuhurtaProvider muhurta) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: muhurta.primaryTextColor),
            onPressed: () => _showExitConfirmation(context),
          ),
          Column(
            children: [
              Text(
                session.selectedMantra?.title ?? "Mantra",
                style: TextStyle(
                  color: muhurta.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "GUIDED AUDIO",
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    final session = context.read<PracticeSessionProvider>();
    final audio = context.read<AudioChantProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final m = Provider.of<MuhurtaProvider>(dialogContext, listen: false);
        return AlertDialog(
          backgroundColor: m.isDarkPhase ? Colors.grey[900] : AppColors.sandalwoodLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Finish Session?", style: TextStyle(color: m.primaryTextColor)),
          content: Text("Would you like to stop and save your progress?", style: TextStyle(color: m.secondaryTextColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("CANCEL", style: TextStyle(color: m.secondaryTextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: m.accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                final finalCount = audio.currentCount;
                final duration = session.sessionDuration;
                final mantraTitle = session.selectedMantra?.title ?? "Mantra";
                
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
              child: Text("FINISH", style: TextStyle(color: m.onAccentColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressCircle(MuhurtaProvider muhurta) {
    return Consumer<AudioChantProvider>(
      builder: (context, audio, child) {
        final bool isJustListen = audio.targetCount <= 0;
        final totalProgress = !isJustListen && audio.targetCount > 0 
            ? (audio.currentCount - 1 + audio.progressPercentage) / audio.targetCount 
            : 0.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: muhurta.accentColor.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // Outer Ring (Total Progress)
            if (!isJustListen)
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: totalProgress.clamp(0.0, 1.0),
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    muhurta.accentColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            // Inner Ring (Current Repetition Progress)
            SizedBox(
              width: 230,
              height: 230,
              child: CircularProgressIndicator(
                value: audio.progressPercentage,
                strokeWidth: 12,
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
                    fontSize: 72,
                    fontWeight: FontWeight.w200, // Thinner, more elegant
                    fontFamily: 'serif',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: muhurta.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isJustListen ? "CONTINUOUS" : "OF ${audio.targetCount}",
                    style: TextStyle(
                      color: muhurta.accentColor,
                      fontSize: 12,
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
                const SizedBox(width: 16),
                _buildSpeedButton("1x", audio, 1.0, muhurta),
                const SizedBox(width: 16),
                _buildSpeedButton("1.5x", audio, 1.5, muhurta),
                const SizedBox(width: 16),
                _buildSpeedButton("2x", audio, 2.0, muhurta),
              ],
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: audio.togglePlay,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: muhurta.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: muhurta.accentColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpeedButton(String label, AudioChantProvider audio, double speed, MuhurtaProvider muhurta) {
    final isSelected = audio.playbackSpeed == speed;
    return GestureDetector(
      onTap: () => audio.setSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? muhurta.accentColor : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : muhurta.primaryTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
