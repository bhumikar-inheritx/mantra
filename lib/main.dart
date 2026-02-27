import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_provider.dart';
import 'features/mantra/providers/mantra_provider.dart';
import 'features/japa/providers/japa_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => MantraProvider()),
        ChangeNotifierProvider(create: (_) => JapaProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
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
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
      ],
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
