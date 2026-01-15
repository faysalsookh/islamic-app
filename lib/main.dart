import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/providers/app_state_provider.dart';
import 'package:islamic_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:islamic_app/features/home/presentation/pages/home_page.dart';
import 'package:islamic_app/features/quran/pages/quran_reader_page.dart';
import 'package:islamic_app/features/quran/pages/surah_list_page.dart';
import 'package:islamic_app/features/bookmarks/presentation/pages/bookmarks_page.dart';
import 'package:islamic_app/features/settings/presentation/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final appState = AppStateProvider();
  await appState.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
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
          title: 'Noble Quran',
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
          initialRoute: appState.hasCompletedOnboarding ? '/home' : '/onboarding',
          routes: {
            '/onboarding': (context) => const OnboardingPage(),
            '/home': (context) => const HomePage(),
            '/surah-list': (context) => const SurahListPage(),
            '/bookmarks': (context) => const BookmarksPage(),
            '/settings': (context) => const SettingsPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/quran-reader') {
              final surahNumber = settings.arguments as int? ?? 1;
              return MaterialPageRoute(
                builder: (context) => QuranReaderPage(surahNumber: surahNumber),
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
