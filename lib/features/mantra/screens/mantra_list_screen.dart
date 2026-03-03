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
  final String? title;
  final String? perspectiveType;
  const MantraListScreen({super.key, this.title, this.perspectiveType});

  @override
  State<MantraListScreen> createState() => _MantraListScreenState();
}

class _MantraListScreenState extends State<MantraListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final mantraProvider = context.read<MantraProvider>();
    if (mantraProvider.mantras.isEmpty) {
      Future.microtask(() => mantraProvider.loadMantras());
    }
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
            mantraProvider.selectedDeity == 'All' &&
            mantraProvider.searchQuery.isEmpty;
        
        final hasPerspectiveFilter = widget.title != null;

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
                        if (!hasPerspectiveFilter) ...[
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
                                if (mantraProvider.selectedCategory != 'All' ||
                                    mantraProvider.selectedDeity != 'All')
                                  TextButton(
                                    onPressed: () =>
                                        mantraProvider.clearFilters(),
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
                        ],

                        if (widget.perspectiveType != null) ...[
                          _buildPerspectiveChips(mantraProvider, muhurta),
                          const SizedBox(height: 24),
                        ],

                        // "Mantras for YOU" Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            widget.perspectiveType != null
                                ? "REVEALING ${mantraProvider.currentFilterValue.toUpperCase()}"
                                : (mantraProvider.selectedCategory == 'All'
                                    ? "ALL MANTRAS"
                                    : "${mantraProvider.selectedCategory.toUpperCase()} MANTRAS"),
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

  Widget _buildPerspectiveChips(MantraProvider provider, MuhurtaProvider muhurta) {
    List<String> options = [];
    String currentValue = '';
    
    switch (widget.perspectiveType) {
      case 'deity':
        options = provider.deities;
        currentValue = provider.selectedDeity;
        break;
      case 'category':
        options = provider.categories;
        currentValue = provider.selectedCategory;
        break;
      case 'zodiac':
        options = provider.zodiacs;
        currentValue = provider.selectedZodiac;
        break;
      case 'planet':
        options = provider.planets;
        currentValue = provider.selectedPlanet;
        break;
      case 'trackType':
        options = provider.trackTypes;
        currentValue = provider.selectedTrackType;
        break;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: options.map((option) {
          final isSelected = currentValue == option;
          return GestureDetector(
            onTap: () {
              switch (widget.perspectiveType) {
                case 'deity':
                  provider.setDeity(option);
                  break;
                case 'category':
                  provider.setCategory(option);
                  break;
                case 'zodiac':
                  provider.setZodiac(option);
                  break;
                case 'planet':
                  provider.setPlanet(option);
                  break;
                case 'trackType':
                  provider.setTrackType(option);
                  break;
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? muhurta.accentColor 
                    : (muhurta.isDarkPhase ? Colors.white : Colors.black).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.3) 
                      : muhurta.accentColor.withValues(alpha: 0.2),
                  width: isSelected ? 2.0 : 1.2,
                ),
              ),
              child: Text(
                option.toUpperCase(),
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : muhurta.primaryTextColor.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryGrid(MantraProvider provider, MuhurtaProvider muhurta) {
    final List<String> availableCats = provider.categories;
    
    final Map<String, Map<String, dynamic>> catData = {
      'All': {'color': muhurta.accentColor, 'emoji': '✨', 'icon': Icons.grid_view_rounded},
      'Wealth': {'color': Colors.amber, 'emoji': '💰', 'icon': Icons.account_balance_wallet_outlined},
      'Career': {'color': Colors.blue, 'emoji': '🚀', 'icon': Icons.trending_up_rounded},
      'Focus': {'color': Colors.indigo, 'emoji': '📚', 'icon': Icons.remove_red_eye_outlined},
      'Relationships': {'color': Colors.pink, 'emoji': '❤️', 'icon': Icons.favorite_border_rounded},
      'Harmony': {'color': Colors.lightGreen, 'emoji': '🕊', 'icon': Icons.auto_awesome_rounded},
      'Peace': {'color': Colors.cyan, 'emoji': '🌿', 'icon': Icons.self_improvement_rounded},
      'Stress Relief': {'color': Colors.deepPurple, 'emoji': '😌', 'icon': Icons.spa_outlined},
      'Health': {'color': Colors.green, 'emoji': '🧘', 'icon': Icons.eco_outlined},
      'Protection': {'color': Colors.orange, 'emoji': '🛡', 'icon': Icons.security_rounded},
      'Wisdom': {'color': Colors.amber, 'emoji': '🕯', 'icon': Icons.lightbulb_outline},
      'Spiritual Growth': {'color': Colors.purple, 'emoji': '🕉', 'icon': Icons.brightness_high_outlined},
    };

    final List<Map<String, dynamic>> categories = availableCats.map((name) {
      final data = catData[name] ?? {'color': Colors.grey, 'emoji': '🕉', 'icon': Icons.category_outlined};
      return {
        'name': name,
        'color': data['color'],
        'emoji': data['emoji'],
        'icon': data['icon'],
      };
    }).toList();


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
                                  cat['icon'] as IconData,
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
                    if (widget.title != null) ...[
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: muhurta.primaryTextColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.title ?? "Explore",
                      style: GoogleFonts.playfairDisplay(
                        color: muhurta.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: (muhurta.isDarkPhase ? Colors.white : Colors.black)
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: muhurta.accentColor.withValues(alpha: 0.2),
                          width: 1,
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
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
