import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _QuranReaderPageState extends State<QuranReaderPage>
    with SingleTickerProviderStateMixin {
  late Surah _currentSurah;
  List<Ayah> _ayahs = [];
  int _currentAyahIndex = 0;
  bool _showTranslation = true;
  bool _legendExpanded = false;
  bool _isLoading = true;
  int? _lastLoadedTranslationId;
  bool _showQuickTips = false;

  final QuranDataService _quranDataService = QuranDataService();

  // Animation controller for tips
  late AnimationController _tipsAnimationController;
  late Animation<double> _tipsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSurahData();
    AudioService().addListener(_onAudioStateChanged);

    // Setup animation
    _tipsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tipsAnimation = CurvedAnimation(
      parent: _tipsAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Check if should show quick tips
    _checkQuickTips();
  }

  Future<void> _checkQuickTips() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTips = prefs.getBool('quran_reader_tips_seen') ?? false;
    if (!hasSeenTips && mounted) {
      setState(() => _showQuickTips = true);
      _tipsAnimationController.forward();
    }
  }

  Future<void> _dismissQuickTips() async {
    await _tipsAnimationController.reverse();
    if (mounted) {
      setState(() => _showQuickTips = false);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quran_reader_tips_seen', true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppStateProvider>(context);

    if (_lastLoadedTranslationId != null &&
        _lastLoadedTranslationId != appState.selectedBengaliTranslationId) {
      _lastLoadedTranslationId = appState.selectedBengaliTranslationId;
      _loadAyahsAsync();
    } else if (_lastLoadedTranslationId == null) {
      _lastLoadedTranslationId = appState.selectedBengaliTranslationId;
    }
  }

  @override
  void dispose() {
    AudioService().removeListener(_onAudioStateChanged);
    AudioService().stop();
    _tipsAnimationController.dispose();
    super.dispose();
  }

  void _onAudioStateChanged() {
    final audioService = AudioService();
    if (audioService.currentSurah == _currentSurah.number &&
        audioService.currentAyah != null &&
        _ayahs.isNotEmpty) {
      final playingAyahNumber = audioService.currentAyah!;
      final index =
          _ayahs.indexWhere((a) => a.numberInSurah == playingAyahNumber);
      if (index != -1 && index != _currentAyahIndex) {
        setState(() {
          _currentAyahIndex = index;
        });
      }
    }
  }

  void _initializeSurahData() {
    _currentSurah = SurahData.surahs.firstWhere(
      (s) => s.number == widget.surahNumber,
      orElse: () => SurahData.surahs.first,
    );
    _loadAyahsAsync();
  }

  Future<void> _loadAyahsAsync() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ayahs =
          await _quranDataService.getAyahsForSurah(widget.surahNumber);
      if (mounted) {
        setState(() {
          _ayahs = ayahs;
          _isLoading = false;
          if (widget.initialAyahNumber != null) {
            final index = ayahs
                .indexWhere((a) => a.numberInSurah == widget.initialAyahNumber);
            if (index != -1) {
              _currentAyahIndex = index;
            }
          }
        });
        _checkAutoPlay();
      }
    } catch (e) {
      debugPrint('Error loading surah: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _ayahs = _getFallbackAyahs();
        });
        _checkAutoPlay();
      }
    }
  }

  void _checkAutoPlay() {
    final appState = context.read<AppStateProvider>();
    if (appState.autoPlayOnPageOpen && _ayahs.isNotEmpty) {
      final audioService = AudioService();
      audioService.setRepeatMode(AudioRepeatMode.surah);
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

    _showSuccessSnackBar(
      'Bookmark saved for Ayah ${currentAyah.numberInSurah}',
      Icons.bookmark_added_rounded,
    );
  }

  void _showSuccessSnackBar(String message, IconData icon) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _goToPreviousAyah() {
    if (_currentAyahIndex > 0) {
      HapticService().selectionClick();
      setState(() {
        _currentAyahIndex--;
      });
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

  void _showJumpToAyah() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final result = await showModalBottomSheet<_NavigationResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _QuranNavigationSheet(
        currentSurahNumber: _currentSurah.number,
        totalAyahs: _ayahs.length,
        currentAyah: _currentAyahIndex + 1,
        isDark: isDark,
        theme: theme,
      ),
    );

    if (result == null || !mounted) return;

    if (result.surahNumber == _currentSurah.number) {
      // Same surah - just jump to ayah
      if (result.ayahNumber != null &&
          result.ayahNumber! > 0 &&
          result.ayahNumber! <= _ayahs.length) {
        setState(() {
          _currentAyahIndex = result.ayahNumber! - 1;
        });
      }
    } else {
      // Different surah - navigate to new page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuranReaderPage(
            surahNumber: result.surahNumber,
            initialAyahNumber: result.ayahNumber,
          ),
        ),
      );
    }
  }

  void _openMoreOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _OptionsSheet(
        isDark: isDark,
        theme: theme,
        showTranslation: _showTranslation,
        onSurahInfo: () {
          Navigator.pop(context);
          _showSurahInfo();
        },
        onJumpToAyah: () {
          Navigator.pop(context);
          _showJumpToAyah();
        },
        onTajweedGuide: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/tajweed-rules');
        },
        onToggleTranslation: () {
          _toggleTranslation();
          Navigator.pop(context);
        },
        onShowTips: () {
          Navigator.pop(context);
          setState(() => _showQuickTips = true);
          _tipsAnimationController.forward();
        },
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
          backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    // Top Bar
                    QuranAppBar(
                      surahNameEnglish: _currentSurah.nameTransliteration,
                      surahNameArabic: _currentSurah.nameArabic,
                      surahNumber: _currentSurah.number,
                      juzNumber: _currentSurah.juzStart,
                      currentAyah: _currentAyahIndex + 1,
                      totalAyahs: _ayahs.length,
                      onBackPressed: () => Navigator.pop(context),
                      onMenuPressed: _openMoreOptions,
                      onProgressTap: _showJumpToAyah,
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
                                            showTranslation: _showTranslation &&
                                                appState.showTranslation,
                                            quranFontSize: appState.quranFontSize,
                                            initialScrollIndex:
                                                widget.initialAyahNumber != null
                                                    ? _currentAyahIndex
                                                    : null,
                                            onAyahSelected: (index) {
                                              setState(() {
                                                _currentAyahIndex = index;
                                              });
                                            },
                                          ),

                                    // Tajweed Color Legend
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
                              audioService.setRepeatMode(AudioRepeatMode.surah);
                              final currentAyah = _ayahs.isNotEmpty
                                  ? _ayahs[_currentAyahIndex].numberInSurah
                                  : 1;
                              audioService.playAyah(
                                  _currentSurah.number, currentAyah);
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

                // Quick Tips Overlay
                if (_showQuickTips)
                  FadeTransition(
                    opacity: _tipsAnimation,
                    child: _QuickTipsOverlay(
                      onDismiss: _dismissQuickTips,
                      isDark: isDark,
                      theme: theme,
                    ),
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
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCard
                    : AppColors.cream,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load Surah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAyahsAsync,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.mutedTealLight : AppColors.mutedTeal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

/// Quick Tips Overlay for first-time users
class _QuickTipsOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  final bool isDark;
  final ThemeData theme;

  const _QuickTipsOverlay({
    required this.onDismiss,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quick Tips',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get the most out of your reading experience',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Tips
                _buildTipItem(
                  Icons.touch_app_rounded,
                  'Tap any ayah',
                  'Select it to play, bookmark, or view tafsir',
                ),
                _buildTipItem(
                  Icons.play_circle_rounded,
                  'Playback controls',
                  'Use center buttons to play/pause and navigate',
                ),
                _buildTipItem(
                  Icons.headphones_rounded,
                  'Audio settings',
                  'Choose Arabic only, Bengali, or both',
                ),
                _buildTipItem(
                  Icons.text_fields_rounded,
                  'Customize display',
                  'Adjust font size and toggle translations',
                ),
                _buildTipItem(
                  Icons.palette_rounded,
                  'Tajweed colors',
                  'Colored text shows pronunciation rules',
                ),

                const SizedBox(height: 32),

                // Dismiss button
                ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap anywhere to dismiss',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Options menu sheet
class _OptionsSheet extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final bool showTranslation;
  final VoidCallback onSurahInfo;
  final VoidCallback onJumpToAyah;
  final VoidCallback onTajweedGuide;
  final VoidCallback onToggleTranslation;
  final VoidCallback onShowTips;

  const _OptionsSheet({
    required this.isDark,
    required this.theme,
    required this.showTranslation,
    required this.onSurahInfo,
    required this.onJumpToAyah,
    required this.onTajweedGuide,
    required this.onToggleTranslation,
    required this.onShowTips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary)
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.more_horiz_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'More Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
              height: 1,
            ),

            // Options
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: Icons.info_outline_rounded,
                    label: 'Surah Information',
                    subtitle: 'Details about this surah',
                    onTap: onSurahInfo,
                  ),
                  _buildOptionTile(
                    icon: Icons.explore_rounded,
                    label: 'Navigate Quran',
                    subtitle: 'Jump to Surah, Juz, or Ayah',
                    onTap: onJumpToAyah,
                  ),
                  _buildOptionTile(
                    icon: Icons.school_rounded,
                    label: 'Tajweed Guide',
                    subtitle: 'Learn pronunciation rules',
                    onTap: onTajweedGuide,
                  ),
                  _buildOptionTile(
                    icon: showTranslation
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    label:
                        showTranslation ? 'Hide Translation' : 'Show Translation',
                    subtitle: 'Toggle translation display',
                    onTap: onToggleTranslation,
                  ),
                  _buildOptionTile(
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Show Quick Tips',
                    subtitle: 'View usage guide',
                    onTap: onShowTips,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation result class
class _NavigationResult {
  final int surahNumber;
  final int? ayahNumber;

  _NavigationResult(this.surahNumber, this.ayahNumber);
}

/// Professional Quran Navigation Sheet with Surah, Juz, and Ayah selection
class _QuranNavigationSheet extends StatefulWidget {
  final int currentSurahNumber;
  final int totalAyahs;
  final int currentAyah;
  final bool isDark;
  final ThemeData theme;

  const _QuranNavigationSheet({
    required this.currentSurahNumber,
    required this.totalAyahs,
    required this.currentAyah,
    required this.isDark,
    required this.theme,
  });

  @override
  State<_QuranNavigationSheet> createState() => _QuranNavigationSheetState();
}

class _QuranNavigationSheetState extends State<_QuranNavigationSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late TextEditingController _ayahController;

  int _selectedJuz = 1;
  String _searchQuery = '';
  String? _ayahError;

  // Juz data mapping (juz number -> starting surah:ayah)
  static const Map<int, Map<String, int>> juzData = {
    1: {'surah': 1, 'ayah': 1},
    2: {'surah': 2, 'ayah': 142},
    3: {'surah': 2, 'ayah': 253},
    4: {'surah': 3, 'ayah': 93},
    5: {'surah': 4, 'ayah': 24},
    6: {'surah': 4, 'ayah': 148},
    7: {'surah': 5, 'ayah': 82},
    8: {'surah': 6, 'ayah': 111},
    9: {'surah': 7, 'ayah': 88},
    10: {'surah': 8, 'ayah': 41},
    11: {'surah': 9, 'ayah': 93},
    12: {'surah': 11, 'ayah': 6},
    13: {'surah': 12, 'ayah': 53},
    14: {'surah': 15, 'ayah': 1},
    15: {'surah': 17, 'ayah': 1},
    16: {'surah': 18, 'ayah': 75},
    17: {'surah': 21, 'ayah': 1},
    18: {'surah': 23, 'ayah': 1},
    19: {'surah': 25, 'ayah': 21},
    20: {'surah': 27, 'ayah': 56},
    21: {'surah': 29, 'ayah': 46},
    22: {'surah': 33, 'ayah': 31},
    23: {'surah': 36, 'ayah': 28},
    24: {'surah': 39, 'ayah': 32},
    25: {'surah': 41, 'ayah': 47},
    26: {'surah': 46, 'ayah': 1},
    27: {'surah': 51, 'ayah': 31},
    28: {'surah': 58, 'ayah': 1},
    29: {'surah': 67, 'ayah': 1},
    30: {'surah': 78, 'ayah': 1},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _ayahController = TextEditingController(text: widget.currentAyah.toString());

    // Find current juz
    final currentSurah = SurahData.getSurahByNumber(widget.currentSurahNumber);
    if (currentSurah != null) {
      _selectedJuz = currentSurah.juzStart;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _ayahController.dispose();
    super.dispose();
  }

  List<Surah> get _filteredSurahs {
    if (_searchQuery.isEmpty) {
      return SurahData.surahs;
    }
    return SurahData.searchSurahs(_searchQuery);
  }

  void _onSurahSelected(Surah surah) {
    Navigator.pop(context, _NavigationResult(surah.number, 1));
  }

  void _onJuzSelected(int juz) {
    final juzInfo = juzData[juz];
    if (juzInfo != null) {
      Navigator.pop(context, _NavigationResult(juzInfo['surah']!, juzInfo['ayah']));
    }
  }

  void _goToAyah() {
    final text = _ayahController.text.trim();
    final number = int.tryParse(text);

    if (number == null || number < 1 || number > widget.totalAyahs) {
      setState(() {
        _ayahError = 'Enter 1 - ${widget.totalAyahs}';
      });
      return;
    }

    Navigator.pop(context, _NavigationResult(widget.currentSurahNumber, number));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: (widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary)
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    color: widget.theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Navigate Quran',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSurface : AppColors.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: widget.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Surah'),
                Tab(text: 'Juz'),
                Tab(text: 'Ayah'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSurahTab(),
                _buildJuzTab(),
                _buildAyahTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search surah...',
              hintStyle: TextStyle(
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              filled: true,
              fillColor: widget.isDark ? AppColors.darkSurface : AppColors.cream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: widget.isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Surah List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filteredSurahs.length,
            itemBuilder: (context, index) {
              final surah = _filteredSurahs[index];
              final isSelected = surah.number == widget.currentSurahNumber;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.theme.colorScheme.primary.withValues(alpha: 0.1)
                      : widget.isDark
                          ? AppColors.darkSurface
                          : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: widget.theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onSurahSelected(surah),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Surah Number
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.theme.colorScheme.primary
                                  : widget.isDark
                                      ? AppColors.darkCard
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                surah.number.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : widget.isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Surah Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surah.nameTransliteration,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${surah.ayahCount} Ayahs • ${surah.revelationType}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arabic Name
                          Text(
                            surah.nameArabic,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Scheherazade',
                              fontSize: 20,
                              color: isSelected
                                  ? widget.theme.colorScheme.primary
                                  : widget.isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJuzTab() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juz = index + 1;
        final isCurrentJuz = juz == _selectedJuz;
        final juzInfo = juzData[juz];
        final startSurah = juzInfo != null
            ? SurahData.getSurahByNumber(juzInfo['surah']!)
            : null;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onJuzSelected(juz),
            borderRadius: BorderRadius.circular(12),
            child: Tooltip(
              message: startSurah != null
                  ? 'Starts: ${startSurah.nameTransliteration}'
                  : 'Juz $juz',
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentJuz
                      ? widget.theme.colorScheme.primary
                      : widget.isDark
                          ? AppColors.darkSurface
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrentJuz
                      ? null
                      : Border.all(
                          color: widget.isDark
                              ? AppColors.dividerDark
                              : Colors.grey.shade200,
                        ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      juz.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCurrentJuz
                            ? Colors.white
                            : widget.isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Juz',
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrentJuz
                            ? Colors.white.withValues(alpha: 0.8)
                            : widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAyahTab() {
    final currentSurah = SurahData.getSurahByNumber(widget.currentSurahNumber);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Surah Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.currentSurahNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSurah?.nameTransliteration ?? 'Surah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${widget.totalAyahs} Ayahs • Currently at Ayah ${widget.currentAyah}',
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currentSurah?.nameArabic ?? '',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 24,
                    color: widget.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ayah Input
          Text(
            'Go to Ayah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter ayah number (1 - ${widget.totalAyahs})',
            style: TextStyle(
              fontSize: 13,
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ayahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ayah number',
                    errorText: _ayahError,
                    filled: true,
                    fillColor:
                        widget.isDark ? AppColors.darkSurface : AppColors.cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.tag_rounded,
                      color: widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) {
                    if (_ayahError != null) {
                      setState(() => _ayahError = null);
                    }
                  },
                  onSubmitted: (_) => _goToAyah(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToAyah,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text(
                    'Go',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Jump Buttons
          Text(
            'Quick Jump',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickJumpChip('First', 1),
              if (widget.totalAyahs > 10) _buildQuickJumpChip('10', 10),
              if (widget.totalAyahs > 25) _buildQuickJumpChip('25', 25),
              if (widget.totalAyahs > 50) _buildQuickJumpChip('50', 50),
              if (widget.totalAyahs > 100) _buildQuickJumpChip('100', 100),
              _buildQuickJumpChip('Middle', (widget.totalAyahs / 2).round()),
              _buildQuickJumpChip('Last', widget.totalAyahs),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickJumpChip(String label, int ayah) {
    final isSelected = ayah == widget.currentAyah;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context, _NavigationResult(widget.currentSurahNumber, ayah));
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.theme.colorScheme.primary
                : widget.isDark
                    ? AppColors.darkSurface
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(
                    color: widget.isDark
                        ? AppColors.dividerDark
                        : Colors.grey.shade300,
                  ),
          ),
          child: Text(
            label == 'First' || label == 'Middle' || label == 'Last'
                ? '$label ($ayah)'
                : 'Ayah $ayah',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : widget.isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Surah Info Sheet
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary)
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Surah number badge
              Container(
                width: 72,
                height: 72,
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
                      fontSize: 26,
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
                  color:
                      isDark ? AppColors.darkTextPrimary : theme.colorScheme.primary,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),

              // English name
              Text(
                surah.nameTransliteration,
                style: AppTypography.heading4(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '(${surah.nameEnglish})',
                style: AppTypography.bodyMedium(
                  color:
                      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                      borderRadius: BorderRadius.circular(12),
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
            ? AppColors.darkSurface
            : theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
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
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
