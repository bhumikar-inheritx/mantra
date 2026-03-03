import 'package:deep_mantra/shared/providers/sankalp_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/chanting/providers/audio_chant_provider.dart';
import 'features/chanting/providers/manual_japa_provider.dart';
import 'features/chanting/providers/practice_session_provider.dart';
import 'features/chanting/services/audio_player_service.dart';
import 'features/chanting/services/haptic_service.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/providers/onboarding_provider.dart';
import 'features/dashboard/screens/onboarding_screen.dart';
import 'features/mantra/providers/mantra_provider.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_provider.dart';
import 'shared/providers/media_player_provider.dart';
import 'shared/providers/muhurta_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final audioPlayerService = AudioPlayerService();
  final hapticService = HapticService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (context) => MediaPlayerProvider(audioPlayerService),
        ),
        ChangeNotifierProvider(create: (_) => MantraProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => SankalpProvider()),
        ChangeNotifierProvider(create: (_) => MuhurtaProvider()),

        // New Practice & Chanting Providers
        ChangeNotifierProvider(create: (_) => PracticeSessionProvider()),
        ChangeNotifierProvider(
          create: (_) => AudioChantProvider(audioPlayerService),
        ),
        ChangeNotifierProvider(
          create: (_) => ManualJapaProvider(hapticService),
        ),
      ],
      child: const DeepMantraApp(),
    ),
  );
}

class DeepMantraApp extends StatelessWidget {
  const DeepMantraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Deep Mantra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      supportedLocales: const [Locale('en', ''), Locale('hi', '')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: const OnboardingScreen(),
    );
  }
}
