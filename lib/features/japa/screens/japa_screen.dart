import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mantra_model.dart';
import '../providers/japa_provider.dart';
import '../widgets/digital_mala_widget.dart';
import '../widgets/chakra_widget.dart';

class JapaScreen extends StatelessWidget {
  final MantraModel mantra;

  const JapaScreen({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    final japaProvider = Provider.of<JapaProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.sandalwoodWhite, AppColors.sandalwoodLight],
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
                      icon: const Icon(Icons.close, color: AppColors.ancientBrown),
                      onPressed: () {
                        _showExitConfirmation(context);
                      },
                    ),
                    Text(
                      japaProvider.formattedTime,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        color: AppColors.ancientBrown,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer
                  ],
                ),
              ),

              const Spacer(),

              // Mantra Display
              Text(
                mantra.sanskritText,
                style: const TextStyle(
                  fontSize: 28,
                  color: AppColors.templeGold,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                mantra.transliteration,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.mistGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Spacer(),

              // Digital Mala
              GestureDetector(
                onTap: () {
                  japaProvider.incrementCount();
                },
                child: Hero(
                  tag: 'mala_beads',
                  child: DigitalMalaWidget(
                    currentCount: japaProvider.currentCount,
                    targetCount: japaProvider.targetReps,
                  ),
                ),
              ),

              const Spacer(),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn("REPS", "${japaProvider.totalReps}"),
                    if (mantra.chakras.isNotEmpty)
                      ChakraWidget(
                        chakraName: mantra.chakras.first,
                        isActive: true,
                      ),
                    _buildStatColumn("CYCLE", "${japaProvider.currentCount}/${japaProvider.targetReps}"),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Active Sankalp
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.templeGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.templeGold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "INTENTION: ${japaProvider.currentSankalp?.toUpperCase()}",
                      style: const TextStyle(
                        color: AppColors.templeGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              
              const Text(
                "TAP ANYWHERE NEAR THE MALA TO COUNT",
                style: TextStyle(color: AppColors.mistGrey, fontSize: 10, letterSpacing: 1.2),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.mistGrey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.ancientBrown,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("Finish Session?"),
        content: const Text("Would you like to stop your current Japa session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("RESUME", style: TextStyle(color: AppColors.templeGold)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<JapaProvider>().stopSession();
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Exit Japa screen
            },
            child: const Text("FINISH"),
          ),
        ],
      ),
    );
  }
}
