import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DigitalMalaWidget extends StatefulWidget {
  final int currentCount;
  final int targetCount;

  const DigitalMalaWidget({
    super.key,
    required this.currentCount,
    required this.targetCount,
  });

  @override
  State<DigitalMalaWidget> createState() => _DigitalMalaWidgetState();
}

class _DigitalMalaWidgetState extends State<DigitalMalaWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _lastAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(DigitalMalaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCount != widget.currentCount) {
      _lastAngle = (2 * pi / widget.targetCount) * (widget.currentCount - 1);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentAngle =
            _lastAngle + (2 * pi / widget.targetCount) * _animation.value;
        return CustomPaint(
          size: const Size(300, 300),
          painter: MalaPainter(
            currentAngle: currentAngle,
            beadCount: widget.targetCount,
            progressIndex: widget.currentCount,
          ),
        );
      },
    );
  }
}

class MalaPainter extends CustomPainter {
  final double currentAngle;
  final int beadCount;
  final int progressIndex;

  MalaPainter({
    required this.currentAngle,
    required this.beadCount,
    required this.progressIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final beadRadius = size.width * 0.04;

    final paint = Paint()..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.ancientBrown.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw connecting thread
    canvas.drawCircle(center, radius, linePaint);

    for (int i = 0; i < beadCount; i++) {
      final angle = (2 * pi / beadCount) * i - currentAngle - (pi / 2);
      final beadCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Highlight current bead and completed beads
      bool isCurrentOrPast = i <= progressIndex;

      if (i == 0) {
        // Master bead (Sumeru)
        paint.color = AppColors.sacredRed;
        canvas.drawRect(
          Rect.fromCenter(
            center: beadCenter,
            width: beadRadius * 2.5,
            height: beadRadius * 2.5,
          ),
          paint,
        );
      } else {
        paint.color = isCurrentOrPast
            ? AppColors.templeGold
            : AppColors.templeGold.withValues(alpha: 0.3);

        // Add glow to current bead
        if (i == progressIndex) {
          final glowPaint = Paint()
            ..color = AppColors.saffronGlow.withValues(alpha: 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawCircle(beadCenter, beadRadius * 1.5, glowPaint);
        }

        canvas.drawCircle(beadCenter, beadRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MalaPainter oldDelegate) => true;
}
