import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum TimePhase {
  brahmaMuhurta,
  sunrise,
  morning,
  midday,
  afternoon,
  sandhya,
  night,
}

class MuhurtaProvider extends ChangeNotifier {
  // Theme is now locked to a static premium state
  final TimePhase _currentPhase = TimePhase.morning;

  MuhurtaProvider();

  TimePhase get currentPhase => _currentPhase;

  String get greeting => "Namaste";

  String get phaseDescription => "Divine Presence";

  List<Color> get themeGradient => [
    AppColors.sandalwoodWhite,
    AppColors.sandalwoodLight,
  ];

  Color get accentColor => AppColors.templeGold;

  Color get onAccentColor => AppColors.ancientBrown;

  bool get isDarkPhase => false;

  Color get primaryTextColor => AppColors.ancientBrown;
  Color get secondaryTextColor => AppColors.earthyGrey;

  @override
  void dispose() {
    super.dispose();
  }
}
