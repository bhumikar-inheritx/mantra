import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/core/theme/app_sizes.dart';
import 'package:deep_mantra/features/chanting/providers/manual_japa_provider.dart';
import 'package:deep_mantra/features/chanting/providers/practice_session_provider.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deep_mantra/localization/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../widgets/chakra_widget.dart';
import '../widgets/digital_mala_widget.dart';
import 'practice_summary_screen.dart';

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
      final session = context.read<PracticeSessionProvider>();
      final manual = context.read<ManualJapaProvider>();
      session.startSession();
      session.resumeTimer();
      manual.initialize(session.targetCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final session = Provider.of<PracticeSessionProvider>(context);
    final manual = Provider.of<ManualJapaProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final mantra = session.selectedMantra;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [muhurta.themeGradient.first, muhurta.themeGradient.last],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                  vertical: AppSizes.paddingSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: muhurta.primaryTextColor,
                        size: AppSizes.iconMd,
                      ),
                      onPressed: () => _showExitConfirmation(context, l10n),
                    ),
                    Text(
                      session.sessionDuration.formatMMSS(),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: AppSizes.fontHeading3,
                        color: muhurta.primaryTextColor,
                      ),
                    ),
                    SizedBox(width: AppSizes.iconXl), // Balance close button
                  ],
                ),
              ),

              const Spacer(),

              // Mantra Display
              if (mantra != null) ...[
                Text(
                  mantra.sanskritText,
                  style: TextStyle(
                    fontSize: AppSizes.fontHeading2,
                    color: muhurta.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  mantra.transliteration,
                  style: TextStyle(
                    fontSize: AppSizes.fontTitle,
                    color: muhurta.secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              // DigitalMala (Circular)
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.vibrate();
                      manual.incrementCount();
                    },
                    child: DigitalMalaWidget(
                      currentCount: manual.currentCount,
                      targetCount: manual.targetCount,
                    ),
                  ),
                  IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.translate("tap").toUpperCase(),
                          style: TextStyle(
                            color: muhurta.secondaryTextColor.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          l10n.translate("to_count").toUpperCase(),
                          style: TextStyle(
                            color: muhurta.secondaryTextColor.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: AppSizes.fontXs,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Stats Row (Legacy Style)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn(l10n.translate("reps").toUpperCase(), "${manual.totalReps}", muhurta),
                    if (mantra?.chakras.isNotEmpty ?? false)
                      ChakraWidget(
                        chakraName: mantra!.chakras.first,
                        isActive: true,
                      ),
                    _buildStatColumn(l10n.translate("cycle").toUpperCase(), "${manual.cycleCount}", muhurta),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Active Sankalp Badge
              _buildSankalpBadge(muhurta, session.selectedSankalp, l10n),

              SizedBox(height: 40.h),

              SizedBox(height: 24.h),
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
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
    );
  }

  Widget _buildSankalpBadge(MuhurtaProvider muhurta, String? sankalp, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.paddingSm,
      ),
      decoration: BoxDecoration(
        color: muhurta.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: muhurta.accentColor,
            size: AppSizes.iconSm,
          ),
          SizedBox(width: 8.w),
          Text(
            "${l10n.translate('intention').toUpperCase()}: ${sankalp?.toUpperCase() ?? l10n.translate('active').toUpperCase()}",
            style: TextStyle(
              color: muhurta.primaryTextColor,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, AppLocalizations l10n) {
    final session = context.read<PracticeSessionProvider>();
    final manual = context.read<ManualJapaProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final m = Provider.of<MuhurtaProvider>(dialogContext, listen: false);
        return AlertDialog(
          backgroundColor: m.isDarkPhase
              ? Colors.grey[900]
              : AppColors.sandalwoodLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Text(
            l10n.translate("finish_session_title"),
            style: TextStyle(color: m.primaryTextColor),
          ),
          content: Text(
            l10n.translate("finish_session_desc"),
            style: TextStyle(color: m.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.translate("cancel"),
                style: TextStyle(color: m.secondaryTextColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: m.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              onPressed: () {
                final finalCount = manual.currentCount;
                final duration = session.sessionDuration;
                final mantraTitle = session.selectedMantra?.title ?? l10n.translate("mantra_fallback");

                Navigator.pop(dialogContext); // Close dialog

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PracticeSummaryScreen(
                      finalCount: finalCount,
                      duration: duration,
                      mantraTitle: mantraTitle,
                    ),
                  ),
                );
              },
              child: Text(
                l10n.translate("finish"),
                style: TextStyle(
                  color: m.onAccentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
