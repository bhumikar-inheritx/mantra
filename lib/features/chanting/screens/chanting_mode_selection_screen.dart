import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../data/models/mantra_model.dart';
import '../../../shared/providers/audio_player_provider.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../models/chanting_session_model.dart';
import '../../../localization/app_localizations.dart';
import '../providers/manual_japa_provider.dart';
import '../providers/practice_session_provider.dart';
import 'audio_loop_practice_screen.dart';
import 'manual_japa_screen.dart';

class ChantingModeSelectionScreen extends StatelessWidget {
  final MantraModel mantra;

  const ChantingModeSelectionScreen({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final sessionProvider = Provider.of<PracticeSessionProvider>(
      context,
      listen: false,
    );

    return Scaffold(
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 48.h),
                Text(
                  l10n.translate("choose_your_path"),
                  style: TextStyle(
                    color: muhurta.primaryTextColor,
                    fontSize: AppSizes.fontHeading1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.translate("practice_today_prompt"),
                  style: TextStyle(
                    color: muhurta.secondaryTextColor,
                    fontSize: AppSizes.fontBody,
                  ),
                ),
                SizedBox(height: 64.h),

                _buildModeCard(
                  context,
                  title: l10n.translate("guided_audio_loop"),
                  description: l10n.translate("guided_audio_desc"),
                  l10n: l10n,
                  icon: Icons.graphic_eq_rounded,
                  mode: ChantMode.audio,
                  muhurta: muhurta,
                  onTap: () {
                    sessionProvider.setMode(ChantMode.audio);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AudioLoopPracticeScreen(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 24.h),

                _buildModeCard(
                  context,
                  title: l10n.translate("manual_japa"),
                  description: l10n.translate("manual_japa_desc"),
                  l10n: l10n,
                  icon: Icons.touch_app_rounded,
                  mode: ChantMode.manual,
                  muhurta: muhurta,
                  onTap: () {
                    sessionProvider.setMode(ChantMode.manual);
                    // Initialize manual provider with target count
                    context.read<ManualJapaProvider>().initialize(
                      sessionProvider.targetCount,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManualJapaScreen(),
                      ),
                    );
                  },
                ),

                const Spacer(),

                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: muhurta.secondaryTextColor,
                    size: AppSizes.iconMd,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required ChantMode mode,
    required MuhurtaProvider muhurta,
    required AppLocalizations l10n,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        // Ensure global audio playback is stopped when entering a
        // dedicated practice/chanting mode so there is only ever
        // one active audio source.
        context.read<AudioPlayerProvider>().stop();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingLg),
        decoration: BoxDecoration(
          color: (muhurta.isDarkPhase ? Colors.white : Colors.black).withValues(
            alpha: 0.05,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: muhurta.accentColor.withValues(alpha: 0.2),
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMd),
              decoration: BoxDecoration(
                color: muhurta.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: muhurta.accentColor,
                size: AppSizes.iconLg,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: muhurta.primaryTextColor,
                      fontSize: AppSizes.fontTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: muhurta.secondaryTextColor,
                      fontSize: AppSizes.fontSm,
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
}
