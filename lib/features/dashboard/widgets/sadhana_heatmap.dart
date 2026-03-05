import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../shared/providers/muhurta_provider.dart';

class SadhanaHeatmap extends StatelessWidget {
  final List<int> activity;
  final MuhurtaProvider muhurta;

  const SadhanaHeatmap({
    super.key,
    required this.activity,
    required this.muhurta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: muhurta.isDarkPhase ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: muhurta.accentColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SADHANA CONSISTENCY",
                style: TextStyle(
                  color: muhurta.accentColor,
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "LAST 30 DAYS",
                style: TextStyle(
                  color: muhurta.secondaryTextColor,
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemSize = (constraints.maxWidth - (9 * 8.w)) / 10;
              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: List.generate(30, (index) {
                  final count = activity[index];
                  return _buildHeatmapDot(count, itemSize);
                }),
              );
            },
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Text("Less", style: TextStyle(color: muhurta.secondaryTextColor, fontSize: AppSizes.fontXs)),
              SizedBox(width: 4.w),
              _buildHeatmapDot(0, 10.w),
              SizedBox(width: 4.w),
              _buildHeatmapDot(108, 10.w),
              SizedBox(width: 4.w),
              _buildHeatmapDot(324, 10.w),
              SizedBox(width: 4.w),
              _buildHeatmapDot(1008, 10.w),
              SizedBox(width: 4.w),
              Text("More", style: TextStyle(color: muhurta.secondaryTextColor, fontSize: AppSizes.fontXs)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapDot(int count, double size) {
    double opacity;
    if (count == 0) {
      opacity = 0.05;
    } else if (count < 108) {
      opacity = 0.3;
    } else if (count < 324) {
      opacity = 0.6;
    } else {
      opacity = 1.0;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: muhurta.accentColor.withOpacity(opacity),
        shape: BoxShape.circle,
        boxShadow: count > 0 ? [
          BoxShadow(
            color: muhurta.accentColor.withOpacity(opacity * 0.3),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          )
        ] : null,
      ),
    );
  }
}
