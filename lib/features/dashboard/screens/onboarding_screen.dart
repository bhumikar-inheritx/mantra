import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _selectedMood;
  String? _selectedGoal;
  String? _selectedDeity;

  final List<String> _moods = ['Stress', 'Fear', 'Confusion', 'Success', 'Gratitude'];
  final List<String> _goals = ['Health', 'Money', 'Protection', 'Peace', 'Spiritual Growth'];
  final List<String> _deities = ['Shiv', 'Vishnu', 'Ganesh', 'Devi', 'Krishna', 'None'];

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sandalwoodWhite,
      body: Column(
        children: [
          // Curved Image Header
          Stack(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
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
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildSelectionPage(
                  title: "How do you feel today?",
                  options: _moods,
                  selectedOption: _selectedMood,
                  onSelect: (val) => setState(() => _selectedMood = val),
                ),
                _buildSelectionPage(
                  title: "What is your primary goal?",
                  options: _goals,
                  selectedOption: _selectedGoal,
                  onSelect: (val) => setState(() => _selectedGoal = val),
                ),
                _buildSelectionPage(
                  title: "Preferred deity (Optional)",
                  options: _deities,
                  selectedOption: _selectedDeity,
                  onSelect: (val) => setState(() => _selectedDeity = val),
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
                    onPressed: _canGoNext() ? _nextPage : null,
                    child: Text(_currentPage == 2 ? "GENERATE PATH" : "CONTINUE"),
                  ),
                ),
                if (_currentPage == 2)
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
  }

  bool _canGoNext() {
    if (_currentPage == 0) return _selectedMood != null;
    if (_currentPage == 1) return _selectedGoal != null;
    return true;
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index <= _currentPage
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
