import 'package:alarm/alarm.dart';
import 'package:audio_session/audio_session.dart';
import 'package:deep_mantra/shared/providers/sankalp_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

import 'features/chanting/providers/audio_chant_provider.dart';
import 'features/chanting/providers/manual_japa_provider.dart';
import 'features/chanting/providers/practice_session_provider.dart';
import 'features/chanting/services/audio_player_service.dart';
import 'features/chanting/services/haptic_service.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/providers/mini_player_provider.dart';
import 'features/dashboard/providers/onboarding_provider.dart';
import 'features/dashboard/providers/quick_ritual_provider.dart';
import 'features/dashboard/screens/splash_screen.dart';
import 'features/dashboard/widgets/global_player_wrapper.dart';
import 'features/mantra/providers/mantra_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/alarm_provider.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_provider.dart';
import 'shared/providers/audio_player_provider.dart';
import 'shared/services/global_audio_player_service.dart';
import 'shared/providers/muhurta_provider.dart';

import 'package:flutter/services.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Alarm.init();

  // Configure Audio Session for low-latency and proper background handling
  try {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers |
          AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));
  } catch (e) {
    debugPrint('AudioSession configuration failed: $e');
  }
  
  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ensure status bar and bottom navigation are visible
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.top,
    SystemUiOverlay.bottom,
  ]);

  // Initialise services
  final globalAudioService = GlobalAudioPlayerService();
  final chantAudioService = AudioPlayerService(); // Separate instance for chanting
  final hapticService = HapticService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(
          create: (context) => AudioPlayerProvider(globalAudioService),
        ),
        ChangeNotifierProvider(create: (_) => MiniPlayerProvider()),
        ChangeNotifierProvider(create: (_) => MantraProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => QuickRitualProvider()),
        ChangeNotifierProvider(create: (_) => SankalpProvider()),
        ChangeNotifierProvider(create: (_) => MuhurtaProvider()),

        // New Practice & Chanting Providers
        ChangeNotifierProvider(create: (_) => PracticeSessionProvider()),
        ChangeNotifierProvider(
          create: (_) => AudioChantProvider(chantAudioService),
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

    return ScreenUtilInit(
      designSize: const Size(390, 844), // Standard iPhone 13 Pro size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Deep Mantra',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          navigatorKey: navigatorKey,
          navigatorObservers: [routeObserver],
          locale: localeProvider.locale,
          supportedLocales: const [Locale('en', ''), Locale('hi', '')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return GlobalMiniPlayerWrapper(child: child!);
          },
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
