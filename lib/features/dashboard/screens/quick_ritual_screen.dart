import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../localization/app_localizations.dart';
import '../providers/quick_ritual_provider.dart';

class QuickRitualScreen extends StatefulWidget {
  const QuickRitualScreen({super.key});

  @override
  State<QuickRitualScreen> createState() => _QuickRitualScreenState();
}

class _QuickRitualScreenState extends State<QuickRitualScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds in, 4 seconds out
    );

    _breatheAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuickRitualProvider>();
    final l10n = AppLocalizations.of(context)!;
    final data = provider.currentRitualData;

    if (data == null) {
      return const Scaffold(body: Center(child: Text("No ritual selected")));
    }

    // Pause animation if timer is paused
    if (provider.isActive && !_breathingController.isAnimating) {
      _breathingController.repeat(reverse: true);
    } else if (!provider.isActive && _breathingController.isAnimating) {
      _breathingController.stop();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      child: Scaffold(
        backgroundColor: data.primaryColor.withValues(alpha: 0.1),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                data.primaryColor.withValues(alpha: 0.8),
                data.secondaryColor.withValues(alpha: 0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLg,
                    vertical: AppSizes.paddingMd,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          provider.stopRitual();
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(
                        provider.formattedTime,
                        style: TextStyle(
                          fontFamily: 'Courier', // monospace for timer
                          color: Colors.white,
                          fontSize: AppSizes.fontHeading2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 48.w), // Balance for back button
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Title and Quote
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
                  child: Column(
                    children: [
                      Text(
                        l10n.translate(data.title),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontHeading1,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.translate(data.quote),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: AppSizes.fontTitle,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Breathing Circle Animation
                AnimatedBuilder(
                  animation: _breatheAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breatheAnimation.value,
                      child: Container(
                        width: 200.w,
                        height: 200.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.1),
                              blurRadius: 30.r,
                              spreadRadius: 10.r,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 150.w,
                            height: 150.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.self_improvement,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 60.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                // Controls
                Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.paddingXl * 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        foregroundColor: data.primaryColor,
                        elevation: 0,
                        onPressed: () {
                          if (provider.isActive) {
                            provider.pauseRitual();
                          } else {
                            provider.resumeRitual();
                          }
                        },
                        child: Icon(
                          provider.isActive ? Icons.pause : Icons.play_arrow,
                          size: 32.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
