import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../localization/app_localizations.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/sadhana_heatmap.dart';

class SadhanaScreen extends StatelessWidget {
  const SadhanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dashboard = Provider.of<DashboardProvider>(context);

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
              _buildAppBar(l10n, muhurta),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSadhanaStats(dashboard, l10n, muhurta),
                      SizedBox(height: 32.h),
                      SadhanaHeatmap(
                        activity: dashboard.getRecentActivity(),
                        muhurta: muhurta,
                      ),
                      SizedBox(height: 32.h),
                      _buildConsistencyMessage(dashboard, muhurta, l10n),
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

  Widget _buildAppBar(AppLocalizations l10n, MuhurtaProvider muhurta) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: AppSizes.paddingLg,
          bottom: 16.h,
        ),
        title: Text(
          l10n.translate("my_sadhana"),
          style: TextStyle(
            color: muhurta.primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontHeading3,
          ),
        ),
      ),
    );
  }

  Widget _buildSadhanaStats(
    DashboardProvider dashboard,
    AppLocalizations l10n,
    MuhurtaProvider muhurta,
  ) {
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
        SizedBox(width: 16.w),
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    MuhurtaProvider muhurta,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: muhurta.isDarkPhase
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.sandalwoodLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSizes.iconMd),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              color: muhurta.primaryTextColor,
              fontSize: AppSizes.fontHeading3,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: muhurta.secondaryTextColor,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyMessage(
    DashboardProvider dashboard,
    MuhurtaProvider muhurta,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: muhurta.accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            color: muhurta.accentColor,
            size: AppSizes.iconLg,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.translate("consistency_message"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muhurta.primaryTextColor,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
