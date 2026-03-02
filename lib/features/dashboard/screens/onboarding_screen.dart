import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../shared/providers/audio_provider.dart';
import 'main_navigation_screen.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final Map<String, String> _deityAudioMap = {
    'Shiv': 'assets/audio/shiv_mantra.mp3',
    'Vishnu': 'assets/audio/vishnu_mantra.mp3',
    'Ganesh': 'assets/audio/ganesha_mantra.mp3',
    'Devi': 'assets/audio/lakshmi_mantra.mp3',
    'Krishna': 'assets/audio/krishna_mantra.mp3',
  };

  void _nextPage(OnboardingProvider provider) {
    // Stop audio when moving past selection page
    context.read<AudioProvider>().stop();
    
    if (provider.currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.read<AudioProvider>().stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.sandalwoodWhite,
          body: Column(
            children: [
              // Curved Image Header
              Stack(
                children: [
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/shiv_image.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.sandalwoodWhite.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildProgressIndicator(provider.currentPage),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    provider.setCurrentPage(page);
                  },
                  children: [
                    _buildSelectionPage(
                      title: "How do you feel today?",
                      options: provider.moods,
                      selectedOption: provider.selectedMood,
                      onSelect: (val) => provider.setSelectedMood(val),
                    ),
                    _buildSelectionPage(
                      title: "What is your primary goal?",
                      options: provider.goals,
                      selectedOption: provider.selectedGoal,
                      onSelect: (val) => provider.setSelectedGoal(val),
                    ),
                    _buildSelectionPage(
                      title: "Preferred deity (Optional)",
                      options: provider.deities,
                      selectedOption: provider.selectedDeity,
                      onSelect: (val) {
                        provider.setSelectedDeity(val);
                        final url = _deityAudioMap[val];
                        if (url != null) {
                          audioProvider.playMantra(url);
                        } else {
                          audioProvider.stop();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.canGoNext() ? () => _nextPage(provider) : null,
                        child: Text(provider.currentPage == 2 ? "GENERATE PATH" : "CONTINUE"),
                      ),
                    ),
                    if (provider.currentPage == 2)
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: const Text("SKIP", style: TextStyle(color: AppColors.mistGrey)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildProgressIndicator(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index <= currentPage
                ? AppColors.templeGold
                : AppColors.templeGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildSelectionPage({
    required String title,
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelect,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.ancientBrown,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: options.map((option) {
                final isSelected = selectedOption == option;
                return GestureDetector(
                  onTap: () => onSelect(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.templeSaffron.withValues(alpha: 0.1) : AppColors.sandalwoodLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.templeGold : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? AppColors.templeSaffron : AppColors.ancientBrown,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, color: AppColors.templeGold, size: 20),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
