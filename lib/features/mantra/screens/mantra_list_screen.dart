import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/data/models/mantra_model.dart';
import 'package:deep_mantra/localization/app_localizations.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:deep_mantra/features/dashboard/providers/onboarding_provider.dart';
import 'package:deep_mantra/features/mantra/providers/mantra_provider.dart';
import 'package:deep_mantra/features/mantra/screens/mantra_detail_screen.dart';

class MantraListScreen extends StatefulWidget {
  const MantraListScreen({super.key});

  @override
  State<MantraListScreen> createState() => _MantraListScreenState();
}

class _MantraListScreenState extends State<MantraListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final mantraProvider = context.read<MantraProvider>();
    Future.microtask(() => mantraProvider.loadMantras());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<MantraProvider>().setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mantraProvider = Provider.of<MantraProvider>(context);
    final onboardingProvider = Provider.of<OnboardingProvider>(context);

    return Consumer<MuhurtaProvider>(
      builder: (context, muhurta, child) {
        final showRecommendations =
            mantraProvider.selectedCategory == 'All' &&
            mantraProvider.searchQuery.isEmpty;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: muhurta.themeGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                _buildAppBar(l10n, muhurta, mantraProvider),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showRecommendations) ...[
                          _buildRecommendedSection(
                            mantraProvider,
                            onboardingProvider,
                            muhurta,
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Category Grid Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "EXPLORE BY CATEGORY",
                                style: TextStyle(
                                  color: muhurta.accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              if (mantraProvider.selectedCategory != 'All')
                                TextButton(
                                  onPressed: () =>
                                      mantraProvider.setCategory('All'),
                                  child: Text(
                                    "Clear",
                                    style: TextStyle(
                                      color: muhurta.accentColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryGrid(mantraProvider, muhurta),

                        const SizedBox(height: 32),

                        // "Mantras for YOU" Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            mantraProvider.selectedCategory == 'All'
                                ? "ALL MANTRAS"
                                : "${mantraProvider.selectedCategory.toUpperCase()} MANTRAS",
                            style: TextStyle(
                              color: muhurta.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMantraGrid(mantraProvider, muhurta),

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

  Widget _buildRecommendedSection(
    MantraProvider mantraProvider,
    OnboardingProvider onboarding,
    MuhurtaProvider muhurta,
  ) {
    // Filter mantras that match user's deity or goal
    final recommended = mantraProvider.mantras.where((m) {
      final matchesDeity =
          onboarding.selectedDeity != null &&
          m.title.toLowerCase().contains(
            onboarding.selectedDeity!.toLowerCase(),
          );
      final matchesGoal =
          onboarding.selectedGoal != null &&
          m.category.toLowerCase() == onboarding.selectedGoal!.toLowerCase();
      return matchesDeity || matchesGoal;
    }).toList();

    if (recommended.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "RECOMMENDED FOR YOU",
            style: TextStyle(
              color: muhurta.accentColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommended.length,
            itemBuilder: (context, index) {
              final mantra = recommended[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: MantraGridItem(mantra: mantra),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(MantraProvider provider, MuhurtaProvider muhurta) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'All', 'color': muhurta.accentColor, 'emoji': '✨'},
      {'name': 'Wealth', 'color': Colors.amber, 'emoji': '💰'},
      {'name': 'Career', 'color': Colors.blue, 'emoji': '🚀'},
      {'name': 'Focus', 'color': Colors.indigo, 'emoji': '📚'},
      {'name': 'Relationships', 'color': Colors.pink, 'emoji': '❤️'},
      {'name': 'Harmony', 'color': Colors.lightGreen, 'emoji': '🕊'},
      {'name': 'Peace', 'color': Colors.cyan, 'emoji': '🌿'},
      {'name': 'Stress Relief', 'color': Colors.deepPurple, 'emoji': '😌'},
      {'name': 'Health', 'color': Colors.green, 'emoji': '🧘'},
      {'name': 'Protection', 'color': Colors.orange, 'emoji': '🛡'},
      {'name': 'Spiritual Growth', 'color': Colors.purple, 'emoji': '🕉'},
    ];


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = provider.selectedCategory == cat['name'];
          final Color themeColor = cat['color'] as Color;

          return GestureDetector(
            onTap: () {
              provider.setCategory(cat['name']);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? themeColor.withValues(alpha: 0.9)
                      : themeColor.withValues(alpha: 0.25),
                  width: isSelected ? 2.5 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeColor.withValues(alpha: isSelected ? 0.4 : 0.2),
                          (muhurta.isDarkPhase ? Colors.black : Colors.white)
                              .withValues(alpha: isSelected ? 0.5 : 0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Text(
                            cat['emoji'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  cat['name'] == 'All'
                                      ? Icons.grid_view_rounded
                                      : _getCategoryIcon(cat['name']),
                                  color: isSelected ? Colors.white : themeColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  cat['name'].toUpperCase(),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.8,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMantraGrid(MantraProvider provider, MuhurtaProvider muhurta) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final mantras = provider.mantras;

    if (mantras.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                color: muhurta.secondaryTextColor,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                "No mantras found matching your criteria.",
                textAlign: TextAlign.center,
                style: TextStyle(color: muhurta.secondaryTextColor),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  provider.setCategory('All');
                },
                child: Text(
                  "Clear All Filters",
                  style: TextStyle(color: muhurta.accentColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: mantras.length,
        itemBuilder: (context, index) {
          final mantra = mantras[index];
          return MantraGridItem(mantra: mantra);
        },
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'Wealth':
        return Icons.account_balance_wallet_outlined;
      case 'Career':
        return Icons.trending_up_rounded;
      case 'Focus':
        return Icons.remove_red_eye_outlined;
      case 'Relationships':
        return Icons.favorite_border_rounded;
      case 'Harmony':
        return Icons.auto_awesome_rounded;
      case 'Peace':
        return Icons.self_improvement_rounded;
      case 'Stress Relief':
        return Icons.spa_outlined;
      case 'Health':
        return Icons.eco_outlined;
      case 'Protection':
        return Icons.security_rounded;
      case 'Spiritual Growth':
        return Icons.brightness_high_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildAppBar(
    AppLocalizations l10n,
    MuhurtaProvider muhurta,
    MantraProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: (muhurta.isDarkPhase ? Colors.black : Colors.white).withValues(
          alpha: 0.1,
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Explore",
                      style: TextStyle(
                        color: muhurta.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    if (provider.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: (muhurta.isDarkPhase ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: muhurta.accentColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: muhurta.primaryTextColor),
                    decoration: InputDecoration(
                      hintText: "Search mantras...",
                      hintStyle: TextStyle(
                        color: muhurta.secondaryTextColor.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: muhurta.secondaryTextColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () => _searchController.clear(),
                              color: muhurta.secondaryTextColor,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MantraGridItem extends StatelessWidget {
  final MantraModel mantra;

  const MantraGridItem({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MantraDetailScreen(mantra: mantra)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  mantra.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    final muhurta = context.read<MuhurtaProvider>();
                    return Container(
                      color: muhurta.isDarkPhase ? AppColors.cosmicBlack : AppColors.sandalwoodLight,
                      child: Icon(
                        Icons.music_note,
                        color: muhurta.accentColor,
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mantra.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mantra.titleHindi,
                      style: GoogleFonts.notoSansDevanagari(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
