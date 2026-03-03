import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/mantra_model.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../models/chanting_session_model.dart';
import '../providers/practice_session_provider.dart';
import '../providers/manual_japa_provider.dart';
import 'audio_loop_practice_screen.dart';
import 'manual_japa_screen.dart';

class ChantingModeSelectionScreen extends StatelessWidget {
  final MantraModel mantra;

  const ChantingModeSelectionScreen({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final sessionProvider = Provider.of<PracticeSessionProvider>(
      context,
      listen: false,
    );

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Text(
                  "Choose Your Path",
                  style: TextStyle(
                    color: muhurta.primaryTextColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "How would you like to practice today?",
                  style: TextStyle(
                    color: muhurta.secondaryTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 64),

                _buildModeCard(
                  context,
                  title: "Guided Audio Loop",
                  description: "Listen and sync with an automated audio cycle.",
                  icon: Icons.graphic_eq_rounded,
                  mode: ChantMode.audio,
                  muhurta: muhurta,
                  onTap: () {
                    sessionProvider.setMode(ChantMode.audio);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AudioLoopPracticeScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                _buildModeCard(
                  context,
                  title: "Manual Japa (Mala)",
                  description: "A tactile experience. Tap to count each bead.",
                  icon: Icons.touch_app_rounded,
                  mode: ChantMode.manual,
                  muhurta: muhurta,
                  onTap: () {
                    sessionProvider.setMode(ChantMode.manual);
                    // Initialize manual provider with target count
                    context.read<ManualJapaProvider>().initialize(
                      sessionProvider.targetCount,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManualJapaScreen(),
                      ),
                    );
                  },
                ),

                const Spacer(),

                IconButton(
                  icon: Icon(Icons.close, color: muhurta.secondaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required ChantMode mode,
    required MuhurtaProvider muhurta,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: (muhurta.isDarkPhase ? Colors.white : Colors.black).withValues(
            alpha: 0.05,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: muhurta.accentColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: muhurta.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: muhurta.accentColor, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: muhurta.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: muhurta.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
