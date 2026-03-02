import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:deep_mantra/features/chanting/providers/chanting_session_provider.dart';
import 'package:deep_mantra/features/chanting/providers/audio_chant_provider.dart';

class AudioChantScreen extends StatefulWidget {
  const AudioChantScreen({super.key});

  @override
  State<AudioChantScreen> createState() => _AudioChantScreenState();
}

class _AudioChantScreenState extends State<AudioChantScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<ChantingSessionProvider>();
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
    final session = Provider.of<ChantingSessionProvider>(context);

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

  Widget _buildHeader(BuildContext context, ChantingSessionProvider session, MuhurtaProvider muhurta) {
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
    final session = context.read<ChantingSessionProvider>();
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
                session.completeSession(context, audio.currentCount);
                Navigator.pop(dialogContext);
                Navigator.pop(context);
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
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: audio.progressPercentage,
                strokeWidth: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(muhurta.accentColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${audio.currentCount}",
                  style: TextStyle(
                    color: muhurta.primaryTextColor,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "OF ${audio.targetCount}",
                  style: TextStyle(
                    color: muhurta.secondaryTextColor,
                    fontSize: 14,
                    letterSpacing: 1,
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
