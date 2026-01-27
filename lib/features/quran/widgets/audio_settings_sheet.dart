import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';

/// Bottom sheet for audio playback settings
class AudioSettingsSheet extends StatefulWidget {
  const AudioSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AudioSettingsSheet(),
    );
  }

  @override
  State<AudioSettingsSheet> createState() => _AudioSettingsSheetState();
}

class _AudioSettingsSheetState extends State<AudioSettingsSheet> {
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary)
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            _buildHeader(isDark, theme),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Audio Language Section
                    _buildAudioLanguageSection(isDark, theme),

                    const SizedBox(height: 20),

                    // Reciter Section
                    _buildReciterSection(isDark, theme),

                    const SizedBox(height: 20),

                    // Speed & Repeat Row
                    _buildSpeedAndRepeatSection(isDark, theme),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.graphic_eq_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio Settings',
                  style: AppTypography.heading3(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customize your listening experience',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.cream,
            ),
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'NotoSansBengali',
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          child,
        ],
      ),
    );
  }

  Widget _buildAudioLanguageSection(bool isDark, ThemeData theme) {
    return _buildSectionCard(
      title: 'Audio Language',
      subtitle: '(ভাষা)',
      icon: Icons.language_rounded,
      isDark: isDark,
      theme: theme,
      child: ListenableBuilder(
        listenable: _audioService,
        builder: (context, child) {
          return Column(
            children: [
              ...AudioPlaybackContent.values.map((content) {
                final isSelected = _audioService.playbackContent == content;
                final isBengaliOnly = content == AudioPlaybackContent.bengaliOnly;
                final isEnglishOnly = content == AudioPlaybackContent.englishOnly;
                final isRecommended = content == AudioPlaybackContent.arabicOnly ||
                    content == AudioPlaybackContent.arabicThenBengali ||
                    content == AudioPlaybackContent.arabicThenEnglish;

                return _buildLanguageOption(
                  content: content,
                  isSelected: isSelected,
                  isBengaliOnly: isBengaliOnly,
                  isEnglishOnly: isEnglishOnly,
                  isRecommended: isRecommended,
                  isDark: isDark,
                  theme: theme,
                );
              }),
              // Bengali Only Warning
              if (_audioService.playbackContent == AudioPlaybackContent.bengaliOnly)
                _buildWarningNote(isDark),
              // Bengali Source Info (show when Bengali is included)
              if (_audioService.playbackContent == AudioPlaybackContent.bengaliOnly ||
                  _audioService.playbackContent == AudioPlaybackContent.arabicThenBengali)
                _buildBengaliSourceInfo(isDark),
              // English Source Info (show when English is included)
              if (_audioService.playbackContent == AudioPlaybackContent.englishOnly ||
                  _audioService.playbackContent == AudioPlaybackContent.arabicThenEnglish)
                _buildEnglishSourceInfo(isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption({
    required AudioPlaybackContent content,
    required bool isSelected,
    required bool isBengaliOnly,
    required bool isEnglishOnly,
    required bool isRecommended,
    required bool isDark,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {
        HapticService().selectionClick();
        _audioService.setPlaybackContent(content);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkCard : Colors.white),
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
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
                  width: isSelected ? 0 : 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkSurface : AppColors.cream),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                content.icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        content.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isRecommended)
                        _buildBadge(
                          text: 'Recommended',
                          color: AppColors.forestGreen,
                          isDark: isDark,
                        ),
                      if (isBengaliOnly)
                        _buildBadge(
                          text: 'TTS Audio',
                          color: Colors.orange,
                          isDark: isDark,
                        ),
                      if (isEnglishOnly)
                        _buildBadge(
                          text: 'Ibrahim Walk',
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content.displayNameBengali,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'NotoSansBengali',
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildWarningNote(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note about Bengali Only',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bengali audio uses TTS (Text-to-Speech) which may have pronunciation variations. For the authentic Quranic experience with proper Tajweed, we recommend including Arabic recitation.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBengaliSourceInfo(bool isDark) {
    // For Arabic+Bengali mode, always use TTS for verse-by-verse tracking
    final isArabicPlusBengali =
        _audioService.playbackContent == AudioPlaybackContent.arabicThenBengali;
    final displayText = isArabicPlusBengali
        ? 'Bengali: TTS (verse-by-verse for ayah tracking)'
        : (_audioService.bengaliAudioSource == BengaliAudioSource.humanVoice
            ? 'Bengali: Human voice narration (full surah)'
            : 'Bengali: AI-generated voice');
    final displayIcon = isArabicPlusBengali
        ? Icons.format_list_numbered_rounded
        : (_audioService.bengaliAudioSource == BengaliAudioSource.humanVoice
            ? Icons.record_voice_over_rounded
            : Icons.smart_toy_rounded);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.forestGreen.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            displayIcon,
            size: 16,
            color: AppColors.forestGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.forestGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnglishSourceInfo(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            _audioService.englishAudioSource == EnglishAudioSource.ibrahimWalk
                ? Icons.record_voice_over_rounded
                : Icons.smart_toy_rounded,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _audioService.englishAudioSource == EnglishAudioSource.ibrahimWalk
                  ? 'English: Ibrahim Walk (Sahih International)'
                  : 'English: AI-generated voice',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReciterSection(bool isDark, ThemeData theme) {
    return _buildSectionCard(
      title: 'Reciter',
      subtitle: '(ক্বারী)',
      icon: Icons.person_rounded,
      isDark: isDark,
      theme: theme,
      child: ListenableBuilder(
        listenable: _audioService,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: Reciter.values.map((reciter) {
                final isSelected = _audioService.currentReciter == reciter;
                return _buildReciterOption(
                  reciter: reciter,
                  isSelected: isSelected,
                  isDark: isDark,
                  theme: theme,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReciterOption({
    required Reciter reciter,
    required bool isSelected,
    required bool isDark,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {
        HapticService().selectionClick();
        _audioService.setReciter(reciter);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkCard : Colors.white),
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
            // Reciter photo/avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: reciter.photoUrl != null
                  ? Image.asset(
                      reciter.photoUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to initial if photo not found
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
                      fontSize: 14,
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
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
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

  Widget _buildReciterInitialAvatar(Reciter reciter, bool isSelected, bool isDark, ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          _getReciterInitials(reciter),
          style: TextStyle(
            fontSize: 20,
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


  Widget _buildSpeedAndRepeatSection(bool isDark, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Speed Section
        Expanded(
          child: _buildCompactSectionCard(
            title: 'Speed',
            subtitle: 'গতি',
            icon: Icons.speed_rounded,
            isDark: isDark,
            theme: theme,
            child: _buildSpeedSelector(isDark, theme),
          ),
        ),
        const SizedBox(width: 12),
        // Repeat Section
        Expanded(
          child: _buildCompactSectionCard(
            title: 'Repeat',
            subtitle: 'পুনরাবৃত্তি',
            icon: Icons.repeat_rounded,
            isDark: isDark,
            theme: theme,
            child: _buildRepeatSelector(isDark, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($subtitle)',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'NotoSansBengali',
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildSpeedSelector(bool isDark, ThemeData theme) {
    final speeds = [0.75, 1.0, 1.25, 1.5];

    return ListenableBuilder(
      listenable: _audioService,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: speeds.map((speed) {
              final isSelected = (_audioService.playbackSpeed - speed).abs() < 0.01;
              final isNormal = speed == 1.0;
              return GestureDetector(
                onTap: () {
                  HapticService().selectionClick();
                  _audioService.setPlaybackSpeed(speed);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? AppColors.dividerDark : AppColors.divider),
                    ),
                  ),
                  child: Text(
                    isNormal ? '1x' : '${speed}x',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRepeatSelector(bool isDark, ThemeData theme) {
    return ListenableBuilder(
      listenable: _audioService,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: AudioRepeatMode.values.map((mode) {
              final isSelected = _audioService.repeatMode == mode;
              return GestureDetector(
                onTap: () {
                  HapticService().selectionClick();
                  _audioService.setRepeatMode(mode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? AppColors.dividerDark : AppColors.divider),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRepeatIcon(mode),
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  IconData _getRepeatIcon(AudioRepeatMode mode) {
    switch (mode) {
      case AudioRepeatMode.none:
        return Icons.arrow_forward_rounded;
      case AudioRepeatMode.single:
        return Icons.repeat_one_rounded;
      case AudioRepeatMode.surah:
        return Icons.repeat_rounded;
      case AudioRepeatMode.continuous:
        return Icons.all_inclusive_rounded;
    }
  }
}
