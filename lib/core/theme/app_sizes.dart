import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized configuration for responsive sizes.
/// Uses `flutter_screenutil` to scale dimensions based on device size.
class AppSizes {
  AppSizes._();

  // Paddings and Margins
  static double get paddingXs => 4.w;
  static double get paddingSm => 8.w;
  static double get paddingMd => 16.w;
  static double get paddingLg => 24.w;
  static double get paddingXl => 32.w;
  static double get paddingXxl => 48.w;

  static double get marginXs => 4.w;
  static double get marginSm => 8.w;
  static double get marginMd => 16.w;
  static double get marginLg => 24.w;
  static double get marginXl => 32.w;

  // Icon Sizes
  static double get iconSm => 16.w;
  static double get iconMd => 24.w;
  static double get iconLg => 32.w;
  static double get iconXl => 48.w;
  static double get iconXxl => 64.w;

  // Component Sizes
  static double get buttonHeight => 56.h;
  static double get miniPlayerHeight => 64.h;
  static double get bottomNavBarHeight => 72.h;

  // Border Radius
  static double get radiusSm => 8.r;
  static double get radiusMd => 16.r;
  static double get radiusLg => 24.r;
  static double get radiusXl => 32.r;
  static double get radiusXxl => 40.r;
  static double get radiusCircular => 100.r;

  // Typography (Using .sp for text scaling)
  static double get fontXs => 10.sp;
  static double get fontSm => 12.sp;
  static double get fontBody => 14.sp;
  static double get fontTitle => 18.sp;
  static double get fontHeading3 => 22.sp;
  static double get fontHeading2 => 28.sp;
  static double get fontHeading1 => 32.sp;
  static double get fontDisplay => 48.sp;
}
