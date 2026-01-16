import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../models/surah.dart';

/// A mini audio player bar that appears at the bottom of the Quran reader
class AudioPlayerBar extends StatelessWidget {
  final AudioService audioService;
  final VoidCallback? onExpand;

  const AudioPlayerBar({
    super.key,
    required this.audioService,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: audioService,
      builder: (context, child) {
        // Don't show if nothing is playing and nothing is loaded
        if (audioService.currentSurah == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                _buildProgressBar(context, isDark),

                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      // Current ayah info
                      Expanded(
                        child: _buildAyahInfo(context, isDark),
                      ),

                      // Control buttons
                      _buildControls(context, isDark),

                      // Expand button
                      IconButton(
                        onPressed: onExpand,
                        icon: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, bool isDark) {
    final progress = audioService.duration.inMilliseconds > 0
        ? audioService.position.inMilliseconds /
            audioService.duration.inMilliseconds
        : 0.0;

    return LinearProgressIndicator(
      value: progress,
      minHeight: 3,
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.05),
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildAyahInfo(BuildContext context, bool isDark) {
    final surahName = SurahData.surahs
        .firstWhere(
          (s) => s.number == audioService.currentSurah,
          orElse: () => SurahData.surahs.first,
        )
        .nameTransliteration;

    return GestureDetector(
      onTap: onExpand,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              surahName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              'Ayah ${audioService.currentAyah}',
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
    );
  }

  Widget _buildControls(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous
        IconButton(
          onPressed: audioService.playPreviousAyah,
          icon: Icon(
            Icons.skip_previous_rounded,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),

        // Play/Pause
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: audioService.togglePlayPause,
            icon: audioService.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(
                    audioService.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
          ),
        ),

        // Next
        IconButton(
          onPressed: audioService.playNextAyahManual,
          icon: Icon(
            Icons.skip_next_rounded,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Expanded audio player with more controls
class ExpandedAudioPlayer extends StatelessWidget {
  final AudioService audioService;
  final VoidCallback? onClose;

  const ExpandedAudioPlayer({
    super.key,
    required this.audioService,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: audioService,
      builder: (context, child) {
        final surah = SurahData.surahs.firstWhere(
          (s) => s.number == audioService.currentSurah,
          orElse: () => SurahData.surahs.first,
        );

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Surah info
                  Text(
                    surah.nameArabic,
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'Amiri',
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.nameTransliteration} • Ayah ${audioService.currentAyah}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Progress slider
                  _buildProgressSlider(context, isDark),

                  const SizedBox(height: 8),

                  // Time indicators
                  _buildTimeIndicators(isDark),

                  const SizedBox(height: 24),

                  // Main controls
                  _buildMainControls(context, isDark),

                  const SizedBox(height: 24),

                  // Additional controls
                  _buildAdditionalControls(context, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSlider(BuildContext context, bool isDark) {
    final progress = audioService.duration.inMilliseconds > 0
        ? audioService.position.inMilliseconds /
            audioService.duration.inMilliseconds
        : 0.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: (value) {
          final position = Duration(
            milliseconds: (value * audioService.duration.inMilliseconds).toInt(),
          );
          audioService.seekTo(position);
        },
      ),
    );
  }

  Widget _buildTimeIndicators(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDuration(audioService.position),
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        Text(
          _formatDuration(audioService.duration),
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMainControls(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Repeat mode
        IconButton(
          onPressed: audioService.cycleRepeatMode,
          icon: Icon(
            _getRepeatIcon(audioService.repeatMode),
            color: audioService.repeatMode != AudioRepeatMode.none
                ? Theme.of(context).colorScheme.primary
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
          ),
        ),

        const SizedBox(width: 16),

        // Previous
        IconButton(
          onPressed: audioService.playPreviousAyah,
          iconSize: 36,
          icon: Icon(
            Icons.skip_previous_rounded,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 8),

        // Play/Pause
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: audioService.togglePlayPause,
            iconSize: 36,
            icon: audioService.isLoading
                ? const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(
                    audioService.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
          ),
        ),

        const SizedBox(width: 8),

        // Next
        IconButton(
          onPressed: audioService.playNextAyahManual,
          iconSize: 36,
          icon: Icon(
            Icons.skip_next_rounded,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 16),

        // Speed
        GestureDetector(
          onTap: () => _showSpeedSelector(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${audioService.playbackSpeed}x',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reciter selector
        TextButton.icon(
          onPressed: () => _showReciterSelector(context),
          icon: Icon(
            Icons.person_rounded,
            size: 18,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          label: Text(
            audioService.currentReciter.displayName.split(' ').last,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getRepeatIcon(AudioRepeatMode mode) {
    switch (mode) {
      case AudioRepeatMode.none:
        return Icons.repeat_rounded;
      case AudioRepeatMode.single:
        return Icons.repeat_one_rounded;
      case AudioRepeatMode.surah:
      case AudioRepeatMode.continuous:
        return Icons.repeat_rounded;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showSpeedSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Playback Speed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) => ListTile(
                  title: Text('${speed}x'),
                  trailing: audioService.playbackSpeed == speed
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    audioService.setPlaybackSpeed(speed);
                    Navigator.pop(context);
                  },
                ))),
          ],
        ),
      ),
    );
  }

  void _showReciterSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Reciter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...Reciter.values.map((reciter) => ListTile(
                  title: Text(reciter.displayName),
                  subtitle: Text(
                    reciter.displayNameArabic,
                    style: const TextStyle(fontFamily: 'Amiri'),
                  ),
                  trailing: audioService.currentReciter == reciter
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    audioService.setReciter(reciter);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
