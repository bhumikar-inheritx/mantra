import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mantra_model.dart';
import '../screens/mantra_detail_screen.dart';

class MantraCard extends StatelessWidget {
  final MantraModel mantra;

  const MantraCard({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MantraDetailScreen(mantra: mantra),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sandalwoodLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.ancientBrown.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldenGradient,
                border: Border.all(color: AppColors.templeGold, width: 2),
              ),
              child: const Icon(Icons.music_note, color: AppColors.cosmicBlack),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mantra.title,
                    style: const TextStyle(
                      color: AppColors.ancientBrown,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mantra.category,
                    style: const TextStyle(
                      color: AppColors.templeGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mantra.transliteration,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mistGrey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.templeGold,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
