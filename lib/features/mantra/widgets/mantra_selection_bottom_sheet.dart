import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/models/mantra_model.dart';
import '../../../shared/dialogs/sankalp_dialog.dart';
import '../../../shared/providers/audio_player_provider.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../../../shared/widgets/normal_media_player_screen.dart';
import '../../chanting/providers/practice_session_provider.dart';
import '../../chanting/screens/chanting_mode_selection_screen.dart';

class MantraSelectionBottomSheet extends StatelessWidget {
  final MantraModel mantra;

  const MantraSelectionBottomSheet({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Center(
        child: Container(
          width: 350.w,
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: muhurta.isDarkPhase ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(48.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40.r,
                spreadRadius: 10.r,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(48.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Artwork Header with Fade Effect
                Stack(
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black,
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                          stops: const [0.6, 0.8, 1.0],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        mantra.imageUrl,
                        width: double.infinity,
                        height: 280.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Floating Handle (Internal)
                    Positioned(
                      top: 16.h,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Content Section
                Padding(
                  padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 36.h),
                  child: Column(
                    children: [
                      // Mantra Title (English Hero/Serif)
                      Text(
                        mantra.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: muhurta.primaryTextColor,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Deity Section with Brackets/Lines
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20.w,
                            height: 1.h,
                            color: muhurta.accentColor.withValues(alpha: 0.3),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              mantra.deity,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: muhurta.accentColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            width: 20.w,
                            height: 1.h,
                            color: muhurta.accentColor.withValues(alpha: 0.3),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Short Spiritual Description
                      Text(
                        mantra.meaning.isNotEmpty
                            ? mantra.meaning
                            : "Powerful mantra for peace, meditation, and connecting with divine energy.",
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.5,
                          color: muhurta.secondaryTextColor.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // 3. Stacked Premium Buttons
                      _buildPremiumButton(
                        label: "Start Practice",
                        icon: Icons.self_improvement_rounded,
                        isPrimary: true,
                        muhurta: muhurta,
                        onTap: () {
                          Navigator.pop(context);
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
                                    builder: (_) => ChantingModeSelectionScreen(
                                      mantra: mantra,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 16.h),

                      _buildPremiumButton(
                        label: "Listen Normally",
                        icon: Icons.headphones_rounded,
                        isPrimary: false,
                        muhurta: muhurta,
                        onTap: () {
                          context.read<AudioPlayerProvider>().playTrack(mantra);
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NormalMediaPlayerScreen(track: mantra),
                            ),
                          );
                        },
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

  Widget _buildPremiumButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required MuhurtaProvider muhurta,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60.h,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.goldenGradient : null,
          color: isPrimary
              ? null
              : (muhurta.isDarkPhase ? Colors.white : Colors.black).withValues(
                  alpha: 0.08,
                ),
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: muhurta.accentColor.withValues(alpha: 0.3),
                    blurRadius: 15.r,
                    offset: Offset(0, 8.h),
                  ),
                ]
              : null,
          border: isPrimary
              ? null
              : Border.all(
                  color: muhurta.accentColor.withValues(alpha: 0.1),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : muhurta.primaryTextColor,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : muhurta.primaryTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
