import 'dart:ui';

import 'package:deep_mantra/features/mantra/widgets/mantra_selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../data/models/mantra_model.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../../mantra/providers/mantra_provider.dart';

class PracticeTabScreen extends StatelessWidget {
  const PracticeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final mantraProvider = Provider.of<MantraProvider>(context);

    // Filter jaapSupported mantras
    final practiceMantras = mantraProvider.mantras
        .where((m) => m.usageType == 'jaapSupported')
        .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: muhurta.themeGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(muhurta),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSpotlight(context, practiceMantras, muhurta),
                  SizedBox(height: 32.h),
                  Text(
                    "CHOOSE YOUR PRACTICE",
                    style: TextStyle(
                      color: muhurta.accentColor,
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final mantra = practiceMantras[index];
                return _PracticeGridItem(mantra: mantra);
              }, childCount: practiceMantras.length),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(MuhurtaProvider muhurta) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: AppSizes.paddingLg,
          bottom: AppSizes.paddingMd,
        ),
        title: Text(
          "Sadhana",
          style: GoogleFonts.playfairDisplay(
            color: muhurta.primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontHeading2,
          ),
        ),
      ),
    );
  }

  Widget _buildSpotlight(
    BuildContext context,
    List<MantraModel> mantras,
    MuhurtaProvider muhurta,
  ) {
    if (mantras.isEmpty) return const SizedBox();
    final featured = mantras.first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: muhurta.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: muhurta.accentColor,
                size: AppSizes.iconSm,
              ),
              SizedBox(width: 8.w),
              Text(
                "RECOMMENDED PRACTICE",
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            featured.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: AppSizes.fontHeading2,
              fontWeight: FontWeight.bold,
              color: muhurta.primaryTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            featured.benefits,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: muhurta.secondaryTextColor,
              fontSize: AppSizes.fontSm,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    MantraSelectionBottomSheet(mantra: featured),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: muhurta.accentColor,
              foregroundColor: muhurta.onAccentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                "START SESSION",
                style: TextStyle(fontSize: AppSizes.fontSm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeGridItem extends StatelessWidget {
  final MantraModel mantra;

  const _PracticeGridItem({required this.mantra});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);

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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          image: DecorationImage(
            image: AssetImage(mantra.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mantra.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontBody,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSm,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: muhurta.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  mantra.trackType.toUpperCase(),
                  style: TextStyle(
                    color: muhurta.accentColor,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
