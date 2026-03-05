import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_sizes.dart';

/// Centralized reusable spacing widgets for consistent layouts.
class AppSpacing {
  AppSpacing._();

  // Vertical Spacing
  static SizedBox get verticalXs => SizedBox(height: AppSizes.paddingXs);
  static SizedBox get verticalSm => SizedBox(height: AppSizes.paddingSm);
  static SizedBox get verticalMd => SizedBox(height: AppSizes.paddingMd);
  static SizedBox get verticalLg => SizedBox(height: AppSizes.paddingLg);
  static SizedBox get verticalXl => SizedBox(height: AppSizes.paddingXl);
  static SizedBox get verticalXxl => SizedBox(height: AppSizes.paddingXxl);

  // Horizontal Spacing
  static SizedBox get horizontalXs => SizedBox(width: AppSizes.paddingXs);
  static SizedBox get horizontalSm => SizedBox(width: AppSizes.paddingSm);
  static SizedBox get horizontalMd => SizedBox(width: AppSizes.paddingMd);
  static SizedBox get horizontalLg => SizedBox(width: AppSizes.paddingLg);
  static SizedBox get horizontalXl => SizedBox(width: AppSizes.paddingXl);

  // Responsive padding inserts
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: AppSizes.paddingLg);
  static EdgeInsets get listPadding => EdgeInsets.symmetric(vertical: AppSizes.paddingMd);
}
