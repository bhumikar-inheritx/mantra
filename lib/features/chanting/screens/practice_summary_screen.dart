import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import 'package:deep_mantra/localization/app_localizations.dart';
import '../providers/practice_session_provider.dart';

class PracticeSummaryScreen extends StatefulWidget {
  final int finalCount;
  final Duration duration;
  final String mantraTitle;

  const PracticeSummaryScreen({
    super.key,
    required this.finalCount,
    required this.duration,
    required this.mantraTitle,
  });

  @override
  State<PracticeSummaryScreen> createState() => _PracticeSummaryScreenState();
}

class _PracticeSummaryScreenState extends State<PracticeSummaryScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  int _selectedMoodIndex = 2; // Default to neutral/calm

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😌', 'label': 'Peaceful'},
    {'emoji': '💫', 'label': 'Elevated'},
    {'emoji': '😐', 'label': 'Focused'},
    {'emoji': '🔋', 'label': 'Energized'},
    {'emoji': '🙏', 'label': 'Devotional'},
  ];

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<PracticeSessionProvider>().resetSession();
        }
      },
      child: Scaffold(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLg,
              vertical: AppSizes.paddingXl,
            ),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                // Success Badge
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: muhurta.accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: AppSizes.iconXxl,
                    color: muhurta.accentColor,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.translate("sadhana_complete"),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: AppSizes.fontHeading1,
                    fontWeight: FontWeight.bold,
                    color: muhurta.primaryTextColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.translate("sadhana_blessing"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muhurta.secondaryTextColor,
                    fontSize: AppSizes.fontTitle,
                  ),
                ),
                SizedBox(height: 48.h),

                // Stats Section
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      l10n.translate("chants_small"),
                      "${widget.finalCount}",
                      Icons.repeat,
                      muhurta,
                    ),
                    SizedBox(width: 16.w),
                    _buildStatCard(
                      context,
                      l10n.translate("total_time_small"),
                      widget.duration.formatMMSS(),
                      Icons.access_time,
                      muhurta,
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Mantra Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: (muhurta.isDarkPhase ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: muhurta.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: muhurta.accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: muhurta.accentColor,
                          size: AppSizes.iconMd,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.translate("practiced_small"),
                              style: TextStyle(
                                fontSize: AppSizes.fontXs,
                                fontWeight: FontWeight.bold,
                                color: muhurta.secondaryTextColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              widget.mantraTitle,
                              style: TextStyle(
                                fontSize: AppSizes.fontTitle,
                                fontWeight: FontWeight.bold,
                                color: muhurta.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 48.h),

                // Reflection Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.translate("feel_now_prompt"),
                    style: TextStyle(
                      color: muhurta.accentColor,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8.w,
                  runSpacing: 12.h,
                  children: List.generate(_moods.length, (index) {
                    final isSelected = _selectedMoodIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMoodIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? muhurta.accentColor.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? muhurta.accentColor
                                : (muhurta.isDarkPhase
                                      ? Colors.white24
                                      : Colors.black26),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _moods[index]['emoji'],
                              style: TextStyle(fontSize: AppSizes.iconMd),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              l10n.translate(_moods[index]['label'].toString().toLowerCase()),
                              style: TextStyle(
                                fontSize: AppSizes.fontXs,
                                color: isSelected
                                    ? muhurta.accentColor
                                    : (muhurta.isDarkPhase
                                          ? Colors.white54
                                          : Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: _reflectionController,
                  maxLines: 3,
                  style: TextStyle(color: muhurta.primaryTextColor),
                  decoration: InputDecoration(
                    hintText: l10n.translate("reflection_hint"),
                    hintStyle: TextStyle(
                      color: muhurta.secondaryTextColor.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor:
                        (muhurta.isDarkPhase ? Colors.white : Colors.black)
                            .withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: BorderSide(
                        color: muhurta.accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 48.h),

                // Complete Button
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Finalize log
                      context.read<DashboardProvider>().addChantsForToday(
                        widget.finalCount,
                      );
                      // Clear session
                      context.read<PracticeSessionProvider>().resetSession();
                      // Close all screens related to practice and return to dashboard
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: muhurta.accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      l10n.translate("finish_save_progress"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontTitle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    MuhurtaProvider muhurta,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingLg),
        decoration: BoxDecoration(
          color: (muhurta.isDarkPhase ? Colors.white : Colors.black).withValues(
            alpha: 0.05,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: muhurta.isDarkPhase ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: muhurta.accentColor.withValues(alpha: 0.5),
              size: AppSizes.iconMd,
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                color: muhurta.secondaryTextColor,
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: muhurta.primaryTextColor,
                fontSize: AppSizes.fontHeading3,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }
}
