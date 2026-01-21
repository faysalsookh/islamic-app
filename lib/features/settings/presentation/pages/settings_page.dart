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
                    title: 'Reciter',
                    subtitle: appState.selectedReciter.displayName,
                    onTap: () => _showReciterDialog(context, appState),
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
      builder: (context) => _SelectionSheet(
        title: 'Select Reciter',
        options: Reciter.values.map((reciter) => _SelectionOption(
          title: reciter.displayName,
          subtitle: reciter.displayNameArabic,
          isSelected: appState.selectedReciter == reciter,
          onTap: () {
            appState.setSelectedReciter(reciter);
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

  const _SelectionOption({
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
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
            children: TajweedRule.values
                .where((rule) => rule != TajweedRule.normal)
                .map((rule) => _TajweedColorItem(rule: rule, isTablet: isTablet))
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
