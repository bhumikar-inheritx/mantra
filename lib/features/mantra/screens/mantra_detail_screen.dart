import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mantra_model.dart';
import '../../../shared/dialogs/sankalp_dialog.dart';
import '../../japa/providers/japa_provider.dart';
import '../../japa/screens/japa_screen.dart';

class MantraDetailScreen extends StatelessWidget {
  final MantraModel mantra;

  const MantraDetailScreen({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mantra.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image / Header
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.sandalwoodWhite, AppColors.sandalwoodLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.spa, size: 100, color: AppColors.templeGold),
                    const SizedBox(height: 16),
                    Text(
                      mantra.titleHindi,
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.templeGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Sanskrit"),
                  const SizedBox(height: 8),
                  Text(
                    mantra.sanskritText,
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppColors.ancientBrown,
                      fontFamily: 'serif',
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Transliteration"),
                  const SizedBox(height: 8),
                  Text(
                    mantra.transliteration,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.mistGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Word-by-word Meaning"),
                  const SizedBox(height: 8),
                  Text(
                    mantra.meaning,
                    style: const TextStyle(fontSize: 16, color: AppColors.ancientBrown),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Spiritual Benefits"),
                  const SizedBox(height: 8),
                  Text(
                    mantra.benefits,
                    style: const TextStyle(fontSize: 16, color: AppColors.ancientBrown),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Ideal Time & Count"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.templeGold, size: 20),
                      const SizedBox(width: 8),
                      Text(mantra.idealTime),
                      const SizedBox(width: 24),
                      const Icon(Icons.repeat, color: AppColors.templeGold, size: 20),
                      const SizedBox(width: 8),
                      Text("${mantra.recommendedCount} Reps"),
                    ],
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => SankalpDialog(
                            onStart: (sankalp, target) {
                              context.read<JapaProvider>().startSession(sankalp, target);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JapaScreen(mantra: mantra),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: const Text("START JAPA"),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.templeGold,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}
