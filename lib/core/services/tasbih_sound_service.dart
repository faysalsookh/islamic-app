import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

/// Service for playing tasbih counting sounds
class TasbihSoundService {
  static final TasbihSoundService _instance = TasbihSoundService._internal();
  factory TasbihSoundService() => _instance;
  TasbihSoundService._internal();

  AudioPlayer? _clickPlayer;
  AudioPlayer? _loopCompletePlayer;
  bool _isInitialized = false;

  /// Initialize audio players
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _clickPlayer = AudioPlayer();
      _loopCompletePlayer = AudioPlayer();

      // Set up click sound - using a bundled asset or generated tone
      await _clickPlayer?.setAsset('assets/sounds/tasbih_click.mp3').catchError((_) {
        // If asset not found, we'll use system sound
        return Duration.zero;
      });

      await _loopCompletePlayer?.setAsset('assets/sounds/tasbih_complete.mp3').catchError((_) {
        return Duration.zero;
      });

      _isInitialized = true;
    } catch (e) {
      // Silently fail - sound is optional
    }
  }

  /// Play click sound for each count
  Future<void> playClickSound() async {
    try {
      // Try to play audio asset, fallback to system haptic
      if (_clickPlayer != null) {
        await _clickPlayer!.seek(Duration.zero);
        await _clickPlayer!.play();
      } else {
        // Fallback to system click sound
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      // Fallback to system sound
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play completion sound when loop finishes
  Future<void> playLoopCompleteSound() async {
    try {
      if (_loopCompletePlayer != null) {
        await _loopCompletePlayer!.seek(Duration.zero);
        await _loopCompletePlayer!.play();
      } else {
        // Fallback to system alert
        await SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Dispose audio players
  void dispose() {
    _clickPlayer?.dispose();
    _loopCompletePlayer?.dispose();
    _clickPlayer = null;
    _loopCompletePlayer = null;
    _isInitialized = false;
  }
}
