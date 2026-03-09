import 'package:flutter/material.dart';
import 'package:deep_mantra/core/theme/app_sizes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mantra_model.dart';
import 'package:deep_mantra/features/mantra/widgets/mantra_selection_bottom_sheet.dart';
import '../screens/mantra_detail_screen.dart';

class MantraCard extends StatelessWidget {
  final MantraModel mantra;

  const MantraCard({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MantraSelectionBottomSheet(mantra: mantra),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.sandalwoodLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldenGradient,
                border: Border.all(color: AppColors.templeGold, width: 2.w),
              ),
              child: Icon(Icons.music_note, color: AppColors.cosmicBlack, size: AppSizes.iconMd),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mantra.title,
                    style: TextStyle(
                      color: AppColors.ancientBrown,
                      fontSize: AppSizes.fontTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    mantra.category,
                    style: TextStyle(
                      color: AppColors.templeGold,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    mantra.transliteration,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.mistGrey,
                      fontSize: AppSizes.fontBody,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.templeGold,
              size: AppSizes.iconSm,
            ),
          ],
        ),
      ),
    );
  }
}
