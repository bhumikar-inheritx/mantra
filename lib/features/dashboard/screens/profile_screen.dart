import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../localization/app_localizations.dart';
import '../../../shared/providers/muhurta_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Container(
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
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
            SizedBox(height: 60.h),
            CircleAvatar(
              radius: 50.r,
              backgroundColor: muhurta.accentColor.withValues(alpha: 0.2),
              child: Icon(
                Icons.person_rounded,
                size: 60.w,
                color: muhurta.accentColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              user?.name ?? l10n.translate("your_sacred_profile"),
              style: GoogleFonts.playfairDisplay(
                fontSize: AppSizes.fontHeading1,
                fontWeight: FontWeight.bold,
                color: muhurta.primaryTextColor,
              ),
            ),
            if (user?.email != null)
              Text(
                user!.email,
                style: TextStyle(
                  color: muhurta.secondaryTextColor,
                  fontSize: AppSizes.fontSm,
                ),
              ),
            SizedBox(height: 16.h),
            Text(
              l10n.translate("manage_spiritual_journey"),
              style: TextStyle(
                color: muhurta.secondaryTextColor,
                fontSize: AppSizes.fontBody,
              ),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingLg),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, color: AppColors.sacredRed),
                  label: const Text(
                    "LOGOUT FROM THE SANCTUM",
                    style: TextStyle(
                      color: AppColors.sacredRed,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.sacredRed),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    ),
    );
  }
}
