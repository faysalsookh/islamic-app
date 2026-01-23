import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/haptic_service.dart';
import 'audio_settings_sheet.dart';

/// Premium bottom control bar for Quran reader with intuitive layout
class ReadingBottomBar extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNextAyah;
  final VoidCallback onPreviousAyah;
  final VoidCallback onBookmark;
  final VoidCallback onSettings;
  final bool isMushafView;
  final VoidCallback onToggleView;

  const ReadingBottomBar({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNextAyah,
    required this.onPreviousAyah,
    required this.onBookmark,
    required this.onSettings,
    required this.isMushafView,
    required this.onToggleView,
  });

  void _openAudioSettings(BuildContext context) {
    HapticService().lightImpact();
    AudioSettingsSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary)
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Playback status indicator
            ListenableBuilder(
              listenable: AudioService(),
              builder: (context, child) {
                final audioService = AudioService();
                if (audioService.isPlaying || audioService.isLoading) {
                  return _buildPlaybackStatus(audioService, theme, isDark);
                }
                return const SizedBox(height: 8);
              },
            ),

            // Main controls
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              child: Row(
                children: [
                  // Left side - View & Display controls
                  _buildControlGroup(
                    children: [
                      _buildControlButton(
                        icon: isMushafView
                            ? Icons.view_list_rounded
                            : Icons.auto_stories_rounded,
                        label: isMushafView ? 'List' : 'Mushaf',
                        onTap: onToggleView,
                        isDark: isDark,
                        theme: theme,
                      ),
                      _buildControlButton(
                        icon: Icons.text_fields_rounded,
                        label: 'Font',
                        onTap: onSettings,
                        isDark: isDark,
                        theme: theme,
                      ),
                    ],
                    isDark: isDark,
                  ),

                  const Spacer(),

                  // Center - Playback controls
                  _buildPlaybackControls(theme, isDark),

                  const Spacer(),

                  // Right side - Bookmark & Audio
                  _buildControlGroup(
                    children: [
                      _buildControlButton(
                        icon: Icons.bookmark_border_rounded,
                        label: 'Save',
                        onTap: onBookmark,
                        isDark: isDark,
                        theme: theme,
                      ),
                      _buildControlButton(
                        icon: Icons.headphones_rounded,
                        label: 'Audio',
                        onTap: () => _openAudioSettings(context),
                        isDark: isDark,
                        theme: theme,
                      ),
                    ],
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackStatus(
    AudioService audioService,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: audioService.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Icon(
                    audioService.isPlayingBengaliPart
                        ? Icons.translate_rounded
                        : Icons.graphic_eq_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
          ),
          const SizedBox(width: 12),
          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audioService.isLoading ? 'Loading...' : 'Now Playing',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  audioService.currentContentLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Mode badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              audioService.playbackContent.displayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlGroup({
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.5)
            : AppColors.cream.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService().selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous button
          _buildCircleButton(
            icon: Icons.skip_previous_rounded,
            onTap: onPreviousAyah,
            size: 40,
            iconSize: 22,
            color: theme.colorScheme.primary,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 4),
          // Play/Pause button
          _buildCircleButton(
            icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onTap: onPlayPause,
            size: 52,
            iconSize: 28,
            color: Colors.white,
            backgroundColor: theme.colorScheme.primary,
            hasShadow: true,
          ),
          const SizedBox(width: 4),
          // Next button
          _buildCircleButton(
            icon: Icons.skip_next_rounded,
            onTap: onNextAyah,
            size: 40,
            iconSize: 22,
            color: theme.colorScheme.primary,
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
    required double iconSize,
    required Color color,
    required Color backgroundColor,
    bool hasShadow = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService().selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: color,
          ),
        ),
      ),
    );
  }
}
