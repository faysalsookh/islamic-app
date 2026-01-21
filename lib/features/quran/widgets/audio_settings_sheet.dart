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
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.headphones_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Audio Settings',
                    style: AppTypography.heading3(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Playback Content Section
                    _buildSectionTitle('Playback Content', 'কি বাজবে', isDark),
                    const SizedBox(height: 12),
                    _buildPlaybackContentSelector(isDark, theme),

                    const SizedBox(height: 24),

                    // Arabic Reciter Section
                    _buildSectionTitle('Arabic Reciter', 'আরবি ক্বারী', isDark),
                    const SizedBox(height: 12),
                    _buildReciterSelector(isDark, theme),

                    const SizedBox(height: 24),

                    // Playback Speed Section
                    _buildSectionTitle('Playback Speed', 'গতি', isDark),
                    const SizedBox(height: 12),
                    _buildSpeedSelector(isDark, theme),

                    const SizedBox(height: 24),

                    // Repeat Mode Section
                    _buildSectionTitle('Repeat Mode', 'পুনরাবৃত্তি', isDark),
                    const SizedBox(height: 12),
                    _buildRepeatModeSelector(isDark, theme),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String bengaliTitle, bool isDark) {
    return Row(
      children: [
        Text(
          title,
          style: AppTypography.label(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '($bengaliTitle)',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'NotoSansBengali',
            color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackContentSelector(bool isDark, ThemeData theme) {
    return ListenableBuilder(
      listenable: _audioService,
      builder: (context, child) {
        final isTTSAvailable = _audioService.isBengaliTTSAvailable;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...AudioPlaybackContent.values.map((content) {
              final isSelected = _audioService.playbackContent == content;
              final isBengaliOption = content != AudioPlaybackContent.arabicOnly;
              final isDisabled = isBengaliOption && !isTTSAvailable;

              return _buildOptionTile(
                icon: content.icon,
                title: content.displayName,
                subtitle: content.displayNameBengali,
                isSelected: isSelected,
                isDark: isDark,
                theme: theme,
                isDisabled: isDisabled,
                disabledNote: isDisabled ? 'TTS unavailable' : (isBengaliOption ? 'TTS' : null),
                onTap: () {
                  if (isDisabled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('বাংলা TTS আপনার ডিভাইসে উপলব্ধ নয়। Bengali TTS is not available on your device.'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  HapticService().selectionClick();
                  _audioService.setPlaybackContent(content);
                },
              );
            }),
            const SizedBox(height: 8),
            // Note about Bengali TTS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.forestGreen.withValues(alpha: 0.1)
                    : AppColors.forestGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? AppColors.forestGreen.withValues(alpha: 0.3)
                      : AppColors.forestGreen.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isTTSAvailable ? Icons.record_voice_over_rounded : Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.forestGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTTSAvailable
                          ? 'বাংলা অনুবাদ Text-to-Speech (TTS) দিয়ে পড়া হবে।\nBengali translation uses device TTS.'
                          : 'বাংলা TTS সক্রিয় করতে আপনার ডিভাইসে Bengali ভাষা ইনস্টল করুন।\nInstall Bengali language on your device for TTS.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReciterSelector(bool isDark, ThemeData theme) {
    return ListenableBuilder(
      listenable: _audioService,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: Reciter.values.map((reciter) {
              final isSelected = _audioService.currentReciter == reciter;
              return InkWell(
                onTap: () {
                  HapticService().selectionClick();
                  _audioService.setReciter(reciter);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
                            width: 2,
                          ),
                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
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
                            Text(
                              reciter.displayNameArabic,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Amiri',
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
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSpeedSelector(bool isDark, ThemeData theme) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    return ListenableBuilder(
      listenable: _audioService,
      builder: (context, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: speeds.map((speed) {
            final isSelected = (_audioService.playbackSpeed - speed).abs() < 0.01;
            return GestureDetector(
              onTap: () {
                HapticService().selectionClick();
                _audioService.setPlaybackSpeed(speed);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.darkSurface : AppColors.cream),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.dividerDark : AppColors.divider),
                  ),
                ),
                child: Text(
                  '${speed}x',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRepeatModeSelector(bool isDark, ThemeData theme) {
    return ListenableBuilder(
      listenable: _audioService,
      builder: (context, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AudioRepeatMode.values.map((mode) {
            final isSelected = _audioService.repeatMode == mode;
            return GestureDetector(
              onTap: () {
                HapticService().selectionClick();
                _audioService.setRepeatMode(mode);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.darkSurface : AppColors.cream),
                  borderRadius: BorderRadius.circular(20),
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
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getRepeatLabel(mode),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
    bool isDisabled = false,
    String? disabledNote,
  }) {
    final effectiveDisabled = isDisabled && !isSelected;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: effectiveDisabled ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : (isDark ? AppColors.darkSurface : AppColors.cream),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDark ? AppColors.dividerDark : AppColors.divider),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        if (disabledNote != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: effectiveDisabled
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : AppColors.forestGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              disabledNote,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: effectiveDisabled ? Colors.orange : AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'NotoSansBengali',
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
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

  String _getRepeatLabel(AudioRepeatMode mode) {
    switch (mode) {
      case AudioRepeatMode.none:
        return 'Off';
      case AudioRepeatMode.single:
        return 'One';
      case AudioRepeatMode.surah:
        return 'Surah';
      case AudioRepeatMode.continuous:
        return 'All';
    }
  }
}
