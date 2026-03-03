import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/muhurta_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: muhurta.themeGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: muhurta.accentColor.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: muhurta.accentColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Your Sacred Profile",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: muhurta.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Manage your spiritual journey.",
                  style: TextStyle(
                    color: muhurta.secondaryTextColor,
                    fontSize: 16,
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
