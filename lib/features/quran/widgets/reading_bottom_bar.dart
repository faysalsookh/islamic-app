import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/haptic_service.dart';
import 'audio_settings_sheet.dart';

/// Bottom control bar for Quran reader
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
    final iconColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current playback content indicator
            ListenableBuilder(
              listenable: AudioService(),
              builder: (context, child) {
                final audioService = AudioService();
                if (audioService.isPlaying || audioService.isLoading) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (audioService.isLoading)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        else
                          Icon(
                            audioService.isPlayingBengaliPart
                                ? Icons.translate_rounded
                                : Icons.speaker_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          audioService.currentContentLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• ${audioService.playbackContent.displayName}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Main controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // View toggle
                IconButton(
                  onPressed: onToggleView,
                  icon: Icon(
                    isMushafView ? Icons.list_alt_rounded : Icons.auto_stories_rounded,
                    color: iconColor,
                  ),
                  tooltip: isMushafView ? 'List View' : 'Mushaf View',
                ),

                // Font Settings
                IconButton(
                  onPressed: onSettings,
                  icon: Icon(Icons.format_size_rounded, color: iconColor),
                  tooltip: 'Appearance',
                ),

                // Middle Player Controls
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onPreviousAyah,
                        icon: Icon(Icons.skip_previous_rounded, color: theme.colorScheme.primary),
                        tooltip: 'Previous Ayah',
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: onPlayPause,
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: isPlaying ? 'Pause' : 'Play',
                        ),
                      ),
                      IconButton(
                        onPressed: onNextAyah,
                        icon: Icon(Icons.skip_next_rounded, color: theme.colorScheme.primary),
                        tooltip: 'Next Ayah',
                      ),
                    ],
                  ),
                ),

                // Bookmark
                IconButton(
                  onPressed: onBookmark,
                  icon: Icon(Icons.bookmark_border_rounded, color: iconColor),
                  tooltip: 'Bookmark Page',
                ),

                // Audio Settings
                IconButton(
                  onPressed: () => _openAudioSettings(context),
                  icon: Icon(Icons.headphones_rounded, color: iconColor),
                  tooltip: 'Audio Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
