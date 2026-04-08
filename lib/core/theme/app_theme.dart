import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.sandalwoodWhite,
      primaryColor: AppColors.templeSaffron,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.templeSaffron,
        onPrimary: Colors.white,
        secondary: AppColors.sacredMarigold,
        surface: AppColors.sandalwoodLight,
        onSurface: AppColors.ancientBrown,
        error: AppColors.sacredRed,
      ),

      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            color: AppColors.ancientBrown,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            color: AppColors.ancientBrown,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: AppColors.ancientBrown,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: AppColors.ancientBrown,
            fontSize: 16.sp,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: AppColors.earthyGrey,
            fontSize: 14.sp,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            color: AppColors.earthyGrey,
            fontSize: 12.sp,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.sandalwoodWhite,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        iconTheme: const IconThemeData(color: AppColors.ancientBrown),
        titleTextStyle: TextStyle(
          color: AppColors.ancientBrown,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.templeSaffron,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          elevation: 2,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.sandalwoodLight,
        elevation: 4,
        shadowColor: AppColors.ancientBrown.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColors.templeSaffron.withValues(alpha: 0.1)),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.ancientBrown.withValues(alpha: 0.1),
        thickness: 1.h,
      ),
    );
  }

  // Keeping darkTheme for now to avoid breaking changes if referenced elsewhere, 
  // but updating it to be a more spiritual "Evening" theme or just alias it.
  static ThemeData get darkTheme => lightTheme; 
}
