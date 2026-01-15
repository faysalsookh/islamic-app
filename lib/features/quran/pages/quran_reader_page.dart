import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/models/ayah.dart';
import '../../../../core/models/bookmark.dart';
import '../widgets/quran_app_bar.dart';
import '../widgets/ayah_list_view.dart';
import '../widgets/mushaf_view.dart';
import '../widgets/reading_bottom_bar.dart';
import '../widgets/font_settings_sheet.dart';

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
  });

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  late Surah _currentSurah;
  late List<Ayah> _ayahs;
  int _currentAyahIndex = 0;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  void _loadSurahData() {
    // Find surah from data
    _currentSurah = SurahData.surahs.firstWhere(
      (s) => s.number == widget.surahNumber,
      orElse: () => SurahData.surahs.first,
    );

    // Load ayahs based on surah number
    if (widget.surahNumber == 1) {
      _ayahs = AyahData.alFatihah;
    } else if (widget.surahNumber == 112) {
      _ayahs = AyahData.alIkhlas;
    } else {
      // For demo, use Al-Fatihah as default
      _ayahs = AyahData.alFatihah;
    }
  }

  void _toggleTranslation() {
    setState(() {
      _showTranslation = !_showTranslation;
    });
  }

  void _openFontSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FontSettingsSheet(),
    );
  }

  void _addBookmark() {
    final appState = context.read<AppStateProvider>();
    final currentAyah = _ayahs[_currentAyahIndex];

    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surahNumber: _currentSurah.number,
      surahNameArabic: _currentSurah.nameArabic,
      surahNameEnglish: _currentSurah.nameTransliteration,
      ayahNumber: currentAyah.numberInSurah,
      ayahSnippet: currentAyah.textArabic.length > 50
          ? '${currentAyah.textArabic.substring(0, 50)}...'
          : currentAyah.textArabic,
      createdAt: DateTime.now(),
      label: BookmarkLabels.dailyRead,
    );

    appState.addBookmark(bookmark);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bookmark added for ${_currentSurah.nameTransliteration}, Ayah ${currentAyah.numberInSurah}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _goToPreviousAyah() {
    if (_currentAyahIndex > 0) {
      setState(() {
        _currentAyahIndex--;
      });
    }
  }

  void _goToNextAyah() {
    if (_currentAyahIndex < _ayahs.length - 1) {
      setState(() {
        _currentAyahIndex++;
      });
    }
  }

  void _openMoreOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _OptionTile(
                icon: Icons.share_rounded,
                label: 'Share Ayah',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _OptionTile(
                icon: Icons.copy_rounded,
                label: 'Copy Text',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _OptionTile(
                icon: Icons.auto_stories_rounded,
                label: 'View Tafsir',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _OptionTile(
                icon: Icons.translate_rounded,
                label: _showTranslation ? 'Hide Translation' : 'Show Translation',
                onTap: () {
                  _toggleTranslation();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar
                QuranAppBar(
                  surahNameEnglish: _currentSurah.nameTransliteration,
                  surahNameArabic: _currentSurah.nameArabic,
                  surahNumber: _currentSurah.number,
                  juzNumber: _currentSurah.juzStart,
                  onBackPressed: () => Navigator.pop(context),
                  onMenuPressed: _openMoreOptions,
                ),

                // Main Content
                Expanded(
                  child: appState.isMushafView
                      ? MushafView(
                          surah: _currentSurah,
                          ayahs: _ayahs,
                          quranFontSize: appState.quranFontSize,
                        )
                      : AyahListView(
                          surah: _currentSurah,
                          ayahs: _ayahs,
                          currentAyahIndex: _currentAyahIndex,
                          showTranslation: _showTranslation && appState.showTranslation,
                          quranFontSize: appState.quranFontSize,
                          onAyahSelected: (index) {
                            setState(() {
                              _currentAyahIndex = index;
                            });
                          },
                        ),
                ),

                // Bottom Control Bar
                ReadingBottomBar(
                  isPlaying: appState.isPlaying,
                  onPlayPause: () {
                    appState.setIsPlaying(!appState.isPlaying);
                  },
                  onNextAyah: _goToNextAyah,
                  onPreviousAyah: _goToPreviousAyah,
                  onBookmark: _addBookmark,
                  onSettings: _openFontSettings,
                  isMushafView: appState.isMushafView,
                  onToggleView: () {
                    appState.setMushafView(!appState.isMushafView);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color:
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: AppTypography.bodyLarge(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
