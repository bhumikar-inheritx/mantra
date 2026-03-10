import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../dashboard/screens/main_navigation_screen.dart';
import '../../dashboard/screens/onboarding_screen.dart';
import '../screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        Widget currentScreen;
        if (auth.isAuthenticated) {
          if (auth.user?.isNewUser ?? false) {
            currentScreen = const OnboardingScreen(key: ValueKey('onboarding'));
          } else {
            currentScreen = const MainNavigationScreen(key: ValueKey('main_nav'));
          }
        } else {
          currentScreen = const LoginScreen(key: ValueKey('login'));
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: currentScreen,
        );
      },
    );
  }
}
