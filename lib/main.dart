import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/providers/app_state_provider.dart';
import 'package:islamic_app/core/providers/ramadan_provider.dart';
import 'package:islamic_app/features/splash/presentation/page/splash_page.dart';
import 'package:islamic_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:islamic_app/features/home/presentation/pages/home_page.dart';
import 'package:islamic_app/features/quran/pages/quran_reader_page.dart';
import 'package:islamic_app/features/quran/pages/surah_list_page.dart';
import 'package:islamic_app/features/quran/pages/juz_list_page.dart';
import 'package:islamic_app/features/quran/pages/tajweed_rules_page.dart';
import 'package:islamic_app/features/quran/pages/quran_topics_page.dart';
import 'package:islamic_app/features/quran/pages/topic_verses_page.dart';
import 'package:islamic_app/core/models/quran_topic.dart';
import 'package:islamic_app/features/bookmarks/presentation/pages/bookmarks_page.dart';
import 'package:islamic_app/features/settings/presentation/pages/settings_page.dart';
import 'package:islamic_app/features/search/presentation/pages/search_page.dart';
import 'package:islamic_app/features/qibla/presentation/pages/qibla_page.dart';
import 'package:islamic_app/features/tasbih/presentation/pages/tasbih_page.dart';
import 'package:islamic_app/features/ramadan/presentation/pages/ramadan_calendar_page.dart';
import 'package:islamic_app/features/ramadan/presentation/pages/ramadan_duas_page.dart';
import 'package:islamic_app/features/ramadan/presentation/pages/ramadan_settings_page.dart';
import 'package:islamic_app/features/ramadan/presentation/pages/daily_tracker_page.dart';
import 'package:islamic_app/features/ramadan/presentation/pages/quran_planner_page.dart';
import 'package:islamic_app/features/ramadan/presentation/pages/zakat_calculator_page.dart';
import 'package:islamic_app/core/providers/daily_tracker_provider.dart';
import 'package:islamic_app/core/providers/quran_plan_provider.dart';
import 'package:islamic_app/core/providers/zakat_provider.dart';
import 'package:islamic_app/features/umrah/presentation/pages/umrah_duas_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final appState = AppStateProvider();
  await appState.initialize();

  final ramadanProvider = RamadanProvider();
  await ramadanProvider.initialize();
  
  final dailyTrackerProvider = DailyTrackerProvider();
  await dailyTrackerProvider.initialize();

  final quranPlanProvider = QuranPlanProvider();
  await quranPlanProvider.initialize();

  final zakatProvider = ZakatProvider();
  await zakatProvider.initialize();
  
  // Set Ramadan start date (2026 Ramadan starts around February 17)
  // TODO: Make this configurable in settings
  await ramadanProvider.setRamadanStartDate(DateTime(2026, 2, 17));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: ramadanProvider),
        ChangeNotifierProvider.value(value: dailyTrackerProvider),
        ChangeNotifierProvider.value(value: quranPlanProvider),
        ChangeNotifierProvider.value(value: zakatProvider),
      ],
      child: const IslamicApp(),
    ),
  );
}

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Rushd',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: _getThemeMode(appState.themeMode),
          // Override theme if specific themed mode is selected
          builder: (context, child) {
             final themeData = AppTheme.getTheme(appState.themeMode);
             return Theme(
               data: themeData,
               child: child!,
             );
          },
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/onboarding': (context) => const OnboardingPage(),
            '/home': (context) => const HomePage(),
            '/surah-list': (context) => const SurahListPage(),
            '/juz-list': (context) => const JuzListPage(),
            '/tajweed-rules': (context) => const TajweedRulesPage(),
            '/bookmarks': (context) => const BookmarksPage(),
            '/settings': (context) => const SettingsPage(),
            '/search': (context) => const SearchPage(),
            '/qibla': (context) => const QiblaPage(),
            '/tasbih': (context) => const TasbihPage(),
            '/ramadan-calendar': (context) => const RamadanCalendarPage(),
            '/ramadan-duas': (context) => const RamadanDuasPage(),
            '/ramadan-settings': (context) => const RamadanSettingsPage(),
            '/daily-tracker': (context) => const DailyTrackerPage(),
            '/quran-planner': (context) => const QuranPlannerPage(),
            '/zakat-calculator': (context) => const ZakatCalculatorPage(),
            '/quran-topics': (context) => const QuranTopicsPage(),
            '/umrah-duas': (context) => const UmrahDuasPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/quran-reader') {
              // Support both int (surah only) and Map (surah + ayah) arguments
              int surahNumber = 1;
              int? initialAyahNumber;

              if (settings.arguments is int) {
                surahNumber = settings.arguments as int;
              } else if (settings.arguments is Map) {
                final args = settings.arguments as Map;
                surahNumber = args['surahNumber'] as int? ?? 1;
                initialAyahNumber = args['ayahNumber'] as int?;
              }

              return MaterialPageRoute(
                builder: (context) => QuranReaderPage(
                  surahNumber: surahNumber,
                  initialAyahNumber: initialAyahNumber,
                ),
              );
            }

            if (settings.name == '/topic-verses') {
              final topic = settings.arguments as QuranTopic;
              return MaterialPageRoute(
                builder: (context) => TopicVersesPage(topic: topic),
              );
            }
            return null;
          },
        );
      },
    );
  }

  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
      case AppThemeMode.roseGold:
      case AppThemeMode.oliveCream:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
