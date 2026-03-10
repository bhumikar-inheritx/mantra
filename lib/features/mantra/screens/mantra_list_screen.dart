
import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/core/theme/app_sizes.dart';
import 'package:deep_mantra/data/models/mantra_model.dart';
import 'package:deep_mantra/features/dashboard/providers/onboarding_provider.dart';
import 'package:deep_mantra/features/dashboard/widgets/deep_mantra_scaffold.dart';
import 'package:deep_mantra/features/mantra/widgets/mantra_selection_bottom_sheet.dart';
import 'package:deep_mantra/localization/app_localizations.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/mantra_provider.dart';

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

        return DeepMantraScaffold(
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
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!hasPerspectiveFilter) ...[
                          if (showRecommendations) ...[
                            _buildRecommendedSection(
                              mantraProvider,
                              onboardingProvider,
                              muhurta,
                              l10n,
                            ),
                            SizedBox(height: 32.h),
                          ],

                          // Category Grid Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingLg,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.translate("explore_by_category"),
                                  style: TextStyle(
                                    color: muhurta.accentColor,
                                    fontSize: AppSizes.fontXs,
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
                                      l10n.translate("clear"),
                                      style: TextStyle(
                                        color: muhurta.accentColor,
                                        fontSize: AppSizes.fontSm,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildCategoryGrid(mantraProvider, muhurta, l10n),
                          SizedBox(height: 32.h),
                        ],

                        if (widget.perspectiveType != null) ...[
                          _buildPerspectiveChips(mantraProvider, muhurta, l10n),
                          SizedBox(height: 24.h),
                        ],

                        // "Mantras for YOU" Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingLg,
                          ),
                          child: Text(
                            widget.perspectiveType != null
                                ? "${l10n.translate('revealing')} ${l10n.translate(mantraProvider.currentFilterValue.toLowerCase()).toUpperCase()}"
                                : (mantraProvider.selectedCategory == 'All'
                                      ? l10n.translate("all_mantras")
                                      : "${l10n.translate(mantraProvider.selectedCategory.toLowerCase()).toUpperCase()} ${l10n.translate('mantras').toUpperCase()}"),
                            style: TextStyle(
                              color: muhurta.accentColor,
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildMantraGrid(mantraProvider, muhurta, l10n),

                        SizedBox(height: 40.h),
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
    AppLocalizations l10n,
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
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
          child: Text(
            l10n.translate("recommended_mantra").toUpperCase(),
            style: TextStyle(
              color: muhurta.accentColor,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
            itemCount: recommended.length,
            itemBuilder: (context, index) {
              final mantra = recommended[index];
              return Container(
                width: 280.w,
                margin: EdgeInsets.only(right: AppSizes.paddingMd),
                child: MantraGridItem(mantra: mantra),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPerspectiveChips(
    MantraProvider provider,
    MuhurtaProvider muhurta,
    AppLocalizations l10n,
  ) {
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
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
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
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? muhurta.accentColor
                    : (muhurta.isDarkPhase ? Colors.white : Colors.black)
                          .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : muhurta.accentColor.withValues(alpha: 0.2),
                  width: isSelected ? 2.0.w : 1.2.w,
                ),
              ),
              child: Text(
                l10n.translate(option.toLowerCase()).toUpperCase(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : muhurta.primaryTextColor.withValues(alpha: 0.8),
                  fontSize: AppSizes.fontSm,
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

  Widget _buildCategoryGrid(
    MantraProvider provider,
    MuhurtaProvider muhurta,
    AppLocalizations l10n,
  ) {
    final List<String> availableCats = provider.categories;

    final Map<String, Map<String, dynamic>> catData = {
      'All': {
        'color': muhurta.accentColor,
        'emoji': '✨',
        'icon': Icons.grid_view_rounded,
      },
      'Wealth': {
        'color': Colors.amber,
        'emoji': '💰',
        'icon': Icons.account_balance_wallet_outlined,
      },
      'Career': {
        'color': Colors.blue,
        'emoji': '🚀',
        'icon': Icons.trending_up_rounded,
      },
      'Focus': {
        'color': Colors.indigo,
        'emoji': '📚',
        'icon': Icons.remove_red_eye_outlined,
      },
      'Relationships': {
        'color': Colors.pink,
        'emoji': '❤️',
        'icon': Icons.favorite_border_rounded,
      },
      'Harmony': {
        'color': Colors.lightGreen,
        'emoji': '🕊',
        'icon': Icons.auto_awesome_rounded,
      },
      'Peace': {
        'color': Colors.cyan,
        'emoji': '🌿',
        'icon': Icons.self_improvement_rounded,
      },
      'Stress Relief': {
        'color': Colors.deepPurple,
        'emoji': '😌',
        'icon': Icons.spa_outlined,
      },
      'Health': {
        'color': Colors.green,
        'emoji': '🧘',
        'icon': Icons.eco_outlined,
      },
      'Protection': {
        'color': Colors.orange,
        'emoji': '🛡',
        'icon': Icons.security_rounded,
      },
      'Wisdom': {
        'color': Colors.amber,
        'emoji': '🕯',
        'icon': Icons.lightbulb_outline,
      },
      'Spiritual Growth': {
        'color': Colors.purple,
        'emoji': '🕉',
        'icon': Icons.brightness_high_outlined,
      },
    };

    final List<Map<String, dynamic>> categories = availableCats.map((name) {
      final data =
          catData[name] ??
          {
            'color': Colors.grey,
            'emoji': '🕉',
            'icon': Icons.category_outlined,
          };
      return {
        'name': name,
        'color': data['color'],
        'emoji': data['emoji'],
        'icon': data['icon'],
      };
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
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
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: isSelected
                      ? themeColor.withValues(alpha: 0.9)
                      : themeColor.withValues(alpha: 0.25),
                  width: isSelected ? 2.5.w : 1.2.w,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.4),
                          blurRadius: 20.r,
                          spreadRadius: 2.r,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  gradient: LinearGradient(
                    colors: [
                      themeColor.withValues(alpha: isSelected ? 0.6 : 0.4),
                      (muhurta.isDarkPhase ? Colors.black : Colors.white)
                          .withValues(alpha: isSelected ? 0.7 : 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: Text(
                            cat['emoji'],
                            style: TextStyle(fontSize: AppSizes.fontSm),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  cat['icon'] as IconData,
                                  color: isSelected ? Colors.white : themeColor,
                                  size: AppSizes.iconMd,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Text(
                                  l10n.translate(cat['name'].toString().toLowerCase()).toUpperCase(),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.8,
                                        ),
                                        blurRadius: 10.r,
                                        offset: Offset(0, 2.h),
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
              );
            },
      ),
    );
  }

  Widget _buildMantraGrid(
    MantraProvider provider,
    MuhurtaProvider muhurta,
    AppLocalizations l10n,
  ) {
    if (provider.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final mantras = provider.mantras;

    if (mantras.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 40.w),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                color: muhurta.secondaryTextColor,
                size: 64.w,
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.translate("no_mantras_found"),
                textAlign: TextAlign.center,
                style: TextStyle(color: muhurta.secondaryTextColor),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  provider.setCategory('All');
                },
                child: Text(
                  l10n.translate("clear_all_filters"),
                  style: TextStyle(color: muhurta.accentColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
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
        top: MediaQuery.of(context).padding.top + 10.h,
        bottom: 20.h,
      ),
      decoration: BoxDecoration(
        color: (muhurta.isDarkPhase ? Colors.black : Colors.white).withValues(
          alpha: 0.1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.title != null) ...[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: muhurta.primaryTextColor,
                      size: AppSizes.iconMd,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8.w),
                ],
                Text(
                  widget.title ?? l10n.translate("explore_mantras"),
                  style: GoogleFonts.playfairDisplay(
                    color: muhurta.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontHeading1,
                  ),
                ),
                if (provider.isLoading)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: (muhurta.isDarkPhase ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: muhurta.accentColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: muhurta.primaryTextColor),
                decoration: InputDecoration(
                   hintText: l10n.translate("search_mantras"),
                  hintStyle: TextStyle(
                    color: muhurta.secondaryTextColor.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: muhurta.secondaryTextColor,
                    size: AppSizes.iconMd,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: AppSizes.iconSm,
                          ),
                          onPressed: () => _searchController.clear(),
                          color: muhurta.secondaryTextColor,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                ),
              ),
            ),
          ],
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
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MantraSelectionBottomSheet(mantra: mantra),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  mantra.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    final muhurta = context.read<MuhurtaProvider>();
                    return Container(
                      color: muhurta.isDarkPhase
                          ? AppColors.cosmicBlack
                          : AppColors.sandalwoodLight,
                      child: Icon(Icons.music_note, color: muhurta.accentColor),
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
                bottom: 12.h,
                left: 12.w,
                right: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mantra.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.fontBody,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      mantra.titleHindi,
                      style: GoogleFonts.notoSansDevanagari(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: AppSizes.fontSm,
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
