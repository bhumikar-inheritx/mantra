import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../mantra/screens/mantra_list_screen.dart';
import '../../mantra/screens/mantra_detail_screen.dart';
import '../../mantra/providers/mantra_provider.dart';
import '../providers/dashboard_provider.dart';

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final dashboard = Provider.of<DashboardProvider>(context);
    final mantraProvider = Provider.of<MantraProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.sandalwoodWhite,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, localeProvider, l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildPersonalGreeting(),
                  const SizedBox(height: 20),
                  _buildQuoteCarousel(dashboard),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 32),
                  _buildSadhanaStats(dashboard, l10n),
                  const SizedBox(height: 32),
                  _buildSectionHeader(l10n.translate('recommended_mantra'), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MantraListScreen()),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildMantraSpotlight(mantraProvider),
                  const SizedBox(height: 32),
                  _buildQuickRituals(context, l10n),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, LocaleProvider localeProvider, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.sandalwoodWhite,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          l10n.translate('app_title'),
          style: const TextStyle(
            color: AppColors.ancientBrown,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language, color: AppColors.ancientBrown),
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

  Widget _buildPersonalGreeting() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.templeSaffron.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.templeSaffron, size: 30),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, Seeker!",
              style: TextStyle(
                color: AppColors.earthyGrey,
                fontSize: 14,
              ),
            ),
            Text(
              "Deepak Sharma",
              style: TextStyle(
                color: AppColors.ancientBrown,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuoteCarousel(DashboardProvider dashboard) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sandalwoodLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.templeSaffron.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ancientBrown.withValues(alpha: 0.05),
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
            child: Icon(Icons.format_quote, color: AppColors.templeSaffron.withValues(alpha: 0.2), size: 48),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "QUOTES OF THE DAY",
                style: TextStyle(
                  color: AppColors.templeSaffron,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dashboard.dailyInsight,
                style: const TextStyle(
                  color: AppColors.ancientBrown,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sandalwoodLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ancientBrown.withValues(alpha: 0.1)),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: AppColors.ancientBrown.withValues(alpha: 0.4)),
          hintText: "Search for a spiritual topic",
          hintStyle: TextStyle(color: AppColors.ancientBrown.withValues(alpha: 0.4), fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSadhanaStats(DashboardProvider dashboard, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            l10n.translate('daily_streak'),
            dashboard.streak.toString(),
            Icons.local_fire_department,
            AppColors.sacredRed,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            l10n.translate('total_chants'),
            dashboard.totalChants.toString(),
            Icons.auto_awesome,
            AppColors.sacredMarigold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sandalwoodLight,
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
            style: const TextStyle(
              color: AppColors.ancientBrown,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.earthyGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ancientBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text("See All"),
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
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
              child: Text("START NOW", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRituals(BuildContext context, AppLocalizations l10n) {
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
            _buildRitualIcon(Icons.timer_outlined, "Morning"),
            _buildRitualIcon(Icons.self_improvement, "Peace"),
            _buildRitualIcon(Icons.shield_outlined, "Protection"),
            _buildRitualIcon(Icons.nightlight_outlined, "Sleep"),
          ],
        ),
      ],
    );
  }

  Widget _buildRitualIcon(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sandalwoodLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.templeSaffron.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: AppColors.templeSaffron),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.ancientBrown, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
