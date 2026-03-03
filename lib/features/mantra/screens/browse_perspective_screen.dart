import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:deep_mantra/features/mantra/providers/mantra_provider.dart';
import 'mantra_list_screen.dart';

class BrowsePerspectiveScreen extends StatelessWidget {
  const BrowsePerspectiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);

    final List<Map<String, dynamic>> perspectives = [
      {
        'title': 'Deity',
        'subtitle': 'Divine Forms',
        'icon': Icons.auto_awesome_rounded,
        'color': Colors.amber,
        'type': 'deity',
        'image': 'assets/images/perspectives/deity.png',
      },
      {
        'title': 'Benefit',
        'subtitle': 'Healing Vibes',
        'icon': Icons.spa_rounded,
        'color': Colors.green,
        'type': 'category',
        'image': 'assets/images/perspectives/benefit.png',
      },
      {
        'title': 'Zodiac',
        'subtitle': 'Star Alignment',
        'icon': Icons.vibration_rounded,
        'color': Colors.deepPurple,
        'type': 'zodiac',
        'image': 'assets/images/perspectives/zodiac.png',
      },
      {
        'title': 'Planet',
        'subtitle': 'Celestial Power',
        'icon': Icons.public_rounded,
        'color': Colors.blue,
        'type': 'planet',
        'image': 'assets/images/perspectives/planet.png',
      },
      {
        'title': 'Type',
        'subtitle': 'Sacred Genres',
        'icon': Icons.library_music_rounded,
        'color': Colors.orange,
        'type': 'trackType',
        'image': 'assets/images/perspectives/track_type.png',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: muhurta.themeGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sacred Library",
                        style: GoogleFonts.playfairDisplay(
                          color: muhurta.primaryTextColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "CHOOSE YOUR PERSPECTIVE",
                        style: TextStyle(
                          color: muhurta.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = perspectives[index];
                      return _buildPremiumPerspectiveCard(context, p, muhurta, index);
                    },
                    childCount: perspectives.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPerspectiveCard(
    BuildContext context,
    Map<String, dynamic> p,
    MuhurtaProvider muhurta,
    int index,
  ) {
    final Color pColor = p['color'] as Color;
    final String imagePath = p['image'] as String;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          final mantraProvider = context.read<MantraProvider>();
          mantraProvider.clearFilters();
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MantraListScreen(
                title: p['title'],
                perspectiveType: p['type'],
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: pColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: -10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                // Overlay Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Glass Effect & Border
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: pColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: pColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          p['icon'],
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p['title'],
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        p['subtitle'],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          letterSpacing: 0.5,
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
