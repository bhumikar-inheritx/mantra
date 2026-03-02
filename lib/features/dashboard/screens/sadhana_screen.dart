import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/sadhana_heatmap.dart';
import '../../../shared/providers/muhurta_provider.dart';

class SadhanaScreen extends StatelessWidget {
  const SadhanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dashboard = Provider.of<DashboardProvider>(context);

    return Consumer<MuhurtaProvider>(
      builder: (context, muhurta, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: muhurta.themeGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(l10n, muhurta),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSadhanaStats(dashboard, l10n, muhurta),
                        const SizedBox(height: 32),
                        SadhanaHeatmap(
                          activity: dashboard.getRecentActivity(),
                          muhurta: muhurta,
                        ),
                        const SizedBox(height: 32),
                        _buildConsistencyMessage(dashboard, muhurta),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AppLocalizations l10n, MuhurtaProvider muhurta) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: (muhurta.isDarkPhase ? Colors.black : Colors.white).withValues(alpha: 0.1),
            child: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "My Sadhana",
                style: TextStyle(
                  color: muhurta.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSadhanaStats(DashboardProvider dashboard, AppLocalizations l10n, MuhurtaProvider muhurta) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            l10n.translate('daily_streak'),
            dashboard.streak.toString(),
            Icons.local_fire_department,
            AppColors.sacredRed,
            muhurta,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            l10n.translate('total_chants'),
            dashboard.totalChants.toString(),
            Icons.auto_awesome,
            AppColors.sacredMarigold,
            muhurta,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, MuhurtaProvider muhurta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: muhurta.isDarkPhase ? Colors.white.withValues(alpha: 0.05) : AppColors.sandalwoodLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: muhurta.primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: muhurta.secondaryTextColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyMessage(DashboardProvider dashboard, MuhurtaProvider muhurta) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: muhurta.accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_outlined, color: muhurta.accentColor, size: 32),
          const SizedBox(height: 16),
          Text(
            "Every chant builds your spiritual protection. Your consistency is your strength.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muhurta.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
