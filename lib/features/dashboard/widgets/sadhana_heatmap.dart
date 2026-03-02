import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: muhurta.isDarkPhase ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: muhurta.accentColor.withValues(alpha: 0.1)),
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
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "LAST 30 DAYS",
                style: TextStyle(
                  color: muhurta.secondaryTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemSize = (constraints.maxWidth - (9 * 8)) / 10;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(30, (index) {
                  final count = activity[index];
                  return _buildHeatmapDot(count, itemSize);
                }),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text("Less", style: TextStyle(color: muhurta.secondaryTextColor, fontSize: 10)),
              const SizedBox(width: 4),
              _buildHeatmapDot(0, 10),
              const SizedBox(width: 4),
              _buildHeatmapDot(108, 10),
              const SizedBox(width: 4),
              _buildHeatmapDot(324, 10),
              const SizedBox(width: 4),
              _buildHeatmapDot(1008, 10),
              const SizedBox(width: 4),
              Text("More", style: TextStyle(color: muhurta.secondaryTextColor, fontSize: 10)),
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
        color: muhurta.accentColor.withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: count > 0 ? [
          BoxShadow(
            color: muhurta.accentColor.withValues(alpha: opacity * 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
    );
  }
}
