import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '../../mantra/screens/mantra_list_screen.dart';
import 'sadhana_screen.dart';
import '../widgets/mini_player_widget.dart';
import '../../../shared/providers/muhurta_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MantraListScreen(),
    const SadhanaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MuhurtaProvider>(
      builder: (context, muhurta, child) {
        return Scaffold(
          body: Stack(
            children: [
              _screens[_selectedIndex],
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: DeepMantraMiniPlayer(),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
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
              backgroundColor: muhurta.isDarkPhase ? const Color(0xFF121212) : Colors.white,
              selectedItemColor: muhurta.accentColor,
              unselectedItemColor: muhurta.secondaryTextColor.withValues(alpha: 0.5),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.wb_sunny_outlined),
                  activeIcon: Icon(Icons.wb_sunny),
                  label: 'Today',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  activeIcon: Icon(Icons.analytics),
                  label: 'Sadhana',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
