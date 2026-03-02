import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:deep_mantra/features/chanting/providers/chanting_session_provider.dart';
import 'package:deep_mantra/features/chanting/providers/manual_japa_provider.dart';
import '../widgets/digital_mala_widget.dart';
import '../widgets/chakra_widget.dart';

class ManualJapaScreen extends StatefulWidget {
  const ManualJapaScreen({super.key});

  @override
  State<ManualJapaScreen> createState() => _ManualJapaScreenState();
}

class _ManualJapaScreenState extends State<ManualJapaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<ChantingSessionProvider>();
      final manual = context.read<ManualJapaProvider>();
      session.startSession();
      manual.initialize(session.targetCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final session = Provider.of<ChantingSessionProvider>(context);
    final manual = Provider.of<ManualJapaProvider>(context);
    final mantra = session.selectedMantra;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              muhurta.themeGradient.first,
              muhurta.themeGradient.last,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: muhurta.primaryTextColor),
                      onPressed: () => _showExitConfirmation(context),
                    ),
                    Text(
                      session.sessionDuration.formatMMSS(),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        color: muhurta.primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(),

              // Mantra Display
              if (mantra != null) ...[
                Text(
                  mantra.sanskritText,
                  style: TextStyle(
                    fontSize: 28,
                    color: muhurta.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  mantra.transliteration,
                  style: TextStyle(
                    fontSize: 16,
                    color: muhurta.secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              // Digital Mala (Circular)
              GestureDetector(
                onTap: () => manual.incrementCount(),
                child: DigitalMalaWidget(
                  currentCount: manual.currentCount,
                  targetCount: manual.targetCount,
                ),
              ),

              const Spacer(),

              // Stats Row (Legacy Style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn("REPS", "${manual.totalReps}", muhurta),
                    if (mantra?.chakras.isNotEmpty ?? false)
                      ChakraWidget(
                        chakraName: mantra!.chakras.first,
                        isActive: true,
                      ),
                    _buildStatColumn("CYCLE", "${manual.cycleCount}", muhurta),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Active Sankalp Badge
              _buildSankalpBadge(muhurta, session.selectedSankalp),

              const SizedBox(height: 40),
              
              Text(
                "TAP ON MALA TO COUNT",
                style: TextStyle(
                  color: muhurta.secondaryTextColor,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, MuhurtaProvider muhurta) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: muhurta.secondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: muhurta.primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildSankalpBadge(MuhurtaProvider muhurta, String? sankalp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: muhurta.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: muhurta.accentColor, size: 16),
          const SizedBox(width: 8),
          Text(
            "INTENTION: ${sankalp?.toUpperCase() ?? 'ACTIVE'}",
            style: TextStyle(
              color: muhurta.primaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    final session = context.read<ChantingSessionProvider>();
    final manual = context.read<ManualJapaProvider>();

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
                session.completeSession(context, manual.currentCount);
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
}
