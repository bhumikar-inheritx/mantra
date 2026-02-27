import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChakraWidget extends StatefulWidget {
  final String chakraName;
  final bool isActive;

  const ChakraWidget({
    super.key,
    required this.chakraName,
    this.isActive = false,
  });

  @override
  State<ChakraWidget> createState() => _ChakraWidgetState();
}

class _ChakraWidgetState extends State<ChakraWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getChakraColor() {
    switch (widget.chakraName.toLowerCase()) {
      case 'root': return AppColors.chakraRoot;
      case 'sacral': return AppColors.chakraSacral;
      case 'solar plexus': return AppColors.chakraSolar;
      case 'heart': return AppColors.chakraHeart;
      case 'throat': return AppColors.chakraThroat;
      case 'third eye': return AppColors.chakraThirdEye;
      case 'crown': return AppColors.chakraCrown;
      default: return AppColors.templeGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    final color = _getChakraColor();

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5 * _glowAnimation.value),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 5 * _glowAnimation.value,
              ),
            ],
            border: Border.all(
              color: color.withValues(alpha: 0.8),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.brightness_7,
              color: color,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}
