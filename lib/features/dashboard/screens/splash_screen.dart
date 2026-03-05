import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/star_field_overlay.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _breathingController;
  late AnimationController _rotationController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entry Animation (Fade & Scale)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _logoScaleAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    );

    _textScaleAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );

    // 2. Continuous Breathing/Glow
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 3. Slow Rotation for background Halo
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _entryController.forward();

    // Navigate to onboarding
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _breathingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cosmicDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Cosmic Gradient
          Container(
            decoration: const BoxDecoration(gradient: AppColors.cosmicRadial),
          ),

          // Star Overlay
          const StarFieldOverlay(),

          // 🪐 Rotating Halo / Spiritual Glow behind the logo
          Center(
            child: RotationTransition(
              turns: _rotationController,
              child: AnimatedBuilder(
                animation: _breathingController,
                builder: (context, child) {
                  return Container(
                    width: 320.w,
                    height: 320.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.luxuryGold.withOpacity(
                            0.15 * _glowAnimation.value,
                          ),
                          blurRadius: 60 * _glowAnimation.value,
                          spreadRadius: 20 * _glowAnimation.value,
                        ),
                      ],
                      gradient: RadialGradient(
                        colors: [
                          AppColors.luxuryGold.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 🏛 Main Content Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🕉 Larger "DEEP MANTRA" - Positioned upside and bigger
              FadeTransition(
                opacity: _textFadeAnimation,
                child: ScaleTransition(
                  scale: _textScaleAnimation,
                  child: Column(
                    children: [
                      Text(
                        "Deep Mantra",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 10,
                          shadows: [
                            Shadow(
                              color: AppColors.luxuryGold.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        height: 1.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.luxuryGold.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // 🏵 Premium Full-Width Logo
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/icons/app_logo.png',
                      width: 1.sw, // Full width of the screen
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Subtle Bottom Meditation Tag
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _logoFadeAnimation,
              child: Center(
                child: Text(
                  "S P I R I T U A L   M I N D F U L N E S S",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
