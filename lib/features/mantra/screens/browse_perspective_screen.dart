import 'package:deep_mantra/core/theme/app_sizes.dart';
import 'package:deep_mantra/features/mantra/providers/mantra_provider.dart';
import 'package:deep_mantra/localization/app_localizations.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'mantra_list_screen.dart';

class BrowsePerspectiveScreen extends StatelessWidget {
  const BrowsePerspectiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> perspectives = [
      {
        'title': l10n.translate('deity'),
        'subtitle': l10n.translate('divine_forms'),
        'icon': Icons.auto_awesome_rounded,
        'color': Colors.amber,
        'type': 'deity',
        'image': 'assets/images/perspectives/deity.png',
      },
      {
        'title': l10n.translate('benefit'),
        'subtitle': l10n.translate('healing_vibes'),
        'icon': Icons.spa_rounded,
        'color': Colors.green,
        'type': 'category',
        'image': 'assets/images/perspectives/benefit.png',
      },
      {
        'title': l10n.translate('zodiac'),
        'subtitle': l10n.translate('star_alignment'),
        'icon': Icons.vibration_rounded,
        'color': Colors.deepPurple,
        'type': 'zodiac',
        'image': 'assets/images/perspectives/zodiac.png',
      },
      {
        'title': l10n.translate('planet'),
        'subtitle': l10n.translate('celestial_power'),
        'icon': Icons.public_rounded,
        'color': Colors.blue,
        'type': 'planet',
        'image': 'assets/images/perspectives/planet.png',
      },
      {
        'title': l10n.translate('type'),
        'subtitle': l10n.translate('sacred_genres'),
        'icon': Icons.library_music_rounded,
        'color': Colors.orange,
        'type': 'trackType',
        'image': 'assets/images/perspectives/track_type.png',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: muhurta.themeGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.paddingLg,
                AppSizes.paddingLg,
                AppSizes.paddingLg,
                32.h,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate("sacred_library"),
                      style: GoogleFonts.playfairDisplay(
                        color: muhurta.primaryTextColor,
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.translate("choose_perspective").toUpperCase(),
                      style: TextStyle(
                        color: muhurta.accentColor,
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20.h,
                  crossAxisSpacing: 20.w,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final p = perspectives[index];
                  return _buildPremiumPerspectiveCard(
                    context,
                    p,
                    muhurta,
                    index,
                  );
                }, childCount: perspectives.length),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 8.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPerspectiveCard(
    BuildContext context,
    Map<String, dynamic> p,
    MuhurtaProvider muhurta,
    int index,
  ) {
    final Color pColor = p['color'] as Color;
    final String imagePath = p['image'] as String;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50.h * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          final mantraProvider = context.read<MantraProvider>();
          mantraProvider.clearFilters();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MantraListScreen(
                title: p['title'],
                perspectiveType: p['type'],
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: pColor.withValues(alpha: 0.2),
                blurRadius: 20.r,
                spreadRadius: -10.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
                // Overlay Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Glass Effect & Border
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: pColor.withValues(alpha: 0.4),
                        width: 1.5.w,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMd),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: pColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.5.w,
                          ),
                        ),
                        child: Icon(
                          p['icon'],
                          color: Colors.white,
                          size: AppSizes.iconSm,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        p['title'],
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        p['subtitle'],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: AppSizes.fontXs,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
