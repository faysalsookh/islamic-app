import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/models/ayah.dart';
import '../../../../core/models/bookmark.dart';
import '../../../../core/services/quran_data_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../widgets/quran_app_bar.dart';
import '../widgets/ayah_list_view.dart';
import '../widgets/mushaf_view.dart';
import '../widgets/reading_bottom_bar.dart';
import '../widgets/font_settings_sheet.dart';

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
  });

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  late Surah _currentSurah;
  List<Ayah> _ayahs = [];
  int _currentAyahIndex = 0;
  bool _showTranslation = true;
  bool _legendExpanded = false;
  bool _isLoading = true;
  int? _lastLoadedTranslationId;

  final QuranDataService _quranDataService = QuranDataService();

  @override
  void initState() {
    super.initState();
    _initializeSurahData();
    // Listen to audio service to sync current ayah with audio playback
    AudioService().addListener(_onAudioStateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppStateProvider>(context);
    
    // Check if translation setting changed
    if (_lastLoadedTranslationId != null && 
        _lastLoadedTranslationId != appState.selectedBengaliTranslationId) {
      _lastLoadedTranslationId = appState.selectedBengaliTranslationId;
      // Reload data with new translation
      _loadAyahsAsync();
    } else if (_lastLoadedTranslationId == null) {
      // Initialize validation tracker
      _lastLoadedTranslationId = appState.selectedBengaliTranslationId;
    }
  }

  @override
  void dispose() {
    // Remove listener and stop audio when leaving the page
    AudioService().removeListener(_onAudioStateChanged);
    AudioService().stop();
    super.dispose();
  }

  void _onAudioStateChanged() {
    final audioService = AudioService();
    // Sync UI with currently playing ayah
    if (audioService.currentSurah == _currentSurah.number &&
        audioService.currentAyah != null &&
        _ayahs.isNotEmpty) {
      final playingAyahNumber = audioService.currentAyah!;
      // Find the index of the currently playing ayah
      final index = _ayahs.indexWhere((a) => a.numberInSurah == playingAyahNumber);
      if (index != -1 && index != _currentAyahIndex) {
        setState(() {
          _currentAyahIndex = index;
        });
      }
    }
  }

  void _initializeSurahData() {
    // Find surah from complete data
    _currentSurah = SurahData.surahs.firstWhere(
      (s) => s.number == widget.surahNumber,
      orElse: () => SurahData.surahs.first,
    );

    // Load ayahs asynchronously
    _loadAyahsAsync();
  }

  Future<void> _loadAyahsAsync() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ayahs = await _quranDataService.getAyahsForSurah(widget.surahNumber);
      if (mounted) {
        setState(() {
          _ayahs = ayahs;
          _isLoading = false;
          // Set initial ayah index if provided
          if (widget.initialAyahNumber != null) {
            final index = ayahs.indexWhere((a) => a.numberInSurah == widget.initialAyahNumber);
            if (index != -1) {
              _currentAyahIndex = index;
            }
          }
        });
        // Auto-play if enabled
        _checkAutoPlay();
      }
    } catch (e) {
      debugPrint('Error loading surah: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Use fallback data
          _ayahs = _getFallbackAyahs();
        });
        // Auto-play if enabled (even with fallback data)
        _checkAutoPlay();
      }
    }
  }

  void _checkAutoPlay() {
    final appState = context.read<AppStateProvider>();
    if (appState.autoPlayOnPageOpen && _ayahs.isNotEmpty) {
      // Set repeat mode to surah so it plays through all ayahs
      final audioService = AudioService();
      audioService.setRepeatMode(AudioRepeatMode.surah);
      // Start playing from the first ayah
      final firstAyah = _ayahs[_currentAyahIndex].numberInSurah;
      audioService.playAyah(_currentSurah.number, firstAyah);
    }
  }

  List<Ayah> _getFallbackAyahs() {
    if (widget.surahNumber == 1) return AyahData.alFatihah;
    if (widget.surahNumber == 112) return AyahData.alIkhlas;
    return AyahData.alFatihah;
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
    HapticService().mediumImpact();
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
      HapticService().selectionClick();
      setState(() {
        _currentAyahIndex--;
      });
      // If audio is playing, play the previous ayah
      final audioService = AudioService();
      if (audioService.isPlaying) {
        final prevAyah = _ayahs[_currentAyahIndex].numberInSurah;
        audioService.playAyah(_currentSurah.number, prevAyah);
      }
    }
  }

  void _goToNextAyah() {
    if (_currentAyahIndex < _ayahs.length - 1) {
      HapticService().selectionClick();
      setState(() {
        _currentAyahIndex++;
      });
      // If audio is playing, play the next ayah
      final audioService = AudioService();
      if (audioService.isPlaying) {
        final nextAyah = _ayahs[_currentAyahIndex].numberInSurah;
        audioService.playAyah(_currentSurah.number, nextAyah);
      }
    }
  }

  void _showSurahInfo() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SurahInfoSheet(
        surah: _currentSurah,
        isDark: isDark,
        theme: theme,
      ),
    );
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
                icon: Icons.info_outline_rounded,
                label: 'Surah Information',
                onTap: () {
                  Navigator.pop(context);
                  _showSurahInfo();
                },
              ),
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
                icon: Icons.school_rounded,
                label: 'Tajweed Guide',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/tajweed-rules');
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  child: _isLoading
                      ? _buildLoadingState(isDark)
                      : _ayahs.isEmpty
                          ? _buildErrorState(isDark)
                          : Stack(
                              children: [
                                // Quran content
                                appState.isMushafView
                                    ? MushafView(
                                        surah: _currentSurah,
                                        ayahs: _ayahs,
                                        quranFontSize: appState.quranFontSize,
                                      )
                                    : AyahListView(
                                        surah: _currentSurah,
                                        ayahs: _ayahs,
                                        currentAyahIndex: _currentAyahIndex,
                                        showTranslation:
                                            _showTranslation && appState.showTranslation,
                                        quranFontSize: appState.quranFontSize,
                                        initialScrollIndex: widget.initialAyahNumber != null
                                            ? _currentAyahIndex
                                            : null,
                                        onAyahSelected: (index) {
                                          setState(() {
                                            _currentAyahIndex = index;
                                          });
                                        },
                                      ),

                                // Tajweed Color Legend (floating at bottom)
                                if (appState.showTajweedColors)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 8,
                                    child: TajweedColorLegend(
                                      isExpanded: _legendExpanded,
                                      onToggle: () {
                                        setState(() {
                                          _legendExpanded = !_legendExpanded;
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                ),

                // Bottom Control Bar
                ListenableBuilder(
                  listenable: AudioService(),
                  builder: (context, child) {
                    final audioService = AudioService();
                    return ReadingBottomBar(
                      isPlaying: audioService.isPlaying,
                      onPlayPause: () {
                        if (audioService.isPlaying) {
                          audioService.pause();
                        } else {
                          // Set repeat mode to surah so it plays through all ayahs
                          audioService.setRepeatMode(AudioRepeatMode.surah);
                          // Get current ayah (1-indexed for audio)
                          final currentAyah = _ayahs.isNotEmpty
                              ? _ayahs[_currentAyahIndex].numberInSurah
                              : 1;
                          audioService.playAyah(_currentSurah.number, currentAyah);
                        }
                      },
                      onNextAyah: _goToNextAyah,
                      onPreviousAyah: _goToPreviousAyah,
                      onBookmark: _addBookmark,
                      onSettings: _openFontSettings,
                      isMushafView: appState.isMushafView,
                      onToggleView: () {
                        appState.setMushafView(!appState.isMushafView);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Loading header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.mutedTealLight : AppColors.mutedTeal,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading ${_currentSurah.nameTransliteration}...',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Skeleton ayahs
          const AyahListSkeleton(itemCount: 4),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'সূরা লোড করতে সমস্যা হয়েছে',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'NotoSansBengali',
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAyahsAsync,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('পুনরায় চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.mutedTealLight : AppColors.mutedTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
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

class _SurahInfoSheet extends StatelessWidget {
  final Surah surah;
  final bool isDark;
  final ThemeData theme;

  const _SurahInfoSheet({
    required this.surah,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                      : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Surah number badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    surah.number.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Arabic name
              Text(
                surah.nameArabic,
                textDirection: TextDirection.rtl,
                style: AppTypography.surahNameArabic(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : theme.colorScheme.primary,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 8),
              // English name and meaning
              Text(
                surah.nameTransliteration,
                style: AppTypography.heading4(
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '(${surah.nameEnglish})',
                style: AppTypography.bodyMedium(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Info cards
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Revelation',
                      value: surah.revelationType,
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'Verses',
                      value: '${surah.ayahCount} Ayahs',
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.menu_book_rounded,
                      label: 'Position',
                      value: 'Surah ${surah.number}',
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.layers_outlined,
                      label: 'Juz',
                      // Juz start is available in surah
                      value: 'Juz ${surah.juzStart}', 
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final ThemeData theme;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground
            : theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkTextSecondary.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.caption(
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
