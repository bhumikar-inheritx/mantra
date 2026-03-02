import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/locale_provider.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../../mantra/providers/mantra_provider.dart';
import '../../mantra/screens/mantra_detail_screen.dart';
import '../../mantra/screens/mantra_list_screen.dart';
import '../providers/dashboard_provider.dart';
import '../providers/onboarding_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure mantras are loaded for the spotlight
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MantraProvider>().loadMantras();

        // Intelligence: Refresh insight based on onboarding profile
        final onboarding = context.read<OnboardingProvider>();
        context.read<DashboardProvider>().refreshInsight(
          onboarding.selectedMood,
          onboarding.selectedGoal,
          onboarding.selectedDeity,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final dashboard = Provider.of<DashboardProvider>(context);
    final mantraProvider = Provider.of<MantraProvider>(context);

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
                _buildAppBar(context, localeProvider, l10n, muhurta),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildPersonalGreeting(muhurta),
                        const SizedBox(height: 20),
                        _buildQuoteCarousel(dashboard, muhurta),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          l10n.translate('recommended_mantra'),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MantraListScreen(),
                              ),
                            );
                          },
                          muhurta,
                        ),
                        const SizedBox(height: 16),
                        _buildMantraSpotlight(mantraProvider),
                        const SizedBox(height: 32),
                        _buildQuickRituals(context, l10n, muhurta),
                        const SizedBox(height: 40),
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

  Widget _buildAppBar(
    BuildContext context,
    LocaleProvider localeProvider,
    AppLocalizations l10n,
    MuhurtaProvider muhurta,
  ) {
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
            color: (muhurta.isDarkPhase ? Colors.black : Colors.white)
                .withValues(alpha: 0.1),
            child: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                l10n.translate('app_title'),
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
      actions: [
        IconButton(
          icon: Icon(Icons.language, color: muhurta.primaryTextColor),
          onPressed: () {
            final currentLanguage = localeProvider.locale.languageCode;
            localeProvider.setLocale(
              currentLanguage == 'en' ? const Locale('hi') : const Locale('en'),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPersonalGreeting(MuhurtaProvider muhurta) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: muhurta.accentColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
            CircleAvatar(
              radius: 26,
              backgroundColor: muhurta.accentColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_outline,
                color: muhurta.accentColor,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              muhurta.greeting,
              style: TextStyle(
                color: muhurta.accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "Deepak Sharma",
              style: TextStyle(
                color: muhurta.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: muhurta.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                muhurta.phaseDescription.toUpperCase(),
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuoteCarousel(
    DashboardProvider dashboard,
    MuhurtaProvider muhurta,
  ) {
    final insight = dashboard.dailyInsight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: muhurta.isDarkPhase
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.sandalwoodLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.auto_awesome,
              color: muhurta.accentColor.withValues(alpha: 0.2),
              size: 48,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SPIRITUAL PRESCRIPTION",
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                insight.verse,
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      'Devanagari', // Assuming font support, otherwise falls back
                ),
              ),
              const SizedBox(height: 12),
              Text(
                insight.translation,
                style: TextStyle(
                  color: muhurta.primaryTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: muhurta.accentColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: muhurta.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.context,
                        style: TextStyle(
                          color: muhurta.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    VoidCallback onSeeAll,
    MuhurtaProvider muhurta,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: muhurta.primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text("See All", style: TextStyle(color: muhurta.accentColor)),
        ),
      ],
    );
  }

  Widget _buildMantraSpotlight(MantraProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.mantras.isEmpty) {
      return const SizedBox();
    }

    final featured = provider.mantras.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.templeSaffron, AppColors.sacredMarigold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.templeSaffron.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S SELECTION",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            featured.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            featured.category,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MantraDetailScreen(mantra: featured),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.templeSaffron,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "START NOW",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRituals(
    BuildContext context,
    AppLocalizations l10n,
    MuhurtaProvider muhurta,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "QUICK RITUALS",
          style: TextStyle(
            color: AppColors.earthyGrey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildRitualIcon(Icons.timer_outlined, "Morning", muhurta),
            _buildRitualIcon(Icons.self_improvement, "Peace", muhurta),
            _buildRitualIcon(Icons.shield_outlined, "Protection", muhurta),
            _buildRitualIcon(Icons.nightlight_outlined, "Sleep", muhurta),
          ],
        ),
      ],
    );
  }

  Widget _buildRitualIcon(IconData icon, String label, MuhurtaProvider muhurta) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sandalwoodLight,
              shape: BoxShape.circle,
              border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: muhurta.accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: muhurta.primaryTextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
