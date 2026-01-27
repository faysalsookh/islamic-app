import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/elegant_card.dart';
import '../../../../core/models/tajweed.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/quran_data_service.dart';
import '../../../../core/utils/responsive.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.heading2(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 700 : double.infinity,
              ),
              child: ListView(
            padding: EdgeInsets.all(horizontalPadding),
            children: [
              // Profile section
              _SettingsSection(
                title: 'Profile',
                isTablet: isTablet,
                children: [
                  _ProfileCard(
                    name: appState.userName.isNotEmpty
                        ? appState.userName
                        : 'Set your name',
                    onTap: () => _showNameEditDialog(context, appState),
                    isTablet: isTablet,
                  ),
                ],
              ),

              // Appearance section
              _SettingsSection(
                title: 'Appearance',
                isTablet: isTablet,
                children: [
                  _ThemeSelector(
                    currentTheme: appState.themeMode,
                    onThemeChanged: appState.setThemeMode,
                    isTablet: isTablet,
                  ),
                ],
              ),

              // Reading settings section
              _SettingsSection(
                title: 'Reading',
                isTablet: isTablet,
                children: [
                  _SettingsTile(
                    icon: Icons.text_fields_rounded,
                    title: 'Arabic Font Style',
                    subtitle: appState.arabicFontStyle.displayName,
                    onTap: () => _showFontStyleDialog(context, appState),
                    isTablet: isTablet,
                  ),
                  _SettingsTile(
                    icon: Icons.format_size_rounded,
                    title: 'Font Size',
                    subtitle: _getFontSizeName(appState.quranFontSize),
                    onTap: () => _showFontSizeDialog(context, appState),
                    isTablet: isTablet,
                  ),
                  _SettingsTile(
                    icon: Icons.translate_rounded,
                    title: 'Translation Language',
                    subtitle: appState.translationLanguage.displayName,
                    onTap: () =>
                        _showTranslationLanguageDialog(context, appState),
                    isTablet: isTablet,
                  ),
                  if (appState.translationLanguage == TranslationLanguage.bengali ||
                      appState.translationLanguage == TranslationLanguage.both)
                    _SettingsTile(
                      icon: Icons.menu_book_rounded,
                      title: 'Bengali Translation Source',
                      subtitle: _getBengaliTranslationName(appState.selectedBengaliTranslationId),
                      onTap: () => _showBengaliTranslationDialog(context, appState),
                      isTablet: isTablet,
                    ),
                  if (appState.translationLanguage == TranslationLanguage.english ||
                      appState.translationLanguage == TranslationLanguage.both)
                    _SettingsTile(
                      icon: Icons.translate_rounded,
                      title: 'English Translation Source',
                      subtitle: _getEnglishTranslationName(appState.selectedEnglishTranslationId),
                      onTap: () => _showEnglishTranslationDialog(context, appState),
                      isTablet: isTablet,
                    ),
                  _SettingsTile(
                    icon: Icons.abc_rounded,
                    title: 'Transliteration',
                    subtitle: appState.transliterationLanguage.displayName,
                    onTap: () =>
                        _showTransliterationLanguageDialog(context, appState),
                    isTablet: isTablet,
                  ),
                  _ToggleTile(
                    icon: Icons.visibility_rounded,
                    title: 'Show Translation',
                    value: appState.showTranslation,
                    onChanged: (_) => appState.toggleShowTranslation(),
                    isTablet: isTablet,
                  ),
                  _ToggleTile(
                    icon: Icons.text_snippet_rounded,
                    title: 'Show Transliteration',
                    value: appState.showTransliteration,
                    onChanged: (_) => appState.toggleShowTransliteration(),
                    isTablet: isTablet,
                  ),
                  _ToggleTile(
                    icon: Icons.auto_stories_rounded,
                    title: 'Mushaf View Mode',
                    subtitle: 'Page-style like printed Quran',
                    value: appState.isMushafView,
                    onChanged: appState.setMushafView,
                    isTablet: isTablet,
                  ),
                ],
              ),

              // Tajweed settings section
              _SettingsSection(
                title: 'Tajweed',
                isTablet: isTablet,
                children: [
                  _ToggleTile(
                    icon: Icons.palette_rounded,
                    title: 'Show Tajweed Colors',
                    subtitle: 'Color-coded recitation rules',
                    value: appState.showTajweedColors,
                    onChanged: (_) => appState.toggleShowTajweedColors(),
                    isTablet: isTablet,
                  ),
                  _ToggleTile(
                    icon: Icons.school_rounded,
                    title: 'Learning Mode',
                    subtitle: 'Tap colored text to see rule explanation',
                    value: appState.tajweedLearningMode,
                    onChanged: (_) => appState.toggleTajweedLearningMode(),
                    isTablet: isTablet,
                  ),
                  _TajweedLegendTile(isTablet: isTablet),
                ],
              ),

              // Audio section
              _SettingsSection(
                title: 'Audio',
                isTablet: isTablet,
                children: [
                  _SettingsTile(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Reciter (Arabic)',
                    subtitle: appState.selectedReciter.displayName,
                    onTap: () => _showReciterDialog(context, appState),
                    isTablet: isTablet,
                  ),
                  _SettingsTile(
                    icon: Icons.translate_rounded,
                    title: 'Bengali Audio Source',
                    subtitle: '${appState.bengaliAudioSource.displayName} - ${appState.bengaliAudioSource.description}',
                    onTap: () => _showBengaliAudioSourceDialog(context, appState),
                    isTablet: isTablet,
                  ),
                  _SettingsTile(
                    icon: Icons.speed_rounded,
                    title: 'Default Playback Speed',
                    subtitle: '${appState.defaultPlaybackSpeed}x',
                    onTap: () => _showPlaybackSpeedDialog(context, appState),
                    isTablet: isTablet,
                  ),
                  _ToggleTile(
                    icon: Icons.play_circle_rounded,
                    title: 'Auto-play on Page Open',
                    subtitle: 'Start playing when opening a surah',
                    value: appState.autoPlayOnPageOpen,
                    onChanged: appState.setAutoPlayOnPageOpen,
                    isTablet: isTablet,
                  ),
                ],
              ),

              // Accessibility section
              _SettingsSection(
                title: 'Accessibility',
                isTablet: isTablet,
                children: [
                  _ToggleTile(
                    icon: Icons.pan_tool_rounded,
                    title: 'Left-handed Mode',
                    subtitle: 'Move controls to the left side',
                    value: appState.isLeftHanded,
                    onChanged: appState.setLeftHanded,
                    isTablet: isTablet,
                  ),
                ],
              ),

              // Data & Storage section
              _SettingsSection(
                title: 'Data & Storage',
                isTablet: isTablet,
                children: [
                  _SettingsTile(
                    icon: Icons.refresh_rounded,
                    title: 'Refresh Quran Data',
                    subtitle: 'Clear cache and re-download with Tajweed',
                    onTap: () => _refreshQuranData(context),
                    isTablet: isTablet,
                  ),
                ],
              ),

              // About section
              _SettingsSection(
                title: 'About',
                isTablet: isTablet,
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    onTap: () {},
                    isTablet: isTablet,
                  ),
                  _SettingsTile(
                    icon: Icons.favorite_rounded,
                    title: 'Rate This App',
                    onTap: () {
                      // TODO: Open app store
                    },
                    isTablet: isTablet,
                  ),
                  _SettingsTile(
                    icon: Icons.share_rounded,
                    title: 'Share With Friends',
                    onTap: () {
                      // TODO: Share app
                    },
                    isTablet: isTablet,
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 32 : 24),

              // Reset progress warning
              Center(
                child: TextButton(
                  onPressed: () => _showResetDialog(context),
                  child: Text(
                    'Reset All Settings',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 48 : 40),
            ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFontSizeName(double size) {
    if (size <= QuranFontSizes.extraSmall) return 'Extra Small';
    if (size <= QuranFontSizes.small) return 'Small';
    if (size <= QuranFontSizes.medium) return 'Medium';
    if (size <= QuranFontSizes.large) return 'Large';
    if (size <= QuranFontSizes.extraLarge) return 'Extra Large';
    return 'Jumbo';
  }

  void _showNameEditDialog(BuildContext context, AppStateProvider appState) {
    final controller = TextEditingController(text: appState.userName);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.setUserName(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFontStyleDialog(BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SelectionSheet(
        title: 'Arabic Font Style',
        options: ArabicFontStyle.values.map((style) => _SelectionOption(
          title: style.displayName,
          isSelected: appState.arabicFontStyle == style,
          onTap: () {
            appState.setArabicFontStyle(style);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showTransliterationLanguageDialog(
      BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SelectionSheet(
        title: 'Transliteration Language',
        options: TransliterationLanguage.values.map((lang) => _SelectionOption(
          title: lang.displayName,
          isSelected: appState.transliterationLanguage == lang,
          onTap: () {
            appState.setTransliterationLanguage(lang);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showPlaybackSpeedDialog(BuildContext context, AppStateProvider appState) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      builder: (context) => _SelectionSheet(
        title: 'Playback Speed',
        options: speeds.map((speed) => _SelectionOption(
          title: '${speed}x',
          isSelected: appState.defaultPlaybackSpeed == speed,
          onTap: () {
            appState.setDefaultPlaybackSpeed(speed);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SelectionSheet(
        title: 'Font Size',
        options: [
          _SelectionOption(
            title: 'Extra Small',
            isSelected: appState.quranFontSize == QuranFontSizes.extraSmall,
            onTap: () {
              appState.setQuranFontSize(QuranFontSizes.extraSmall);
              Navigator.pop(context);
            },
          ),
          _SelectionOption(
            title: 'Small',
            isSelected: appState.quranFontSize == QuranFontSizes.small,
            onTap: () {
              appState.setQuranFontSize(QuranFontSizes.small);
              Navigator.pop(context);
            },
          ),
          _SelectionOption(
            title: 'Medium',
            isSelected: appState.quranFontSize == QuranFontSizes.medium,
            onTap: () {
              appState.setQuranFontSize(QuranFontSizes.medium);
              Navigator.pop(context);
            },
          ),
          _SelectionOption(
            title: 'Large',
            isSelected: appState.quranFontSize == QuranFontSizes.large,
            onTap: () {
              appState.setQuranFontSize(QuranFontSizes.large);
              Navigator.pop(context);
            },
          ),
          _SelectionOption(
            title: 'Extra Large',
            isSelected: appState.quranFontSize == QuranFontSizes.extraLarge,
            onTap: () {
              appState.setQuranFontSize(QuranFontSizes.extraLarge);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTranslationLanguageDialog(
      BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SelectionSheet(
        title: 'Translation Language',
        options: [
          _SelectionOption(
            title: 'English',
            isSelected: appState.translationLanguage == TranslationLanguage.english,
            onTap: () {
              appState.setTranslationLanguage(TranslationLanguage.english);
              Navigator.pop(context);
            },
          ),
          _SelectionOption(
            title: 'Bengali',
            isSelected: appState.translationLanguage == TranslationLanguage.bengali,
            onTap: () {
              appState.setTranslationLanguage(TranslationLanguage.bengali);
              Navigator.pop(context);
            },
          ),
          _SelectionOption(
            title: 'English & Bengali',
            isSelected: appState.translationLanguage == TranslationLanguage.both,
            onTap: () {
              appState.setTranslationLanguage(TranslationLanguage.both);
              Navigator.pop(context);
            },
          ),
          _SelectionOption(
            title: 'None',
            isSelected: appState.translationLanguage == TranslationLanguage.none,
            onTap: () {
              appState.setTranslationLanguage(TranslationLanguage.none);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showReciterDialog(BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary)
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Reciter',
                            style: AppTypography.heading2(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reciter list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: Reciter.values.length,
                      itemBuilder: (context, index) {
                        final reciter = Reciter.values[index];
                        final isSelected = appState.selectedReciter == reciter;
                        
                        return _buildReciterListItem(
                          context: context,
                          reciter: reciter,
                          isSelected: isSelected,
                          isDark: isDark,
                          theme: theme,
                          onTap: () {
                            appState.setSelectedReciter(reciter);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReciterListItem({
    required BuildContext context,
    required Reciter reciter,
    required bool isSelected,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkSurface : AppColors.cream.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Reciter photo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: reciter.photoUrl != null
                  ? Image.asset(
                      reciter.photoUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildReciterInitialAvatar(reciter, isSelected, isDark, theme);
                      },
                    )
                  : _buildReciterInitialAvatar(reciter, isSelected, isDark, theme),
            ),
            const SizedBox(width: 14),
            // Reciter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reciter.displayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reciter.displayNameArabic,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Amiri',
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reciter.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary)
                          .withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReciterInitialAvatar(Reciter reciter, bool isSelected, bool isDark, ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : (isDark ? AppColors.darkSurface : AppColors.cream),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          _getReciterInitials(reciter),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Amiri',
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  String _getReciterInitials(Reciter reciter) {
    switch (reciter) {
      case Reciter.misharyRashidAlafasy:
        return 'م';
      case Reciter.abdulRahmanAlSudais:
        return 'س';
      case Reciter.maherAlMuaiqly:
        return 'ﻡ';
      case Reciter.saadAlGhamdi:
        return 'غ';
      case Reciter.abuBakrAlShatri:
        return 'أ';
      case Reciter.haniArRifai:
        return 'ه';
      case Reciter.hudhaify:
        return 'ح';
      case Reciter.aliJaber:
        return 'ج';
      case Reciter.yasserAlDosari:
        return 'ي';
      case Reciter.nasserAlQatami:
        return 'ن';
    }
  }

  void _showBengaliAudioSourceDialog(BuildContext context, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SelectionSheet(
        title: 'Bengali Audio Source',
        options: BengaliAudioSource.values.map((source) => _SelectionOption(
          title: '${source.displayName} (${source.displayNameBengali})',
          subtitle: source.description,
          isSelected: appState.bengaliAudioSource == source,
          onTap: () {
            appState.setBengaliAudioSource(source);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all settings to their default values. Your bookmarks will be preserved. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement reset
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshQuranData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refresh Quran Data'),
        content: const Text(
          'This will clear the cached Quran data and download fresh data with Tajweed colors from the server.\n\nThis may take a moment depending on your internet connection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Clear the cache
        await QuranDataService().clearCache();

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quran data cache cleared. Fresh data with Tajweed will load when you open a surah.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing cache: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  String _getBengaliTranslationName(int id) {
    final options = QuranDataService.getBengaliTranslationOptions();
    final option = options.firstWhere(
      (o) => o['id'] == id,
      orElse: () => {'name': 'Unknown'},
    );
    return option['name'] as String;
  }

  void _showBengaliTranslationDialog(
      BuildContext context, AppStateProvider appState) {
    final options = QuranDataService.getBengaliTranslationOptions();
    showModalBottomSheet(
      context: context,
      builder: (context) => _SelectionSheet(
        title: 'Bengali Translation',
        options: options.map((option) {
          final id = option['id'] as int;
          return _SelectionOption(
            title: option['name'] as String,
            subtitle: option['nameEn'] as String,
            isSelected: appState.selectedBengaliTranslationId == id,
            onTap: () {
              appState.setSelectedBengaliTranslationId(id);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getEnglishTranslationName(int id) {
    final options = QuranDataService.getEnglishTranslationOptions();
    final option = options.firstWhere(
      (o) => o['id'] == id,
      orElse: () => {'name': 'Unknown'},
    );
    return option['name'] as String;
  }

  void _showEnglishTranslationDialog(
      BuildContext context, AppStateProvider appState) {
    final options = QuranDataService.getEnglishTranslationOptions();
    showModalBottomSheet(
      context: context,
      builder: (context) => _SelectionSheet(
        title: 'English Translation',
        options: options.map((option) {
          final id = option['id'] as int;
          return _SelectionOption(
            title: option['name'] as String,
            subtitle: option['description'] as String,
            isSelected: appState.selectedEnglishTranslationId == id,
            onTap: () {
              appState.setSelectedEnglishTranslationId(id);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isTablet;

  const _SettingsSection({
    required this.title,
    required this.children,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, top: isTablet ? 24 : 16, bottom: isTablet ? 12 : 8),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.label(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ).copyWith(fontSize: isTablet ? 14 : 12),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final bool isTablet;

  const _ProfileCard({
    required this.name,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final avatarSize = isTablet ? 64.0 : 56.0;
    final iconSize = isTablet ? 32.0 : 28.0;

    return ElegantCard(
      onTap: onTap,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Row(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.primary,
              size: iconSize,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.heading3(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ).copyWith(fontSize: isTablet ? 20 : 18),
                ),
                Text(
                  'Tap to edit',
                  style: AppTypography.bodySmall(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ).copyWith(fontSize: isTablet ? 14 : 12),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit_rounded,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
            size: isTablet ? 26 : 24,
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final AppThemeMode currentTheme;
  final Function(AppThemeMode) onThemeChanged;
  final bool isTablet;

  const _ThemeSelector({
    required this.currentTheme,
    required this.onThemeChanged,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElegantCard(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: AppTypography.heading3(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ).copyWith(fontSize: isTablet ? 20 : 18),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Row(
            children: [
              _ThemeOption(
                name: 'Light',
                colors: [AppColors.cream, AppColors.forestGreen],
                isSelected: currentTheme == AppThemeMode.light,
                onTap: () => onThemeChanged(AppThemeMode.light),
                isTablet: isTablet,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              _ThemeOption(
                name: 'Dark',
                colors: [AppColors.darkBackground, AppColors.softRose],
                isSelected: currentTheme == AppThemeMode.dark,
                onTap: () => onThemeChanged(AppThemeMode.dark),
                isTablet: isTablet,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              _ThemeOption(
                name: 'Rose Gold',
                colors: [AppColors.roseGoldBackground, AppColors.roseGoldPrimary],
                isSelected: currentTheme == AppThemeMode.roseGold,
                onTap: () => onThemeChanged(AppThemeMode.roseGold),
                isTablet: isTablet,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              _ThemeOption(
                name: 'Olive',
                colors: [AppColors.oliveCream, AppColors.oliveGreen],
                isSelected: currentTheme == AppThemeMode.oliveCream,
                onTap: () => onThemeChanged(AppThemeMode.oliveCream),
                isTablet: isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String name;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  const _ThemeOption({
    required this.name,
    required this.colors,
    required this.isSelected,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: isTablet ? 60 : 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.3),
                  width: isSelected ? 3 : 1,
                ),
              ),
            ),
            SizedBox(height: isTablet ? 10 : 8),
            Text(
              name,
              style: TextStyle(
                fontSize: isTablet ? 13 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isTablet;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElegantCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 18 : 14,
      ),
      margin: EdgeInsets.only(bottom: isTablet ? 10 : 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: isTablet ? 28 : 24,
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ).copyWith(fontSize: isTablet ? 18 : 16),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ).copyWith(fontSize: isTablet ? 14 : 12),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
            size: isTablet ? 28 : 24,
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;
  final bool isTablet;

  const _ToggleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElegantCard(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 14 : 10,
      ),
      margin: EdgeInsets.only(bottom: isTablet ? 10 : 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: isTablet ? 28 : 24,
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ).copyWith(fontSize: isTablet ? 18 : 16),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ).copyWith(fontSize: isTablet ? 14 : 12),
                  ),
              ],
            ),
          ),
          Transform.scale(
            scale: isTablet ? 1.15 : 1.0,
            child: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionSheet extends StatelessWidget {
  final String title;
  final List<_SelectionOption> options;

  const _SelectionSheet({
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // Constrain max height to prevent overflow
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                title,
                style: AppTypography.heading2(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            // Scrollable options list
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? leading;

  const _SelectionOption({
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: leading,
      title: Text(
        title,
        style: AppTypography.bodyLarge(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodySmall(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            )
          : null,
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
            )
          : null,
    );
  }
}

/// Tajweed legend tile showing all color codes
class _TajweedLegendTile extends StatelessWidget {
  final bool isTablet;

  const _TajweedLegendTile({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElegantCard(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      margin: EdgeInsets.only(bottom: isTablet ? 10 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.color_lens_rounded,
                color: theme.colorScheme.primary,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Text(
                'Tajweed Color Legend',
                style: AppTypography.bodyLarge(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ).copyWith(fontSize: isTablet ? 18 : 16),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Wrap(
            spacing: isTablet ? 20 : 16,
            runSpacing: isTablet ? 16 : 12,
            // Show only main tajweed rules (not sub-variants)
            children: const [
              TajweedRule.ghunnah,
              TajweedRule.ikhfa,
              TajweedRule.qalqalah,
              TajweedRule.idgham,
              TajweedRule.iqlab,
              TajweedRule.izhar,
              TajweedRule.safir,
              TajweedRule.madd,
            ].map((rule) => _TajweedColorItem(rule: rule, isTablet: isTablet))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TajweedColorItem extends StatelessWidget {
  final TajweedRule rule;
  final bool isTablet;

  const _TajweedColorItem({required this.rule, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isTablet ? 20 : 16,
          height: isTablet ? 20 : 16,
          decoration: BoxDecoration(
            color: rule.color,
            borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
          ),
        ),
        SizedBox(width: isTablet ? 8 : 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rule.englishName.split(' ').first,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              rule.arabicName,
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                fontFamily: 'Amiri',
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
