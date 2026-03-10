import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/locale_provider.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../../mantra/providers/mantra_provider.dart';
import '../../mantra/screens/mantra_list_screen.dart';
import '../../mantra/widgets/mantra_selection_bottom_sheet.dart';
import '../providers/dashboard_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/quick_ritual_provider.dart';
import 'quick_ritual_screen.dart';

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
        return Container(
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
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildPersonalGreeting(muhurta, l10n),
                      SizedBox(height: 20.h),
                      _buildQuoteCarousel(dashboard, muhurta, l10n),
                      SizedBox(height: 32.h),
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
                        l10n,
                      ),
                      SizedBox(height: 16.h),
                      _buildMantraSpotlight(mantraProvider, l10n),
                      SizedBox(height: 32.h),
                      _buildQuickRituals(context, l10n, muhurta),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
            ],
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
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.sandalwoodWhite,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        title: Text(
          l10n.translate('app_title'),
          style: TextStyle(
            color: muhurta.primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontHeading2,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.language,
            color: muhurta.primaryTextColor,
            size: AppSizes.iconMd,
          ),
          onPressed: () {
            final currentLanguage = localeProvider.locale.languageCode;
            localeProvider.setLocale(
              currentLanguage == 'en' ? const Locale('hi') : const Locale('en'),
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildPersonalGreeting(MuhurtaProvider muhurta, AppLocalizations l10n) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: muhurta.accentColor.withValues(alpha: 0.2),
                  width: 2.w,
                ),
              ),
            ),
            CircleAvatar(
              radius: 26.r,
              backgroundColor: muhurta.accentColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_outline,
                color: muhurta.accentColor,
                size: AppSizes.iconLg,
              ),
            ),
          ],
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate(muhurta.greeting),
              style: TextStyle(
                color: muhurta.accentColor,
                fontSize: AppSizes.fontBody,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              l10n.translate("default_username"),
              style: TextStyle(
                color: muhurta.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontHeading3,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: muhurta.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                l10n.translate(muhurta.phaseDescription).toUpperCase(),
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: AppSizes.fontXs,
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
    AppLocalizations l10n,
  ) {
    final insight = dashboard.dailyInsight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: muhurta.isDarkPhase
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.sandalwoodLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
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
              size: 48.w,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.isHindi ? insight.titleHindi : insight.title,
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                insight.verse,
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: AppSizes.fontTitle,
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      'Devanagari', // Assuming font support, otherwise falls back
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.isHindi ? insight.translationHindi : insight.translation,
                style: TextStyle(
                  color: muhurta.primaryTextColor,
                  fontSize: AppSizes.fontBody,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: muhurta.accentColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: muhurta.accentColor,
                      size: AppSizes.iconSm,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                        child: Text(
                        l10n.isHindi ? insight.contextHindi : insight.context,
                        style: TextStyle(
                          color: muhurta.secondaryTextColor,
                          fontSize: AppSizes.fontSm,
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
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: muhurta.primaryTextColor,
            fontSize: AppSizes.fontHeading3,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            l10n.translate('see_all'),
            style: TextStyle(
              color: muhurta.accentColor,
              fontSize: AppSizes.fontSm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMantraSpotlight(MantraProvider provider, AppLocalizations l10n) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.mantras.isEmpty) {
      return const SizedBox();
    }

    final featured = provider.mantras.first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.templeSaffron, AppColors.sacredMarigold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.templeSaffron.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('todays_selection'),
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.isHindi ? featured.titleHindi : featured.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.translate(featured.category.toLowerCase()),
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.fontBody,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    MantraSelectionBottomSheet(mantra: featured),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.templeSaffron,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: 8.h,
              ),
              child: Text(
                l10n.translate('start_now'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSm,
                ),
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
    void handleRitualTap(QuickRitualType type) {
      context.read<QuickRitualProvider>().startRitual(type);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuickRitualScreen()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('quick_rituals'),
          style: TextStyle(
            color: AppColors.earthyGrey,
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            _buildRitualIcon(Icons.timer_outlined, l10n.translate("morning"), muhurta, () => handleRitualTap(QuickRitualType.morning)),
            _buildRitualIcon(Icons.self_improvement, l10n.translate("peace"), muhurta, () => handleRitualTap(QuickRitualType.peace)),
            _buildRitualIcon(Icons.shield_outlined, l10n.translate("protection"), muhurta, () => handleRitualTap(QuickRitualType.protection)),
            _buildRitualIcon(Icons.nightlight_outlined, l10n.translate("sleep"), muhurta, () => handleRitualTap(QuickRitualType.sleep)),
          ],
        ),
      ],
    );
  }

  Widget _buildRitualIcon(
    IconData icon,
    String label,
    MuhurtaProvider muhurta,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.sandalwoodLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: muhurta.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                icon,
                color: muhurta.accentColor,
                size: AppSizes.iconMd,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: muhurta.primaryTextColor,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
