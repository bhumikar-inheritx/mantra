import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/data/models/mantra_model.dart';
import 'package:deep_mantra/features/chanting/providers/practice_session_provider.dart';
import 'package:deep_mantra/features/chanting/screens/chanting_mode_selection_screen.dart';
import 'package:deep_mantra/shared/providers/media_player_provider.dart';
import 'package:deep_mantra/shared/widgets/normal_media_player_screen.dart';
import 'package:deep_mantra/shared/dialogs/sankalp_dialog.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class MantraDetailScreen extends StatelessWidget {
  final MantraModel mantra;

  const MantraDetailScreen({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    return Scaffold(
      backgroundColor: muhurta.isDarkPhase
          ? AppColors.surfaceDark
          : AppColors.sandalwoodWhite,
      appBar: AppBar(
        title: Text(
          mantra.title,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
              height: 250,
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
                    Icon(Icons.spa, size: 100, color: muhurta.accentColor),
                    const SizedBox(height: 16),
                    Text(
                      mantra.titleHindi,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 32,
                        color: muhurta.accentColor,
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
                  _buildSectionTitle("Sanskrit", muhurta),
                  const SizedBox(height: 8),
                  Text(
                    mantra.sanskritText,
                    style: TextStyle(
                      fontSize: 24,
                      color: muhurta.primaryTextColor,
                      fontFamily: 'serif',
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Transliteration", muhurta),
                  const SizedBox(height: 8),
                  Text(
                    mantra.transliteration,
                    style: TextStyle(
                      fontSize: 18,
                      color: muhurta.secondaryTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Word-by-word Meaning", muhurta),
                  const SizedBox(height: 8),
                  Text(
                    mantra.meaning,
                    style: TextStyle(
                      fontSize: 16,
                      color: muhurta.primaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Spiritual Benefits", muhurta),
                  const SizedBox(height: 8),
                  Text(
                    mantra.benefits,
                    style: TextStyle(
                      fontSize: 16,
                      color: muhurta.primaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Ideal Time & Count", muhurta),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: muhurta.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mantra.idealTime,
                        style: TextStyle(color: muhurta.primaryTextColor),
                      ),
                      const SizedBox(width: 24),
                      Icon(Icons.repeat, color: muhurta.accentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "${mantra.recommendedCount} Reps",
                        style: TextStyle(color: muhurta.primaryTextColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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

                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final mediaProvider = context.read<MediaPlayerProvider>();
                            mediaProvider.playTrack(mantra);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NormalMediaPlayerScreen(track: mantra),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: muhurta.accentColor),
                            foregroundColor: muhurta.accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text("JUST LISTEN"),
                        ),
                      ),
                      if (mantra.usageType == 'jaapSupported') ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => SankalpDialog(
                                  onStart: (target) {
                                    final session = context.read<PracticeSessionProvider>();
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: muhurta.accentColor,
                              foregroundColor: muhurta.onAccentColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor: muhurta.accentColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            child: const Text("PRACTICE"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
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
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, MuhurtaProvider muhurta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: muhurta.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: muhurta.accentColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: muhurta.primaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
