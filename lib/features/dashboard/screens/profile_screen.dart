import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../shared/providers/muhurta_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: muhurta.themeGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                "Your Sacred Profile",
                style: GoogleFonts.playfairDisplay(
                  fontSize: AppSizes.fontHeading1,
                  fontWeight: FontWeight.bold,
                  color: muhurta.primaryTextColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Manage your spiritual journey.",
                style: TextStyle(
                  color: muhurta.secondaryTextColor,
                  fontSize: AppSizes.fontBody,
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
