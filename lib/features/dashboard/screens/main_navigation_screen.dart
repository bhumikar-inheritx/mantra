import 'package:deep_mantra/features/mantra/screens/browse_perspective_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../shared/providers/muhurta_provider.dart';
import '../providers/mini_player_provider.dart';
import '../widgets/deep_mantra_scaffold.dart';
import 'home_screen.dart';
import 'practice_tab_screen.dart';
import 'profile_screen.dart';
import 'sadhana_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BrowsePerspectiveScreen(),
    const PracticeTabScreen(),
    const SadhanaScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MuhurtaProvider>(
      builder: (context, muhurta, child) {
        return DeepMantraScaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20.r,
                  offset: Offset(0, -5.h),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: muhurta.isDarkPhase
                  ? const Color(0xFF121212)
                  : Colors.white,
              selectedItemColor: muhurta.accentColor,
              unselectedItemColor: muhurta.secondaryTextColor.withValues(
                alpha: 0.5,
              ),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontSm,
              ),
              unselectedLabelStyle: TextStyle(fontSize: AppSizes.fontSm),
              iconSize: AppSizes.iconMd,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.self_improvement_outlined),
                  activeIcon: Icon(Icons.self_improvement),
                  label: 'Practice',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.insights_outlined),
                  activeIcon: Icon(Icons.insights),
                  label: 'Progress',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
