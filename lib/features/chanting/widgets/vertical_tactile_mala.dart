import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class VerticalTactileMala extends StatefulWidget {
  final int currentCount;
  final int targetCount;
  final VoidCallback onCountIncrement;
  final Color themeColor;

  const VerticalTactileMala({
    super.key,
    required this.currentCount,
    required this.targetCount,
    required this.onCountIncrement,
    required this.themeColor,
  });

  @override
  State<VerticalTactileMala> createState() => _VerticalTactileMalaState();
}

class _VerticalTactileMalaState extends State<VerticalTactileMala>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;
  final double _beadSpacing = 60.0;
  bool _hasIncrementedThisSwipe = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      
      // If pulled down far enough to count
      if (_dragOffset > _beadSpacing * 0.7 && !_hasIncrementedThisSwipe) {
        widget.onCountIncrement();
        _hasIncrementedThisSwipe = true;
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _dragOffset = 0;
      _hasIncrementedThisSwipe = false;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: ClipRect(
        child: SizedBox(
          width: 100,
          height: 400,
          child: CustomPaint(
            painter: VerticalMalaPainter(
              offset: _dragOffset,
              spacing: _beadSpacing,
              themeColor: widget.themeColor,
              currentCount: widget.currentCount,
            ),
          ),
        ),
      ),
    );
  }
}

class VerticalMalaPainter extends CustomPainter {
  final double offset;
  final double spacing;
  final Color themeColor;
  final int currentCount;

  VerticalMalaPainter({
    required this.offset,
    required this.spacing,
    required this.themeColor,
    required this.currentCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw string
    final stringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), stringPaint);

    // Draw beads
    for (int i = -4; i <= 4; i++) {
      final y = centerY + (i * spacing) + (offset % spacing);
      final opacity = 1.0 - (i.abs() / 5.0);
      final scale = 1.0 - (i.abs() * 0.1);
      
      final beadPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(centerX, y),
          15 * scale,
          [
            themeColor.withValues(alpha: 0.9 * opacity),
            themeColor.withValues(alpha: 0.4 * opacity),
          ],
        )
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(centerX, y), 15 * scale, beadPaint);
      
      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 * opacity)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(centerX - 4 * scale, y - 4 * scale), 4 * scale, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant VerticalMalaPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.currentCount != currentCount;
  }
}
