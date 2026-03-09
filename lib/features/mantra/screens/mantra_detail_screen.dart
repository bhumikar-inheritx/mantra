import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/core/theme/app_sizes.dart';
import 'package:deep_mantra/data/models/mantra_model.dart';
import 'package:deep_mantra/features/chanting/providers/practice_session_provider.dart';
import 'package:deep_mantra/features/chanting/screens/chanting_mode_selection_screen.dart';
import 'package:deep_mantra/features/dashboard/widgets/deep_mantra_scaffold.dart';
import 'package:deep_mantra/shared/dialogs/sankalp_dialog.dart';
import 'package:deep_mantra/shared/providers/audio_player_provider.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:deep_mantra/shared/widgets/normal_media_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../dashboard/providers/mini_player_provider.dart';

class MantraDetailScreen extends StatefulWidget {
  final MantraModel mantra;

  const MantraDetailScreen({super.key, required this.mantra});

  @override
  State<MantraDetailScreen> createState() => _MantraDetailScreenState();
}

class _MantraDetailScreenState extends State<MantraDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final mantra = widget.mantra;
    final muhurta = Provider.of<MuhurtaProvider>(context);

    return DeepMantraScaffold(
      backgroundColor: muhurta.isDarkPhase
          ? AppColors.surfaceDark
          : AppColors.sandalwoodWhite,
      appBar: AppBar(
        title: Text(
          mantra.title,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontHeading2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: muhurta.primaryTextColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image / Header
            Container(
              height: 250.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: muhurta.themeGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.spa, size: 100.w, color: muhurta.accentColor),
                    SizedBox(height: 16.h),
                    Text(
                      mantra.titleHindi,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 32.sp,
                        color: muhurta.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSizes.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Sanskrit", muhurta),
                  SizedBox(height: 8.h),
                  Text(
                    mantra.sanskritText,
                    style: TextStyle(
                      fontSize: AppSizes.fontHeading2,
                      color: muhurta.primaryTextColor,
                      fontFamily: 'serif',
                    ),
                  ),

                  SizedBox(height: 24.h),
                  _buildSectionTitle("Transliteration", muhurta),
                  SizedBox(height: 8.h),
                  Text(
                    mantra.transliteration,
                    style: TextStyle(
                      fontSize: AppSizes.fontTitle,
                      color: muhurta.secondaryTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: 24.h),
                  _buildSectionTitle("Word-by-word Meaning", muhurta),
                  SizedBox(height: 8.h),
                  Text(
                    mantra.meaning,
                    style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: muhurta.primaryTextColor,
                    ),
                  ),

                  SizedBox(height: 24.h),
                  _buildSectionTitle("Spiritual Benefits", muhurta),
                  SizedBox(height: 8.h),
                  Text(
                    mantra.benefits,
                    style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: muhurta.primaryTextColor,
                    ),
                  ),

                  SizedBox(height: 24.h),
                  _buildSectionTitle("Ideal Time & Count", muhurta),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: muhurta.accentColor,
                        size: AppSizes.iconSm,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        mantra.idealTime,
                        style: TextStyle(
                          color: muhurta.primaryTextColor,
                          fontSize: AppSizes.fontBody,
                        ),
                      ),
                      SizedBox(width: 24.w),
                      Icon(
                        Icons.repeat,
                        color: muhurta.accentColor,
                        size: AppSizes.iconSm,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "${mantra.recommendedCount} Reps",
                        style: TextStyle(
                          color: muhurta.primaryTextColor,
                          fontSize: AppSizes.fontBody,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildInfoChip(mantra.deity, Icons.auto_awesome, muhurta),
                      if (mantra.zodiac.isNotEmpty)
                        _buildInfoChip(
                          mantra.zodiac.first,
                          Icons.vibration,
                          muhurta,
                        ),
                      if (mantra.planet.isNotEmpty)
                        _buildInfoChip(
                          mantra.planet.first,
                          Icons.public,
                          muhurta,
                        ),
                      _buildInfoChip(
                        mantra.trackType,
                        Icons.music_note,
                        muhurta,
                      ),
                    ],
                  ),

                  SizedBox(height: 48.h),
                  Column(
                    children: [
                      Divider(
                        color: muhurta.accentColor.withValues(alpha: 0.1),
                        height: 48.h,
                      ),
                      Text(
                        "BEGIN YOUR RITUAL",
                        style: TextStyle(
                          color: muhurta.accentColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPlayActionTile(
                              context: context,
                              title: "Listen",
                              icon: Icons.headphones_rounded,
                              muhurta: muhurta,
                              onTap: () {
                                context
                                    .read<MiniPlayerProvider>()
                                    .setFullPlayerVisible(true);

                                final audioProvider = context
                                    .read<AudioPlayerProvider>();
                                audioProvider.playTrack(mantra);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NormalMediaPlayerScreen(track: mantra),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (mantra.usageType == 'jaapSupported') ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildPlayActionTile(
                                context: context,
                                title: "Practice",
                                icon: Icons.vibration_rounded,
                                muhurta: muhurta,
                                isPrimary: true,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SankalpDialog(
                                      onStart: (target) {
                                        final session = context
                                            .read<PracticeSessionProvider>();
                                        session.selectMantra(mantra);
                                        session.setSankalp(mantra.title);
                                        session.setTargetCount(target);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ChantingModeSelectionScreen(
                                                  mantra: mantra,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, MuhurtaProvider muhurta) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.playfairDisplay(
        color: muhurta.accentColor,
        fontSize: AppSizes.fontBody,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildPlayActionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required MuhurtaProvider muhurta,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? muhurta.accentColor
              : muhurta.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isPrimary
                ? muhurta.accentColor
                : muhurta.accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : muhurta.accentColor,
              size: 20.w,
            ),
            SizedBox(width: 10.w),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: isPrimary ? Colors.white : muhurta.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, MuhurtaProvider muhurta) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: muhurta.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: muhurta.accentColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: muhurta.primaryTextColor,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
