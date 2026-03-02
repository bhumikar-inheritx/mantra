import 'package:flutter/material.dart';
import 'dart:math' as math;

class MandalaPainter extends CustomPainter {
  final double progress;
  final Color themeColor;

  MandalaPainter({required this.progress, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    final paint = Paint()
      ..color = themeColor.withValues(alpha: 0.15 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw Seed of Life pattern
    // Central circle
    canvas.drawCircle(center, radius * progress, paint);

    // 6 surrounding circles
    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * math.pi / 180;
      final circleCenter = Offset(
        center.dx + radius * math.cos(angle) * progress,
        center.dy + radius * math.sin(angle) * progress,
      );
      canvas.drawCircle(circleCenter, radius * progress, paint);
    }
    
    // Additional outer layer for "Bloom"
    if (progress > 0.7) {
      final outerPaint = Paint()
        ..color = themeColor.withValues(alpha: 0.1 * (progress - 0.7) * 3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawCircle(center, radius * 1.5 * progress, outerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MandalaPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.themeColor != themeColor;
  }
}
