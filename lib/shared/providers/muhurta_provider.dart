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
  final TimePhase _currentPhase = TimePhase.morning;
  // Timer? _timer; // Disabled dynamic theming

  MuhurtaProvider() {
    // Theme is now locked to TimePhase.morning by default
    // _updatePhase();
    // _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updatePhase());
  }

  TimePhase get currentPhase => _currentPhase;

  /* 
  void _updatePhase() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final timeValue = hour + (minute / 60.0);

    TimePhase newPhase;

    if (timeValue >= 4.0 && timeValue < 6.0) {
      newPhase = TimePhase.brahmaMuhurta;
    } else if (timeValue >= 6.0 && timeValue < 8.0) {
      newPhase = TimePhase.sunrise;
    } else if (timeValue >= 8.0 && timeValue < 12.0) {
      newPhase = TimePhase.morning;
    } else if (timeValue >= 12.0 && timeValue < 15.0) {
      newPhase = TimePhase.midday;
    } else if (timeValue >= 15.0 && timeValue < 17.5) {
      newPhase = TimePhase.afternoon;
    } else if (timeValue >= 17.5 && timeValue < 19.0) {
      newPhase = TimePhase.sandhya;
    } else {
      newPhase = TimePhase.night;
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      notifyListeners();
    }
  }
  */

  String get greeting {
    switch (_currentPhase) {
      case TimePhase.brahmaMuhurta:
        return "Subha Brahma Muhurta";
      case TimePhase.sunrise:
        return "Suprabhatam";
      case TimePhase.morning:
        return "Shubh Prabhat";
      case TimePhase.midday:
        return "Shubh Madhyahan";
      case TimePhase.afternoon:
        return "Shubh Aparahn";
      case TimePhase.sandhya:
        return "Shubh Sandhya";
      case TimePhase.night:
        return "Shubh Ratri";
    }
  }

  String get phaseDescription {
    switch (_currentPhase) {
      case TimePhase.brahmaMuhurta:
        return "The Creator's Hour";
      case TimePhase.sunrise:
        return "Surya Udaya";
      case TimePhase.morning:
        return "Morning Sadhana";
      case TimePhase.midday:
        return "Peak Energy";
      case TimePhase.afternoon:
        return "Sustained Focus";
      case TimePhase.sandhya:
        return "Evening Devotion";
      case TimePhase.night:
        return "Deep Reflection";
    }
  }

  List<Color> get themeGradient {
    switch (_currentPhase) {
      case TimePhase.brahmaMuhurta:
        return [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)];
      case TimePhase.sunrise:
        return [const Color(0xFFFF9E7D), const Color(0xFFFFD194), AppColors.sandalwoodWhite];
      case TimePhase.morning:
        return [AppColors.sandalwoodWhite, AppColors.sandalwoodLight];
      case TimePhase.midday:
        return [const Color(0xFFFFF9E3), AppColors.sandalwoodWhite];
      case TimePhase.afternoon:
        return [AppColors.sandalwoodWhite, const Color(0xFFFDEEDC)];
      case TimePhase.sandhya:
        return [const Color(0xFFE94560), const Color(0xFFF96D00), const Color(0xFFFFBB5C)];
      case TimePhase.night:
        return [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)];
    }
  }

  Color get accentColor {
    switch (_currentPhase) {
      case TimePhase.brahmaMuhurta:
        return const Color(0xFFE94560);
      case TimePhase.sunrise:
        return AppColors.templeSaffron;
      case TimePhase.morning:
        return AppColors.templeGold;
      case TimePhase.midday:
        return AppColors.templeGold;
      case TimePhase.afternoon:
        return AppColors.templeSaffron;
      case TimePhase.sandhya:
        return AppColors.sacredRed;
      case TimePhase.night:
        return const Color(0xFF7B66FF);
    }
  }

  Color get onAccentColor {
    switch (_currentPhase) {
      case TimePhase.brahmaMuhurta:
      case TimePhase.sandhya:
      case TimePhase.night:
        return Colors.white;
      case TimePhase.sunrise:
      case TimePhase.morning:
      case TimePhase.midday:
      case TimePhase.afternoon:
        return AppColors.ancientBrown;
    }
  }

  bool get isDarkPhase => _currentPhase == TimePhase.brahmaMuhurta || _currentPhase == TimePhase.night || _currentPhase == TimePhase.sandhya;

  Color get primaryTextColor => isDarkPhase ? Colors.white : AppColors.ancientBrown;
  Color get secondaryTextColor => isDarkPhase ? Colors.white70 : AppColors.mistGrey;

  @override
  void dispose() {
    // _timer?.cancel();
    super.dispose();
  }
}
