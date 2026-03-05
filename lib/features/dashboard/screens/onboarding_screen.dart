import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../shared/providers/audio_player_provider.dart';
import '../../../shared/widgets/star_field_overlay.dart';
import '../providers/onboarding_provider.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeController;
  late Animation<double> _contentFade;

  final Map<String, String> _deityAudioMap = {
    'Shiv': 'assets/audio/shiv_mantra.mp3',
    'Vishnu': 'assets/audio/vishnu_mantra.mp3',
    'Ganesh': 'assets/audio/ganesha_mantra.mp3',
    'Devi': 'assets/audio/lakshmi_mantra.mp3',
    'Krishna': 'assets/audio/krishna_mantra.mp3',
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentFade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage(OnboardingProvider provider) {
    context.read<AudioPlayerProvider>().stop();

    if (provider.currentPage < 2) {
      _fadeController.reverse().then((_) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _fadeController.forward();
      });
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.read<AudioPlayerProvider>().stop();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(
      context,
      listen: false,
    );

    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.cosmicDeep,
          body: Stack(
            children: [
              // Cosmic Background
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.cosmicRadial,
                ),
              ),
              const StarFieldOverlay(opacity: 0.2),

              Column(
                children: [
                  // Premium Dynamic Header
                  _buildAnimatedHeader(provider),

                  _buildProgressIndicator(provider.currentPage),

                  Expanded(
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (int page) {
                          provider.setCurrentPage(page);
                        },
                        children: [
                          _buildSelectionPage(
                            title: "How do you feel today?",
                            subtitle: "Select your current state of mind",
                            options: provider.moods,
                            selectedOption: provider.selectedMood,
                            onSelect: (val) => provider.setSelectedMood(val),
                          ),
                          _buildSelectionPage(
                            title: "What is your primary goal?",
                            subtitle: "Help us personalize your spiritual path",
                            options: provider.goals,
                            selectedOption: provider.selectedGoal,
                            onSelect: (val) => provider.setSelectedGoal(val),
                          ),
                          _buildSelectionPage(
                            title: "Preferred deity (Optional)",
                            subtitle: "Select a focal point for your practice",
                            options: provider.deities,
                            selectedOption: provider.selectedDeity,
                            onSelect: (val) {
                              provider.setSelectedDeity(val);
                              final url = _deityAudioMap[val];
                              if (url != null) {
                                audioProvider.playUrl(url);
                              } else {
                                audioProvider.stop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Bar
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.paddingLg,
                      0,
                      AppSizes.paddingLg,
                      AppSizes.paddingXl,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusXl,
                              ),
                              gradient: provider.canGoNext()
                                  ? AppColors.goldenGradient
                                  : null,
                              color: provider.canGoNext()
                                  ? null
                                  : Colors.white10,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 18.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusXl,
                                  ),
                                ),
                              ),
                              onPressed: provider.canGoNext()
                                  ? () => _nextPage(provider)
                                  : null,
                              child: Text(
                                provider.currentPage == 2
                                    ? "GENERATE PATH"
                                    : "CONTINUE",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: provider.canGoNext()
                                      ? Colors.white
                                      : Colors.white24,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (provider.currentPage == 2)
                          TextButton(
                            onPressed: _finishOnboarding,
                            child: Text(
                              "SKIP",
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: AppSizes.fontSm,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader(OnboardingProvider provider) {
    String imagePath;
    switch (provider.currentPage) {
      case 0:
        imagePath = 'assets/images/shiv_image.jpg';
        break;
      case 1:
        imagePath = 'assets/images/shivWithTemple.jpg';
        break;
      case 2:
        // Dynamic deity visual
        if (provider.selectedDeity == 'Shiv') {
          imagePath = 'assets/images/shiv_image.jpg';
        } else if (provider.selectedDeity == 'Vishnu') {
          imagePath = 'assets/images/vishnu.png';
        } else if (provider.selectedDeity == 'Ganesh') {
          imagePath = 'assets/images/ganesha.png';
        } else if (provider.selectedDeity == 'Devi') {
          imagePath = 'assets/images/lakshmi.png';
        } else if (provider.selectedDeity == 'Krishna') {
          imagePath = 'assets/images/krishna.png';
        } else {
          imagePath = 'assets/images/peace_cat.png';
        }
        break;
      default:
        imagePath = 'assets/images/shiv_image.jpg';
    }

    return Container(
      height: 420.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Container(
              key: ValueKey(imagePath),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cosmicDeep.withOpacity(0.0),
                  AppColors.cosmicDeep.withOpacity(0.4),
                  AppColors.cosmicDeep,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Subtle glow at bottom of header
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.luxuryGold.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  center: const Alignment(0, 1),
                  radius: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int currentPage) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: 8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == currentPage;
          final isCompleted = index < currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 40.w : 20.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              gradient: (isCompleted || isActive)
                  ? AppColors.goldenGradient
                  : null,
              color: !(isCompleted || isActive) ? Colors.white10 : null,
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.luxuryGold.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectionPage({
    required String title,
    required String subtitle,
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelect,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w200,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white54,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 30.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              alignment: WrapAlignment.center,
              children: options.map((option) {
                final isSelected = selectedOption == option;
                return GestureDetector(
                  onTap: () => onSelect(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.luxuryGold.withOpacity(0.1)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.luxuryGold.withOpacity(0.5)
                            : Colors.white12,
                        width: 1.w,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.luxuryGold.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isSelected
                            ? AppColors.luxuryGold
                            : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w300,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
