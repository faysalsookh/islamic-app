import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Enum for different repeat modes
enum AudioRepeatMode {
  /// No repeat - stop after current ayah
  none,

  /// Repeat single ayah
  single,

  /// Repeat current surah
  surah,

  /// Continuous play through entire Quran
  continuous,
}

/// Enum for available reciters
enum Reciter {
  misharyRashidAlafasy,
  abdulBasitAbdulSamad,
  mahmoudKhalilAlHusary,
  saudAlShuraym,
  abdulRahmanAlSudais,
}

extension ReciterExtension on Reciter {
  String get displayName {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'Mishary Rashid Alafasy';
      case Reciter.abdulBasitAbdulSamad:
        return 'Abdul Basit Abdul Samad';
      case Reciter.mahmoudKhalilAlHusary:
        return 'Mahmoud Khalil Al-Husary';
      case Reciter.saudAlShuraym:
        return 'Saud Al-Shuraym';
      case Reciter.abdulRahmanAlSudais:
        return 'Abdul Rahman Al-Sudais';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'مشاري راشد العفاسي';
      case Reciter.abdulBasitAbdulSamad:
        return 'عبد الباسط عبد الصمد';
      case Reciter.mahmoudKhalilAlHusary:
        return 'محمود خليل الحصري';
      case Reciter.saudAlShuraym:
        return 'سعود الشريم';
      case Reciter.abdulRahmanAlSudais:
        return 'عبد الرحمن السديس';
    }
  }

  /// Base URL for this reciter's audio files
  String get baseUrl {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'https://cdn.islamic.network/quran/audio/128/ar.alafasy';
      case Reciter.abdulBasitAbdulSamad:
        return 'https://cdn.islamic.network/quran/audio/64/ar.abdulbasitmurattal';
      case Reciter.mahmoudKhalilAlHusary:
        return 'https://cdn.islamic.network/quran/audio/128/ar.husary';
      case Reciter.saudAlShuraym:
        return 'https://cdn.islamic.network/quran/audio/64/ar.saoodshuraym';
      case Reciter.abdulRahmanAlSudais:
        return 'https://cdn.islamic.network/quran/audio/192/ar.abdurrahmaansudais';
    }
  }
}

/// Service for managing Quran audio playback
class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _initializePlayer();
  }

  final AudioPlayer _player = AudioPlayer();

  // Current playback state
  bool _isPlaying = false;
  bool _isLoading = false;
  int? _currentSurah;
  int? _currentAyah;
  Reciter _currentReciter = Reciter.misharyRashidAlafasy;
  AudioRepeatMode _repeatMode = AudioRepeatMode.none;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  int? get currentSurah => _currentSurah;
  int? get currentAyah => _currentAyah;
  Reciter get currentReciter => _currentReciter;
  AudioRepeatMode get repeatMode => _repeatMode;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioPlayer get player => _player;

  /// Check if a specific ayah is currently playing
  bool isAyahPlaying(int surahNumber, int ayahNumber) {
    return _isPlaying &&
        _currentSurah == surahNumber &&
        _currentAyah == ayahNumber;
  }

  void _initializePlayer() {
    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    // Listen to position changes
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // Listen to duration changes
    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    // Listen for playback completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handlePlaybackComplete();
      }
    });
  }

  /// Play a specific ayah
  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    try {
      _isLoading = true;
      _currentSurah = surahNumber;
      _currentAyah = ayahNumber;
      notifyListeners();

      // Build audio URL
      // Format: baseUrl/ayahNumber.mp3 (global ayah number)
      final globalAyahNumber = _getGlobalAyahNumber(surahNumber, ayahNumber);
      final url = '${_currentReciter.baseUrl}/$globalAyahNumber.mp3';

      debugPrint('Playing audio - Reciter: ${_currentReciter.displayName}, URL: $url');

      await _player.setUrl(url);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      notifyListeners();
      debugPrint('Error playing audio: $e');
      rethrow;
    }
  }

  /// Play from a specific ayah and continue
  Future<void> playFromAyah(int surahNumber, int ayahNumber) async {
    // Set repeat mode to continuous for this operation
    _repeatMode = AudioRepeatMode.continuous;
    await playAyah(surahNumber, ayahNumber);
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.play();
    notifyListeners();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
    _currentSurah = null;
    _currentAyah = null;
    _isPlaying = false;
    notifyListeners();
  }

  /// Seek to a position
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed.clamp(0.5, 2.0);
    await _player.setSpeed(_playbackSpeed);
    notifyListeners();
  }

  /// Set repeat mode
  void setRepeatMode(AudioRepeatMode mode) {
    _repeatMode = mode;
    notifyListeners();
  }

  /// Cycle through repeat modes
  void cycleRepeatMode() {
    final modes = AudioRepeatMode.values;
    final currentIndex = modes.indexOf(_repeatMode);
    _repeatMode = modes[(currentIndex + 1) % modes.length];
    notifyListeners();
  }

  /// Set reciter
  void setReciter(Reciter reciter) {
    if (_currentReciter == reciter) return;

    _currentReciter = reciter;
    debugPrint('Reciter changed to: ${reciter.displayName}');

    // If currently playing, reload with new reciter
    if (_currentSurah != null && _currentAyah != null) {
      final wasPlaying = _isPlaying;
      playAyah(_currentSurah!, _currentAyah!).then((_) {
        if (!wasPlaying) {
          pause();
        }
      });
    }

    notifyListeners();
  }

  /// Handle playback completion based on repeat mode
  void _handlePlaybackComplete() {
    switch (_repeatMode) {
      case AudioRepeatMode.none:
        // Stop playback
        _currentSurah = null;
        _currentAyah = null;
        notifyListeners();
        break;

      case AudioRepeatMode.single:
        // Replay the same ayah
        if (_currentSurah != null && _currentAyah != null) {
          playAyah(_currentSurah!, _currentAyah!);
        }
        break;

      case AudioRepeatMode.surah:
      case AudioRepeatMode.continuous:
        // Play next ayah
        _playNextAyah();
        break;
    }
  }

  /// Play the next ayah
  void _playNextAyah() {
    if (_currentSurah == null || _currentAyah == null) return;

    // Get the ayah count for current surah
    final ayahCount = _getAyahCount(_currentSurah!);

    if (_currentAyah! < ayahCount) {
      // Play next ayah in same surah
      playAyah(_currentSurah!, _currentAyah! + 1);
    } else if (_repeatMode == AudioRepeatMode.surah) {
      // Restart surah
      playAyah(_currentSurah!, 1);
    } else if (_repeatMode == AudioRepeatMode.continuous) {
      // Move to next surah
      if (_currentSurah! < 114) {
        playAyah(_currentSurah! + 1, 1);
      } else {
        // End of Quran
        stop();
      }
    }
  }

  /// Play previous ayah
  void playPreviousAyah() {
    if (_currentSurah == null || _currentAyah == null) return;

    if (_currentAyah! > 1) {
      playAyah(_currentSurah!, _currentAyah! - 1);
    } else if (_currentSurah! > 1) {
      // Go to last ayah of previous surah
      final prevSurahAyahCount = _getAyahCount(_currentSurah! - 1);
      playAyah(_currentSurah! - 1, prevSurahAyahCount);
    }
  }

  /// Play next ayah (public method)
  void playNextAyahManual() {
    if (_currentSurah == null || _currentAyah == null) return;

    final ayahCount = _getAyahCount(_currentSurah!);
    if (_currentAyah! < ayahCount) {
      playAyah(_currentSurah!, _currentAyah! + 1);
    } else if (_currentSurah! < 114) {
      playAyah(_currentSurah! + 1, 1);
    }
  }

  /// Get global ayah number for API calls
  int _getGlobalAyahNumber(int surahNumber, int ayahNumber) {
    // This is a simplified calculation
    // In production, you'd use a lookup table
    int globalNumber = 0;
    for (int i = 1; i < surahNumber; i++) {
      globalNumber += _getAyahCount(i);
    }
    return globalNumber + ayahNumber;
  }

  /// Get the number of ayahs in a surah
  int _getAyahCount(int surahNumber) {
    // Ayah counts for each surah (1-114)
    const ayahCounts = [
      7, 286, 200, 176, 120, 165, 206, 75, 129, 109, // 1-10
      123, 111, 43, 52, 99, 128, 111, 110, 98, 135, // 11-20
      112, 78, 118, 64, 77, 227, 93, 88, 69, 60, // 21-30
      34, 30, 73, 54, 45, 83, 182, 88, 75, 85, // 31-40
      54, 53, 89, 59, 37, 35, 38, 29, 18, 45, // 41-50
      60, 49, 62, 55, 78, 96, 29, 22, 24, 13, // 51-60
      14, 11, 11, 18, 12, 12, 30, 52, 52, 44, // 61-70
      28, 28, 20, 56, 40, 31, 50, 40, 46, 42, // 71-80
      29, 19, 36, 25, 22, 17, 19, 26, 30, 20, // 81-90
      15, 21, 11, 8, 8, 19, 5, 8, 8, 11, // 91-100
      11, 8, 3, 9, 5, 4, 7, 3, 6, 3, // 101-110
      5, 4, 5, 6, // 111-114
    ];

    if (surahNumber < 1 || surahNumber > 114) return 0;
    return ayahCounts[surahNumber - 1];
  }

  /// Dispose of resources
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
