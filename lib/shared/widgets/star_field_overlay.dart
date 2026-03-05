import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarFieldOverlay extends StatelessWidget {
  final int starCount;
  final double opacity;

  const StarFieldOverlay({
    super.key,
    this.starCount = 60,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarsPainter(starCount, opacity),
      size: Size.infinite,
    );
  }
}

class _StarsPainter extends CustomPainter {
  final int starCount;
  final double baseOpacity;
  final List<Offset> _starPositions;
  final math.Random _random = math.Random(42);

  _StarsPainter(this.starCount, this.baseOpacity)
      : _starPositions = List.generate(
          starCount,
          (index) => Offset(
            math.Random().nextDouble(),
            math.Random().nextDouble(),
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    for (var pos in _starPositions) {
      final actualPos = Offset(pos.dx * size.width, pos.dy * size.height);
      final radius = _random.nextDouble() * 1.5;
      final individualOpacity = _random.nextDouble() * 0.4 + 0.1;
      final paint = Paint()
        ..color = Colors.white.withOpacity(individualOpacity * (baseOpacity / 0.3));
      canvas.drawCircle(actualPos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
