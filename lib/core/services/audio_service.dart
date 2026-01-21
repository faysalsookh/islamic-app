import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'cloud_tts_service.dart';
import 'quran_data_service.dart';

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

/// Enum for audio playback content options
enum AudioPlaybackContent {
  /// Play only Arabic recitation
  arabicOnly,

  /// Play only Bengali translation audio
  bengaliOnly,

  /// Play Arabic first, then Bengali translation
  arabicThenBengali,

  /// Play Bengali translation first, then Arabic
  bengaliThenArabic,
}

extension AudioPlaybackContentExtension on AudioPlaybackContent {
  String get displayName {
    switch (this) {
      case AudioPlaybackContent.arabicOnly:
        return 'Arabic Only';
      case AudioPlaybackContent.bengaliOnly:
        return 'Bengali Only';
      case AudioPlaybackContent.arabicThenBengali:
        return 'Arabic + Bengali';
      case AudioPlaybackContent.bengaliThenArabic:
        return 'Bengali + Arabic';
    }
  }

  String get displayNameBengali {
    switch (this) {
      case AudioPlaybackContent.arabicOnly:
        return 'শুধু আরবি';
      case AudioPlaybackContent.bengaliOnly:
        return 'শুধু বাংলা';
      case AudioPlaybackContent.arabicThenBengali:
        return 'আরবি + বাংলা';
      case AudioPlaybackContent.bengaliThenArabic:
        return 'বাংলা + আরবি';
    }
  }

  IconData get icon {
    switch (this) {
      case AudioPlaybackContent.arabicOnly:
        return Icons.speaker_rounded;
      case AudioPlaybackContent.bengaliOnly:
        return Icons.translate_rounded;
      case AudioPlaybackContent.arabicThenBengali:
        return Icons.playlist_play_rounded;
      case AudioPlaybackContent.bengaliThenArabic:
        return Icons.playlist_play_rounded;
    }
  }
}

/// Enum for Bengali translation reciters
/// Note: Bengali audio availability depends on the source and may not be available for all verses
enum BengaliTranslator {
  /// Verses.quran.com Bengali recitation (most reliable)
  quranComBengali,
}

extension BengaliTranslatorExtension on BengaliTranslator {
  String get displayName {
    switch (this) {
      case BengaliTranslator.quranComBengali:
        return 'Bengali Translation';
    }
  }

  String get displayNameBengali {
    switch (this) {
      case BengaliTranslator.quranComBengali:
        return 'বাংলা অনুবাদ';
    }
  }

  /// Get audio URL for specific ayah
  /// Returns null if audio is not available
  String? getAudioUrl(int surahNumber, int ayahNumber) {
    // Calculate absolute ayah number (for APIs that use it)
    // This is a workaround - Bengali verse-by-verse audio is limited
    switch (this) {
      case BengaliTranslator.quranComBengali:
        // Note: Bengali translation audio is not widely available as verse-by-verse
        // Returning null to indicate unavailability
        return null;
    }
  }
}

/// Enum for available reciters
/// Note: Only reciters with verse-by-verse audio on free CDNs are included
enum Reciter {
  misharyRashidAlafasy,
  abdulBasitAbdulSamad,
  abdulRahmanAlSudais,
  maherAlMuaiqly,
  abuBakrAlShatri,
  haniArRifai,
}

extension ReciterExtension on Reciter {
  String get displayName {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'Mishary Rashid Alafasy';
      case Reciter.abdulBasitAbdulSamad:
        return 'Abdul Basit Abdul Samad';
      case Reciter.abdulRahmanAlSudais:
        return 'Abdul Rahman Al-Sudais';
      case Reciter.maherAlMuaiqly:
        return 'Maher Al-Muaiqly';
      case Reciter.abuBakrAlShatri:
        return 'Abu Bakr Al-Shatri';
      case Reciter.haniArRifai:
        return 'Hani Ar-Rifai';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'مشاري راشد العفاسي';
      case Reciter.abdulBasitAbdulSamad:
        return 'عبد الباسط عبد الصمد';
      case Reciter.abdulRahmanAlSudais:
        return 'عبد الرحمن السديس';
      case Reciter.maherAlMuaiqly:
        return 'ماهر المعيقلي';
      case Reciter.abuBakrAlShatri:
        return 'أبو بكر الشاطري';
      case Reciter.haniArRifai:
        return 'هاني الرفاعي';
    }
  }

  /// Base URL for this reciter's audio files (ayah by ayah)
  /// Uses EveryAyah.com for verse-by-verse audio
  String get baseUrl {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'https://everyayah.com/data/Alafasy_128kbps';
      case Reciter.abdulBasitAbdulSamad:
        return 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps';
      case Reciter.abdulRahmanAlSudais:
        return 'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps';
      case Reciter.maherAlMuaiqly:
        return 'https://everyayah.com/data/MaherAlMuaiqly128kbps';
      case Reciter.abuBakrAlShatri:
        return 'https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps';
      case Reciter.haniArRifai:
        return 'https://everyayah.com/data/Hani_Rifai_192kbps';
    }
  }

  /// All reciters use EveryAyah URL format (SSSAAA.mp3)
  bool get usesEveryAyahFormat => true;
}

/// Service for managing Quran audio playback
class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _initializePlayer();
  }

  final AudioPlayer _player = AudioPlayer();
  final CloudTTSService _cloudTTSService = CloudTTSService();
  final QuranDataService _quranDataService = QuranDataService();

  // For playing multiple TTS audio chunks in sequence
  List<String> _bengaliAudioUrls = [];
  int _currentBengaliChunkIndex = 0;

  // Current playback state
  bool _isPlaying = false;
  bool _isLoading = false;
  int? _currentSurah;
  int? _currentAyah;
  Reciter _currentReciter = Reciter.misharyRashidAlafasy;
  BengaliTranslator _currentBengaliTranslator = BengaliTranslator.quranComBengali;
  String? _errorMessage;
  AudioRepeatMode _repeatMode = AudioRepeatMode.none;
  AudioPlaybackContent _playbackContent = AudioPlaybackContent.arabicOnly;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Track which part of the ayah is currently playing (for combined modes)
  bool _isPlayingBengaliPart = false;

  // Track current content label for UI
  String _currentContentLabel = 'Arabic';

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  int? get currentSurah => _currentSurah;
  int? get currentAyah => _currentAyah;
  Reciter get currentReciter => _currentReciter;
  BengaliTranslator get currentBengaliTranslator => _currentBengaliTranslator;
  AudioRepeatMode get repeatMode => _repeatMode;
  AudioPlaybackContent get playbackContent => _playbackContent;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioPlayer get player => _player;
  bool get isPlayingBengaliPart => _isPlayingBengaliPart;
  String get currentContentLabel => _currentContentLabel;
  String? get errorMessage => _errorMessage;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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
        // Check if we're playing Bengali chunks and have more to play
        if (_isPlayingBengaliPart || _playbackContent == AudioPlaybackContent.bengaliOnly) {
          if (_bengaliAudioUrls.isNotEmpty && _currentBengaliChunkIndex < _bengaliAudioUrls.length - 1) {
            // Play next Bengali chunk
            _currentBengaliChunkIndex++;
            _playBengaliChunk();
            return;
          } else if (_bengaliAudioUrls.isNotEmpty) {
            // All Bengali chunks done
            _bengaliAudioUrls = [];
            _currentBengaliChunkIndex = 0;
            _handleBengaliPlaybackComplete();
            return;
          }
        }
        _handlePlaybackComplete();
      }
    });
  }

  /// Play a specific ayah based on current playback content setting
  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    _currentSurah = surahNumber;
    _currentAyah = ayahNumber;
    _isPlayingBengaliPart = false;

    switch (_playbackContent) {
      case AudioPlaybackContent.arabicOnly:
        await _playArabicAyah(surahNumber, ayahNumber);
        break;
      case AudioPlaybackContent.bengaliOnly:
        await _playBengaliAyah(surahNumber, ayahNumber);
        break;
      case AudioPlaybackContent.arabicThenBengali:
        _isPlayingBengaliPart = false;
        await _playArabicAyah(surahNumber, ayahNumber);
        break;
      case AudioPlaybackContent.bengaliThenArabic:
        _isPlayingBengaliPart = true;
        await _playBengaliAyah(surahNumber, ayahNumber);
        break;
    }
  }

  /// Play Arabic recitation for a specific ayah
  Future<void> _playArabicAyah(int surahNumber, int ayahNumber) async {
    try {
      _isLoading = true;
      _currentContentLabel = 'Arabic';
      notifyListeners();

      // Build audio URL - EveryAyah format: SSSAAA.mp3 (3 digits surah, 3 digits ayah)
      final surahStr = surahNumber.toString().padLeft(3, '0');
      final ayahStr = ayahNumber.toString().padLeft(3, '0');
      final url = '${_currentReciter.baseUrl}/$surahStr$ayahStr.mp3';

      debugPrint('Playing Arabic - Reciter: ${_currentReciter.displayName}, URL: $url');

      await _player.setUrl(url);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      notifyListeners();
      debugPrint('Error playing Arabic audio: $e');
      rethrow;
    }
  }

  /// Play Bengali translation using Cloud TTS API
  /// No device TTS engine required - plays audio directly from API
  Future<void> _playBengaliAyah(int surahNumber, int ayahNumber) async {
    try {
      _isLoading = true;
      _currentContentLabel = 'বাংলা';
      _errorMessage = null;
      notifyListeners();

      // Get the ayah data with Bengali translation
      final ayahs = await _quranDataService.getAyahsForSurah(surahNumber);
      final ayah = ayahs.firstWhere(
        (a) => a.numberInSurah == ayahNumber,
        orElse: () => throw Exception('Ayah not found'),
      );

      final bengaliText = ayah.translationBengali;

      if (bengaliText == null || bengaliText.isEmpty) {
        _errorMessage = 'বাংলা অনুবাদ পাওয়া যায়নি। Bengali translation not found.';
        debugPrint('Bengali translation not found for $surahNumber:$ayahNumber');
        _isLoading = false;
        _handleBengaliAudioFailed();
        return;
      }

      // Generate cloud TTS audio URLs (may split long text into chunks)
      _bengaliAudioUrls = _cloudTTSService.generateAudioUrls(bengaliText);
      _currentBengaliChunkIndex = 0;

      debugPrint('Playing Bengali Cloud TTS for $surahNumber:$ayahNumber - ${_bengaliAudioUrls.length} chunks');

      // Play the first chunk
      await _playBengaliChunk();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'বাংলা অডিও চালাতে সমস্যা হয়েছে। Error: $e';
      debugPrint('Error playing Bengali Cloud TTS: $e');

      // If Bengali audio fails, try to continue with Arabic in combined mode
      if (_playbackContent == AudioPlaybackContent.arabicThenBengali ||
          _playbackContent == AudioPlaybackContent.bengaliThenArabic) {
        _handleBengaliAudioFailed();
      } else {
        _isPlaying = false;
        notifyListeners();
      }
    }
  }

  /// Play a chunk of Bengali TTS audio
  Future<void> _playBengaliChunk() async {
    if (_currentBengaliChunkIndex >= _bengaliAudioUrls.length) {
      // All chunks played, handle completion
      _handleBengaliPlaybackComplete();
      return;
    }

    try {
      final url = _bengaliAudioUrls[_currentBengaliChunkIndex];
      debugPrint('Playing Bengali chunk ${_currentBengaliChunkIndex + 1}/${_bengaliAudioUrls.length}');

      await _player.setUrl(url);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing Bengali chunk: $e');
      _isLoading = false;
      _handleBengaliAudioFailed();
    }
  }

  /// Handle completion of Bengali audio (all chunks played)
  void _handleBengaliPlaybackComplete() {
    debugPrint('Bengali playback complete');

    // Handle combined modes
    if (_playbackContent == AudioPlaybackContent.bengaliThenArabic && _isPlayingBengaliPart) {
      // Bengali finished, now play Arabic
      _isPlayingBengaliPart = false;
      if (_currentSurah != null && _currentAyah != null) {
        _playArabicAyah(_currentSurah!, _currentAyah!);
      }
    } else if (_playbackContent == AudioPlaybackContent.arabicThenBengali && _isPlayingBengaliPart) {
      // Both Arabic and Bengali finished, move to next ayah
      _isPlayingBengaliPart = false;
      _handlePlaybackComplete();
    } else if (_playbackContent == AudioPlaybackContent.bengaliOnly) {
      // Bengali only mode, move to next based on repeat mode
      _handlePlaybackComplete();
    }
  }

  /// Handle when Bengali audio fails in combined mode
  void _handleBengaliAudioFailed() {
    if (_playbackContent == AudioPlaybackContent.bengaliThenArabic && _isPlayingBengaliPart) {
      // Bengali failed, play Arabic instead
      _isPlayingBengaliPart = false;
      if (_currentSurah != null && _currentAyah != null) {
        _playArabicAyah(_currentSurah!, _currentAyah!);
      }
    } else {
      // Just move to next ayah
      _handlePlaybackComplete();
    }
  }

  /// Set playback content mode
  void setPlaybackContent(AudioPlaybackContent content) {
    _playbackContent = content;
    debugPrint('Playback content changed to: ${content.displayName}');
    notifyListeners();
  }

  /// Set Bengali translator
  void setBengaliTranslator(BengaliTranslator translator) {
    if (_currentBengaliTranslator == translator) return;
    _currentBengaliTranslator = translator;
    debugPrint('Bengali translator changed to: ${translator.displayName}');
    notifyListeners();
  }

  /// Play Arabic audio directly (for manual control)
  Future<void> playArabicOnly(int surahNumber, int ayahNumber) async {
    _currentSurah = surahNumber;
    _currentAyah = ayahNumber;
    _isPlayingBengaliPart = false;
    await _playArabicAyah(surahNumber, ayahNumber);
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
    _isPlayingBengaliPart = false;
    _bengaliAudioUrls = [];
    _currentBengaliChunkIndex = 0;
    notifyListeners();
  }

  /// Check if Bengali Cloud TTS is available (always true - uses API)
  bool get isBengaliTTSAvailable => true;

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

  /// Handle playback completion based on repeat mode and playback content
  void _handlePlaybackComplete() {
    // First, check if we need to play the second part of a combined mode
    if (_playbackContent == AudioPlaybackContent.arabicThenBengali && !_isPlayingBengaliPart) {
      // Arabic finished, now play Bengali
      _isPlayingBengaliPart = true;
      if (_currentSurah != null && _currentAyah != null) {
        _playBengaliAyah(_currentSurah!, _currentAyah!);
        return;
      }
    } else if (_playbackContent == AudioPlaybackContent.bengaliThenArabic && _isPlayingBengaliPart) {
      // Bengali finished, now play Arabic
      _isPlayingBengaliPart = false;
      if (_currentSurah != null && _currentAyah != null) {
        _playArabicAyah(_currentSurah!, _currentAyah!);
        return;
      }
    }

    // Reset for next ayah
    _isPlayingBengaliPart = false;

    // Now handle based on repeat mode
    switch (_repeatMode) {
      case AudioRepeatMode.none:
        // Stop playback
        _currentSurah = null;
        _currentAyah = null;
        _currentContentLabel = '';
        notifyListeners();
        break;

      case AudioRepeatMode.single:
        // Replay the same ayah (from the beginning based on content mode)
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
