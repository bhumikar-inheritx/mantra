import 'package:flutter/material.dart';

class AppColors {
  // Temple Morning Palette (Spiritual Light)
  static const Color sandalwoodWhite = Color(0xFFFDF5E6);
  static const Color sandalwoodLight = Color(0xFFFFF9F0);
  static const Color templeSaffron = Color(0xFFFF9933);
  static const Color ancientBrown = Color(0xFF3E2723);
  static const Color sacredMarigold = Color(0xFFFFBF00);
  static const Color earthyGrey = Color(0xFF795548);
  static const Color sacredRed = Color(0xFFC0392B);

  // Background and Surfaces
  static const Color bgDark = sandalwoodWhite; // For light theme, using white as primary bg
  static const Color bgSurface = sandalwoodLight;
  static const Color cosmicBlack = ancientBrown; // Keeping name for compatibility or mapping to deep brown
  static const Color surfaceDark = sandalwoodLight;

  // Accents (Mapping old names to new for easier migration where needed)
  static const Color templeGold = templeSaffron;
  static const Color saffronGlow = sacredMarigold;
  static const Color lotusWhite = sandalwoodWhite;
  static const Color mistGrey = earthyGrey;

  // Text Colors
  static const Color textBody = ancientBrown;
  static const Color textSecondary = earthyGrey;
  static const Color textAccent = templeSaffron;

  // Gradients
  static const LinearGradient goldenGradient = LinearGradient(
    colors: [templeSaffron, sacredMarigold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient spiritualGradient = LinearGradient(
    colors: [sandalwoodWhite, sandalwoodLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0x883E2723)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Chakra Colors
  static const Color chakraRoot = Color(0xFFFF0000);
  static const Color chakraSacral = Color(0xFFFF7F00);
  static const Color chakraSolar = Color(0xFFE5B800); // Muted yellow for light bg
  static const Color chakraHeart = Color(0xFF00A300); // Muted green
  static const Color chakraThroat = Color(0xFF0088CC); // Muted blue
  static const Color chakraThirdEye = Color(0xFF330066);
  static const Color chakraCrown = Color(0xFF660099);
}
