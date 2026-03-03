import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Success Badge
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: muhurta.accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: muhurta.accentColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Sadhana Complete",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: muhurta.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "May the vibrations of this practice stay with you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muhurta.secondaryTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Stats Section
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      "CHANTS",
                      "${widget.finalCount}",
                      Icons.repeat,
                      muhurta,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      "TOTAL TIME",
                      widget.duration.formatMMSS(),
                      Icons.access_time,
                      muhurta,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Mantra Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (muhurta.isDarkPhase ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: muhurta.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: muhurta.accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: muhurta.accentColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "PRACTICED",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mistGrey,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              widget.mantraTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Reflection Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "HOW DO YOU FEEL NOW?",
                    style: TextStyle(
                      color: muhurta.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_moods.length, (index) {
                    final isSelected = _selectedMoodIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMoodIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? muhurta.accentColor.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? muhurta.accentColor
                                : Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _moods[index]['emoji'],
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _moods[index]['label'],
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? muhurta.accentColor
                                    : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _reflectionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Add a note to your practice (optional)...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: muhurta.accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Complete Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      "FINISH & SAVE PROGRESS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: (muhurta.isDarkPhase ? Colors.white : Colors.black).withValues(
            alpha: 0.05,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: muhurta.accentColor.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.mistGrey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
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
