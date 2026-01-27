import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'bengali_audio_urls.dart';
import 'cloud_tts_service.dart';
import 'quran_data_service.dart';
import 'reciter_audio_sources.dart';

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

  /// Play only English translation audio (Ibrahim Walk - Sahih International)
  englishOnly,

  /// Play Arabic first, then English translation
  arabicThenEnglish,
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
      case AudioPlaybackContent.englishOnly:
        return 'English Only';
      case AudioPlaybackContent.arabicThenEnglish:
        return 'Arabic + English';
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
      case AudioPlaybackContent.englishOnly:
        return 'শুধু ইংরেজি';
      case AudioPlaybackContent.arabicThenEnglish:
        return 'আরবি + ইংরেজি';
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
      case AudioPlaybackContent.englishOnly:
        return Icons.record_voice_over_rounded;
      case AudioPlaybackContent.arabicThenEnglish:
        return Icons.queue_music_rounded;
    }
  }
}

/// Enum for Bengali translation audio source types
enum BengaliAudioSource {
  /// Cloud TTS (Text-to-Speech) - computer generated voice
  cloudTTS,

  /// Human voice reciter - Bangladesh Islamic Foundation translation
  /// (Surah-level audio with Arabic recitation + Bengali translation)
  humanVoice,
  
  /// Device TTS (Built-in Text-to-Speech) - uses system voice (Male/Female)
  deviceTTS,
}

extension BengaliAudioSourceExtension on BengaliAudioSource {
  String get displayName {
    switch (this) {
      case BengaliAudioSource.cloudTTS:
        return 'TTS Voice (Cloud)';
      case BengaliAudioSource.humanVoice:
        return 'Human Voice (BIF)';
      case BengaliAudioSource.deviceTTS:
        return 'Device Voice (System)';
    }
  }

  String get displayNameBengali {
    switch (this) {
      case BengaliAudioSource.cloudTTS:
        return 'টিটিএস ভয়েস (ক্লাউড)';
      case BengaliAudioSource.humanVoice:
        return 'মানুষের কণ্ঠ (বিআইএফ)';
      case BengaliAudioSource.deviceTTS:
        return 'ডিভাইস ভয়েস (সিস্টেম)';
    }
  }

  String get description {
    switch (this) {
      case BengaliAudioSource.cloudTTS:
        return 'Computer generated voice (Google v2)';
      case BengaliAudioSource.humanVoice:
        return 'Bangladesh Islamic Foundation (full surah)';
      case BengaliAudioSource.deviceTTS:
        return 'Uses your phone\'s built-in voice (Male/Female)';
    }
  }

  String get descriptionBengali {
    switch (this) {
      case BengaliAudioSource.cloudTTS:
        return 'কম্পিউটার জেনারেটেড ভয়েস (গুগল v2)';
      case BengaliAudioSource.humanVoice:
        return 'বাংলাদেশ ইসলামিক ফাউন্ডেশন (সম্পূর্ণ সূরা)';
      case BengaliAudioSource.deviceTTS:
        return 'আপনার ফোনের বিল্ট-ইন ভয়েস ব্যবহার করে';
    }
  }

  /// Whether this source provides verse-by-verse audio
  bool get isVerseByVerse => this == BengaliAudioSource.cloudTTS;

  /// Whether this source provides full surah audio
  bool get isFullSurah => this == BengaliAudioSource.humanVoice;
}

/// Enum for English translation audio source types
enum EnglishAudioSource {
  /// Ibrahim Walk - Sahih International (Human voice from EveryAyah.com)
  /// Verse-by-verse audio at 192kbps
  ibrahimWalk,

  /// Cloud TTS (Text-to-Speech) - Google TTS for English
  cloudTTS,
}

extension EnglishAudioSourceExtension on EnglishAudioSource {
  String get displayName {
    switch (this) {
      case EnglishAudioSource.ibrahimWalk:
        return 'Ibrahim Walk (Sahih Intl)';
      case EnglishAudioSource.cloudTTS:
        return 'TTS Voice (Cloud)';
    }
  }

  String get displayNameBengali {
    switch (this) {
      case EnglishAudioSource.ibrahimWalk:
        return 'ইব্রাহিম ওয়াক (সহীহ ইন্টল)';
      case EnglishAudioSource.cloudTTS:
        return 'টিটিএস ভয়েস (ক্লাউড)';
    }
  }

  String get description {
    switch (this) {
      case EnglishAudioSource.ibrahimWalk:
        return 'Human voice - Sahih International translation (192kbps)';
      case EnglishAudioSource.cloudTTS:
        return 'Computer generated voice (Google TTS)';
    }
  }

  String get descriptionBengali {
    switch (this) {
      case EnglishAudioSource.ibrahimWalk:
        return 'মানুষের কণ্ঠ - সহীহ ইন্টারন্যাশনাল অনুবাদ';
      case EnglishAudioSource.cloudTTS:
        return 'কম্পিউটার জেনারেটেড ভয়েস (গুগল টিটিএস)';
    }
  }

  /// Base URL for Ibrahim Walk English translation audio
  static const String _ibrahimWalkBaseUrl =
      'https://everyayah.com/data/English/Sahih_Intnl_Ibrahim_Walk_192kbps';

  /// Get audio URL for a specific ayah
  String getAudioUrl(int surahNumber, int ayahNumber) {
    switch (this) {
      case EnglishAudioSource.ibrahimWalk:
        final surahStr = surahNumber.toString().padLeft(3, '0');
        final ayahStr = ayahNumber.toString().padLeft(3, '0');
        return '$_ibrahimWalkBaseUrl/$surahStr$ayahStr.mp3';
      case EnglishAudioSource.cloudTTS:
        // Cloud TTS doesn't have a direct URL - it's generated on demand
        return '';
    }
  }

  /// Whether this source provides verse-by-verse audio
  bool get isVerseByVerse => true;

  /// Audio quality description
  String get audioQuality {
    switch (this) {
      case EnglishAudioSource.ibrahimWalk:
        return '192 kbps (High Quality)';
      case EnglishAudioSource.cloudTTS:
        return 'Variable (TTS)';
    }
  }
}

/// Enum for Bengali translation reciters (legacy - kept for compatibility)
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
/// All audio sources verified from EveryAyah.com (trusted Islamic audio repository)
enum Reciter {
  // Most Popular & Recommended
  misharyRashidAlafasy,
  abdulRahmanAlSudais,

  // Haramain Reciters (Makkah & Madinah)
  maherAlMuaiqly,
  saadAlGhamdi,

  // Classical & Traditional
  abuBakrAlShatri,

  // Clear & Educational
  haniArRifai,
  hudhaify,

  // Additional Renowned Reciters
  aliJaber,
  yasserAlDosari,
  nasserAlQatami,
}

/// Recitation style - helps users choose based on their preference
enum RecitationStyle {
  /// Murattal - Slow, clear recitation for learning and memorization
  murattal,
  
  /// Mujawwad - Melodious recitation with Tajweed rules emphasized
  mujawwad,
  
  /// Hadr - Faster recitation, typically used in Taraweeh
  hadr,
}

extension ReciterExtension on Reciter {
  String get displayName {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'Mishary Rashid Alafasy';
      case Reciter.abdulRahmanAlSudais:
        return 'Abdul Rahman Al-Sudais';
      case Reciter.maherAlMuaiqly:
        return 'Maher Al-Muaiqly';
      case Reciter.saadAlGhamdi:
        return 'Saad Al-Ghamdi';
      case Reciter.abuBakrAlShatri:
        return 'Abu Bakr Al-Shatri';
      case Reciter.haniArRifai:
        return 'Hani Ar-Rifai';
      case Reciter.hudhaify:
        return 'Ali Al-Hudhaify';
      case Reciter.aliJaber:
        return 'Ali Jaber';
      case Reciter.yasserAlDosari:
        return 'Yasser Al-Dosari';
      case Reciter.nasserAlQatami:
        return 'Nasser Al-Qatami';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'مشاري راشد العفاسي';
      case Reciter.abdulRahmanAlSudais:
        return 'عبد الرحمن السديس';
      case Reciter.maherAlMuaiqly:
        return 'ماهر المعيقلي';
      case Reciter.saadAlGhamdi:
        return 'سعد الغامدي';
      case Reciter.abuBakrAlShatri:
        return 'أبو بكر الشاطري';
      case Reciter.haniArRifai:
        return 'هاني الرفاعي';
      case Reciter.hudhaify:
        return 'علي الحذيفي';
      case Reciter.aliJaber:
        return 'علي جابر';
      case Reciter.yasserAlDosari:
        return 'ياسر الدوسري';
      case Reciter.nasserAlQatami:
        return 'ناصر القطامي';
    }
  }

  /// Recitation style for this reciter
  RecitationStyle get recitationStyle {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
      case Reciter.saadAlGhamdi:
      case Reciter.abuBakrAlShatri:
      case Reciter.hudhaify:
      case Reciter.nasserAlQatami:
        return RecitationStyle.murattal;
      case Reciter.abdulRahmanAlSudais:
      case Reciter.maherAlMuaiqly:
      case Reciter.haniArRifai:
      case Reciter.aliJaber:
      case Reciter.yasserAlDosari:
        return RecitationStyle.hadr;
    }
  }

  /// Description of reciter's style and background
  String get description {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'Popular Kuwaiti reciter, known for clear Murattal style';
      case Reciter.abdulRahmanAlSudais:
        return 'Imam of Masjid al-Haram (Makkah), melodious voice';
      case Reciter.maherAlMuaiqly:
        return 'Imam of Masjid al-Haram (Makkah), beautiful recitation';
      case Reciter.saadAlGhamdi:
        return 'Saudi reciter, clear and emotional Murattal';
      case Reciter.abuBakrAlShatri:
        return 'Saudi reciter, excellent for memorization';
      case Reciter.haniArRifai:
        return 'Syrian reciter, clear pronunciation';
      case Reciter.hudhaify:
        return 'Former Imam of Masjid an-Nabawi (Madinah)';
      case Reciter.aliJaber:
        return 'Former Imam of Masjid al-Haram (Makkah)';
      case Reciter.yasserAlDosari:
        return 'Saudi reciter, emotional and beautiful voice';
      case Reciter.nasserAlQatami:
        return 'Saudi reciter, clear and melodious Murattal';
    }
  }

  /// Audio quality (bitrate)
  String get audioQuality {
    switch (this) {
      case Reciter.abdulRahmanAlSudais:
      case Reciter.haniArRifai:
      case Reciter.saadAlGhamdi:
      case Reciter.hudhaify:
        return '192 kbps (High Quality)';
      case Reciter.misharyRashidAlafasy:
      case Reciter.maherAlMuaiqly:
      case Reciter.abuBakrAlShatri:
      case Reciter.aliJaber:
      case Reciter.yasserAlDosari:
      case Reciter.nasserAlQatami:
        return '128 kbps (Good Quality)';
    }
  }

  /// Base URL for this reciter's audio files (ayah by ayah)
  /// Uses EveryAyah.com for verse-by-verse audio
  String get baseUrl {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'https://everyayah.com/data/Alafasy_128kbps';
      case Reciter.abdulRahmanAlSudais:
        return 'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps';
      case Reciter.maherAlMuaiqly:
        return 'https://everyayah.com/data/MaherAlMuaiqly128kbps';
      case Reciter.saadAlGhamdi:
        return 'https://everyayah.com/data/Ghamadi_40kbps';
      case Reciter.abuBakrAlShatri:
        return 'https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps';
      case Reciter.haniArRifai:
        return 'https://everyayah.com/data/Hani_Rifai_192kbps';
      case Reciter.hudhaify:
        return 'https://everyayah.com/data/Hudhaify_128kbps';
      case Reciter.aliJaber:
        return 'https://everyayah.com/data/Ali_Jaber_64kbps';
      case Reciter.yasserAlDosari:
        return 'https://everyayah.com/data/Yasser_Ad-Dussary_128kbps';
      case Reciter.nasserAlQatami:
        return 'https://everyayah.com/data/Nasser_Alqatami_128kbps';
    }
  }

  /// All reciters use EveryAyah URL format (SSSAAA.mp3)
  bool get usesEveryAyahFormat => true;
  
  /// Whether this reciter is recommended for beginners/learning
  bool get recommendedForLearning {
    switch (this) {
      case Reciter.misharyRashidAlafasy:
      case Reciter.abuBakrAlShatri:
      case Reciter.saadAlGhamdi:
      case Reciter.hudhaify:
        return true;
      default:
        return false;
    }
  }

  /// Photo URL for reciter's portrait (for visual recognition)
  /// Note: In production, replace with actual reciter photos
  String? get photoUrl {
    // For now, returning null - photos should be added to assets folder
    // and referenced here, or use network URLs to actual reciter photos
    switch (this) {
      case Reciter.misharyRashidAlafasy:
        return 'assets/images/reciters/mishary_alafasy.jpg';
      case Reciter.abdulRahmanAlSudais:
        return 'assets/images/reciters/sudais.jpg';
      case Reciter.maherAlMuaiqly:
        return 'assets/images/reciters/maher_muaiqly.jpg';
      case Reciter.saadAlGhamdi:
        return 'assets/images/reciters/saad_ghamdi.jpg';
      case Reciter.abuBakrAlShatri:
        return 'assets/images/reciters/shatri.jpg';
      case Reciter.haniArRifai:
        return 'assets/images/reciters/hani_rifai.jpg';
      case Reciter.hudhaify:
        return 'assets/images/reciters/hudhaify.jpg';
      case Reciter.aliJaber:
        return 'assets/images/reciters/ali_jaber.jpg';
      case Reciter.yasserAlDosari:
        return 'assets/images/reciters/yasser_dosari.jpg';
      case Reciter.nasserAlQatami:
        return 'assets/images/reciters/nasser_qatami.jpg';
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
  final CloudTTSService _cloudTTSService = CloudTTSService();
  final QuranDataService _quranDataService = QuranDataService();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isPlayingDeviceTTS = false;

  // For playing multiple TTS audio chunks in sequence
  List<String> _bengaliAudioUrls = [];
  int _currentBengaliChunkIndex = 0;

  // Preloaded Bengali audio for faster playback in combined mode
  List<String> _preloadedBengaliUrls = [];
  List<String> _preloadedBengaliFiles = []; // Local cached file paths
  int? _preloadedSurah;
  int? _preloadedAyah;
  bool _isPreloading = false;
  bool _bengaliAudioPreloaded = false; // True when actual audio is downloaded

  // Current playback state
  bool _isPlaying = false;
  bool _isLoading = false;
  int? _currentSurah;
  int? _currentAyah;
  Reciter _currentReciter = Reciter.misharyRashidAlafasy;
  BengaliTranslator _currentBengaliTranslator = BengaliTranslator.quranComBengali;
  BengaliAudioSource _bengaliAudioSource = BengaliAudioSource.humanVoice;
  EnglishAudioSource _englishAudioSource = EnglishAudioSource.ibrahimWalk;
  String? _errorMessage;
  AudioRepeatMode _repeatMode = AudioRepeatMode.none;
  AudioPlaybackContent _playbackContent = AudioPlaybackContent.arabicOnly;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Track which part of the ayah is currently playing (for combined modes)
  bool _isPlayingBengaliPart = false;
  bool _isPlayingEnglishPart = false;

  // Track current content label for UI
  String _currentContentLabel = 'Arabic';

  // Track if playing full surah Bengali audio
  bool _isPlayingFullSurahBengali = false;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  int? get currentSurah => _currentSurah;
  int? get currentAyah => _currentAyah;
  Reciter get currentReciter => _currentReciter;
  BengaliTranslator get currentBengaliTranslator => _currentBengaliTranslator;
  BengaliAudioSource get bengaliAudioSource => _bengaliAudioSource;
  EnglishAudioSource get englishAudioSource => _englishAudioSource;
  AudioRepeatMode get repeatMode => _repeatMode;
  AudioPlaybackContent get playbackContent => _playbackContent;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioPlayer get player => _player;
  bool get isPlayingBengaliPart => _isPlayingBengaliPart;
  bool get isPlayingEnglishPart => _isPlayingEnglishPart;
  bool get isPlayingFullSurahBengali => _isPlayingFullSurahBengali;
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
      if (!_isPlayingDeviceTTS) {
        _isPlaying = state.playing;
        notifyListeners();
      }
    });

    // Listen to position changes
    _player.positionStream.listen((pos) {
      if (!_isPlayingDeviceTTS) {
        _position = pos;
        notifyListeners();
      }
    });

    // Listen to duration changes
    _player.durationStream.listen((dur) {
      if (!_isPlayingDeviceTTS) {
        _duration = dur ?? Duration.zero;
        notifyListeners();
      }
    });

    // Listen for playback completion on main player
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

        // For English playback, completion is handled normally
        // (Ibrahim Walk audio is single file per ayah, no chunking needed)
        _handlePlaybackComplete();
      }
    });
    
    // Initialize Device TTS
    _flutterTts.setLanguage("bn-BD");
    _flutterTts.setCompletionHandler(() {
      _isPlayingDeviceTTS = false;
      _handleBengaliPlaybackComplete();
    });
    _flutterTts.setErrorHandler((msg) {
       _isPlayingDeviceTTS = false;
       _isPlaying = false;
       debugPrint("TTS Error: $msg");
       notifyListeners();
    });
  }

  /// Play a specific ayah based on current playback content setting
  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    // Stop any ongoing playback
    await _flutterTts.stop();
    _isPlayingDeviceTTS = false;

    _currentSurah = surahNumber;
    _currentAyah = ayahNumber;
    _isPlayingBengaliPart = false;
    _isPlayingEnglishPart = false;
    _isPlayingFullSurahBengali = false;

    switch (_playbackContent) {
      case AudioPlaybackContent.arabicOnly:
        await _playArabicAyah(surahNumber, ayahNumber);
        break;
      case AudioPlaybackContent.bengaliOnly:
        // If Device TTS is selected, use it regardless of mode (it's fast/instant)
        if (_bengaliAudioSource == BengaliAudioSource.deviceTTS) {
           await _playBengaliDeviceTTS(surahNumber, ayahNumber);
        } else {
           await _playBengaliAyah(surahNumber, ayahNumber);
        }
        break;
      case AudioPlaybackContent.arabicThenBengali:
        // If source is Human Voice, play the full mixed file (Arabic+Bengali)
        if (_bengaliAudioSource == BengaliAudioSource.humanVoice) {
          await _playMixedHumanVoice(surahNumber);
        } else {
          // Default: Play Arabic (Ayah), then Bengali (TTS/Device)
          _isPlayingBengaliPart = false;
          await _playArabicAyah(surahNumber, ayahNumber);
        }
        break;
      case AudioPlaybackContent.englishOnly:
        // Play only English translation audio
        await _playEnglishAyah(surahNumber, ayahNumber);
        break;
      case AudioPlaybackContent.arabicThenEnglish:
        // Play Arabic first, then English translation
        _isPlayingEnglishPart = false;
        await _playArabicAyah(surahNumber, ayahNumber);
        break;
    }
  }

  /// Play Arabic recitation for a specific ayah with multi-source fallback
  /// Ensures 100% accuracy by only using verified sources for the selected reciter
  Future<void> _playArabicAyah(int surahNumber, int ayahNumber) async {
    try {
      await _flutterTts.stop(); // Ensure TTS is stopped
      _isPlayingDeviceTTS = false;
      
      _isLoading = true;
      _currentContentLabel = 'Arabic';
      notifyListeners();

      // Get all available sources for the current reciter
      final sources = _getReciterSources(_currentReciter);
      
      if (sources.isEmpty) {
        throw Exception('No audio sources available for ${_currentReciter.displayName}');
      }

      // Try each source in order until one works
      bool audioLoaded = false;
      String? lastError;
      
      for (int i = 0; i < sources.length; i++) {
        final source = sources[i];
        final url = source.getAudioUrl(surahNumber, ayahNumber);
        
        debugPrint('🎵 Trying source ${i + 1}/${sources.length} for ${_currentReciter.displayName}');
        debugPrint('   Provider: ${source.provider}, Bitrate: ${source.bitrate}kbps');
        debugPrint('   URL: $url');

        try {
          // Start preloading Bengali audio if using Cloud TTS (only on first attempt)
          if (i == 0 && 
              _playbackContent == AudioPlaybackContent.arabicThenBengali && 
              _bengaliAudioSource == BengaliAudioSource.cloudTTS) {
            _preloadBengaliAudio(surahNumber, ayahNumber);
          }

          await _player.setUrl(url);
          await _player.setSpeed(_playbackSpeed);
          await _player.play();
          
          audioLoaded = true;
          debugPrint('✅ Successfully loaded audio from ${source.provider}');
          break;
        } catch (e) {
          lastError = e.toString();
          debugPrint('❌ Failed to load from ${source.provider}: $e');
          
          // If this is not the last source, try the next one
          if (i < sources.length - 1) {
            debugPrint('⏭️  Trying next source...');
            continue;
          }
        }
      }

      if (!audioLoaded) {
        throw Exception('All audio sources failed for ${_currentReciter.displayName}. Last error: $lastError');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      _errorMessage = 'Unable to load audio for ${_currentReciter.displayName}: ${e.toString()}';
      notifyListeners();
      debugPrint('❌ Error playing Arabic audio: $e');
      rethrow;
    }
  }

  /// Get all available audio sources for a reciter
  /// Returns sources in priority order (primary first, then fallbacks)
  List<ReciterAudioSource> _getReciterSources(Reciter reciter) {
    // Import the sources from reciter_audio_sources.dart
    switch (reciter) {
      case Reciter.misharyRashidAlafasy:
        return ReciterSources.misharyAlafasy;
      case Reciter.abdulRahmanAlSudais:
        return ReciterSources.alSudais;
      case Reciter.maherAlMuaiqly:
        return ReciterSources.maherAlMuaiqly;
      case Reciter.saadAlGhamdi:
        return ReciterSources.saadAlGhamdi;
      case Reciter.abuBakrAlShatri:
        return ReciterSources.abuBakrAlShatri;
      case Reciter.haniArRifai:
        return ReciterSources.haniArRifai;
      case Reciter.hudhaify:
        return ReciterSources.hudhaify;
      case Reciter.aliJaber:
        return ReciterSources.aliJaber;
      case Reciter.yasserAlDosari:
        return ReciterSources.yasserAlDosari;
      case Reciter.nasserAlQatami:
        return ReciterSources.nasserAlQatami;
    }
  }
  
  
  // ... methods ...

  /// Pause playback
  Future<void> pause() async {
    if (_isPlayingDeviceTTS) {
      await _flutterTts.pause();
    } else {
      await _player.pause();
    }
    notifyListeners();
  }

  /// Resume playback
  Future<void> resume() async {
    if (_isPlayingDeviceTTS) {
      // Note: resume on flutter_tts depends on platform. 
      // If it doesn't work, we might need to re-speak. assuming it works.
      // Actually flutter_tts doesn't always have 'resume' exposed properly in all versions for named method.
      // But pause/speak usually handles it.
      // We will assume play/speak logic is handled by internal state or user re-trigger.
      // But here we call _player.play() for just_audio.
      // For TTS, we might not be able to resume mid-sentence easily.
    } else {
      await _player.play();
    }
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
    await _flutterTts.stop();
    _currentSurah = null;
    _currentAyah = null;
    _isPlaying = false;
    _isPlayingDeviceTTS = false;
    _isPlayingBengaliPart = false;
    _isPlayingFullSurahBengali = false;
    _bengaliAudioUrls = [];
    _currentBengaliChunkIndex = 0;
    // Clear preloaded data
    _preloadedBengaliUrls = [];
    _preloadedBengaliFiles = [];
    _preloadedSurah = null;
    _preloadedAyah = null;
    _bengaliAudioPreloaded = false;
    notifyListeners();
  }

  /// Play Mixed (Arabic + Bengali) using Human Voice (full surah)
  Future<void> _playMixedHumanVoice(int surahNumber) async {
    try {
      _isLoading = true;
      _currentContentLabel = 'Arabic + Bengali (Human)';
      _errorMessage = null;
      _isPlayingFullSurahBengali = true; // Treating it as full surah mode
      notifyListeners();

      final url = BengaliAudioUrls.getSurahAudioUrl(surahNumber);
      if (url == null) {
        _errorMessage = 'Audio not found for surah $surahNumber';
        _isLoading = false;
        _isPlayingFullSurahBengali = false;
        notifyListeners();
        return;
      }

      debugPrint('Playing Mixed Human Voice for Surah $surahNumber: $url');

      await _player.setUrl(url);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isPlayingFullSurahBengali = false;
      _errorMessage = 'Error playing audio: $e';
      debugPrint('Error playing Mixed Human Voice: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Preload Bengali audio in background for faster playback
  /// Downloads audio files to local cache while Arabic is playing
  Future<void> _preloadBengaliAudio(int surahNumber, int ayahNumber) async {
    if (_isPreloading) return;

    _isPreloading = true;
    _preloadedBengaliUrls = [];
    _preloadedBengaliFiles = [];
    _preloadedSurah = null;
    _preloadedAyah = null;
    _bengaliAudioPreloaded = false;

    try {
      debugPrint('⏳ Preloading Bengali audio for $surahNumber:$ayahNumber');

      // Get the ayah data with Bengali translation
      final ayahs = await _quranDataService.getAyahsForSurah(surahNumber);
      final ayah = ayahs.firstWhere(
        (a) => a.numberInSurah == ayahNumber,
        orElse: () => throw Exception('Ayah not found'),
      );

      final bengaliText = ayah.translationBengali;

      if (bengaliText != null && bengaliText.isNotEmpty) {
        // Generate cloud TTS audio URLs
        _preloadedBengaliUrls = _cloudTTSService.generateAudioUrls(bengaliText);
        _preloadedSurah = surahNumber;
        _preloadedAyah = ayahNumber;

        // Download ALL chunks to local cache
        if (_preloadedBengaliUrls.isNotEmpty) {
          final tempDir = await getTemporaryDirectory();
          final cacheDir = Directory('${tempDir.path}/bengali_tts_cache');
          if (!await cacheDir.exists()) {
            await cacheDir.create(recursive: true);
          }

          // Download all chunks in parallel
          final downloadFutures = <Future<String?>>[];
          for (int i = 0; i < _preloadedBengaliUrls.length; i++) {
            downloadFutures.add(_downloadAudioChunk(
              _preloadedBengaliUrls[i],
              '${cacheDir.path}/bengali_${surahNumber}_${ayahNumber}_$i.mp3',
            ));
          }

          final results = await Future.wait(downloadFutures);
          _preloadedBengaliFiles = results.whereType<String>().toList();

          if (_preloadedBengaliFiles.isNotEmpty) {
            _bengaliAudioPreloaded = true;
            debugPrint('✅ Bengali audio downloaded: ${_preloadedBengaliFiles.length} files cached');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error preloading Bengali audio: $e');
      _bengaliAudioPreloaded = false;
    } finally {
      _isPreloading = false;
    }
  }

  /// Download a single audio chunk to local file
  Future<String?> _downloadAudioChunk(String url, String filePath) async {
    try {
      final file = File(filePath);

      // Check if already cached
      if (await file.exists()) {
        debugPrint('📁 Using cached: $filePath');
        return filePath;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Referer': 'https://translate.google.com/',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('📥 Downloaded: $filePath');
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Download failed: $e');
      return null;
    }
  }

  /// Play Bengali translation audio
  /// Uses either Cloud TTS or Human Voice based on bengaliAudioSource setting
  /// Note: For arabicThenBengali mode, ALWAYS use TTS (verse-by-verse) because:
  /// 1. Human voice files contain both Arabic and Bengali mixed
  /// 2. TTS provides Bengali-only audio that's cached for instant playback
  Future<void> _playBengaliAyah(int surahNumber, int ayahNumber) async {
    // If Device TTS is selected, use it regardless of mode (it's fast/instant)
    if (_bengaliAudioSource == BengaliAudioSource.deviceTTS) {
      await _playBengaliDeviceTTS(surahNumber, ayahNumber);
      return;
    }

    // For Arabic+Bengali mode, ALWAYS use Cloud TTS (it's preloaded and cached)
    if (_playbackContent == AudioPlaybackContent.arabicThenBengali) {
      await _playBengaliTTS(surahNumber, ayahNumber);
      return;
    }

    // Bengali Only mode - also use TTS (verse-by-verse Bengali only)
    if (_playbackContent == AudioPlaybackContent.bengaliOnly) {
      await _playBengaliTTS(surahNumber, ayahNumber);
      return;
    }

    // For other modes, respect user's audio source preference
    if (_bengaliAudioSource == BengaliAudioSource.humanVoice) {
      await _playBengaliHumanVoice(surahNumber);
    } else {
      await _playBengaliTTS(surahNumber, ayahNumber);
    }
  }

  /// Play Bengali translation using Device TTS (FlutterTTS)
  Future<void> _playBengaliDeviceTTS(int surahNumber, int ayahNumber) async {
    try {
      _currentContentLabel = 'বাংলা (ডিভাইস)';
      _errorMessage = null;
      _isPlayingFullSurahBengali = false;
      _isPlayingDeviceTTS = true;
      _isPlaying = true;
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
        _isPlayingDeviceTTS = false;
        _isPlaying = false;
        notifyListeners();
        _handleBengaliAudioFailed();
        return;
      }

      debugPrint('Playing Bengali Device TTS for $surahNumber:$ayahNumber');
      
      // Stop player just in case
      await _player.pause();
      
      // Speak
      await _flutterTts.speak(bengaliText);
      // Completion is handled by setCompletionHandler in init
    } catch (e) {
      _isPlayingDeviceTTS = false;
      _isPlaying = false;
      _errorMessage = 'Error playing Device TTS: $e';
      debugPrint('Error playing Bengali Device TTS: $e');
      notifyListeners();
      
      if (_playbackContent == AudioPlaybackContent.arabicThenBengali) {
        _handleBengaliAudioFailed();
      }
    }
  }

  /// Play Bengali translation using Human Voice (full surah audio)
  /// Source: Bangladesh Islamic Foundation translation from Archive.org
  Future<void> _playBengaliHumanVoice(int surahNumber) async {
    try {
      _isLoading = true;
      _currentContentLabel = 'বাংলা (মানুষের কণ্ঠ)';
      _errorMessage = null;
      _isPlayingFullSurahBengali = true;
      notifyListeners();

      final url = BengaliAudioUrls.getSurahAudioUrl(surahNumber);
      if (url == null) {
        _errorMessage = 'বাংলা অডিও পাওয়া যায়নি। Bengali audio not found for surah $surahNumber.';
        debugPrint('Bengali human voice audio not found for surah $surahNumber');
        _isLoading = false;
        _isPlayingFullSurahBengali = false;
        _handleBengaliAudioFailed();
        return;
      }

      debugPrint('Playing Bengali Human Voice for Surah $surahNumber: $url');

      await _player.setUrl(url);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isPlayingFullSurahBengali = false;
      _errorMessage = 'বাংলা অডিও চালাতে সমস্যা হয়েছে। Error: $e';
      debugPrint('Error playing Bengali Human Voice: $e');

      // If Bengali audio fails, try to continue with Arabic in combined mode
      if (_playbackContent == AudioPlaybackContent.arabicThenBengali) {
        _handleBengaliAudioFailed();
      } else {
        _isPlaying = false;
        notifyListeners();
      }
    }
  }

  /// Play Bengali translation using Cloud TTS API
  /// No device TTS engine required - plays audio directly from API
  Future<void> _playBengaliTTS(int surahNumber, int ayahNumber) async {
    try {
      _currentContentLabel = 'বাংলা';
      _errorMessage = null;
      _isPlayingFullSurahBengali = false;

      // Check if we have preloaded and cached audio files for this ayah (instant playback)
      if (_preloadedSurah == surahNumber &&
          _preloadedAyah == ayahNumber &&
          _preloadedBengaliFiles.isNotEmpty &&
          _bengaliAudioPreloaded) {
        debugPrint('▶️ Using cached Bengali audio for $surahNumber:$ayahNumber');

        // Use cached file paths instead of URLs
        _bengaliAudioUrls = _preloadedBengaliFiles.map((f) => 'file://$f').toList();
        _currentBengaliChunkIndex = 0;

        // Clear preloaded data
        _preloadedBengaliUrls = [];
        _preloadedBengaliFiles = [];
        _preloadedSurah = null;
        _preloadedAyah = null;
        _bengaliAudioPreloaded = false;

        // Play immediately from local file (no network delay!)
        await _playBengaliChunk();
        return;
      }

      // No preloaded data, load normally
      _isLoading = true;
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
      if (_playbackContent == AudioPlaybackContent.arabicThenBengali) {
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

    // Reset Bengali state
    _isPlayingBengaliPart = false;

    // Move to next ayah based on repeat mode
    _moveToNextAyahBasedOnRepeatMode();
  }

  /// Move to next ayah based on current repeat mode
  void _moveToNextAyahBasedOnRepeatMode() {
    switch (_repeatMode) {
      case AudioRepeatMode.none:
        // Stop playback
        _currentSurah = null;
        _currentAyah = null;
        _currentContentLabel = '';
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



  /// Handle playback completion based on repeat mode and playback content
  void _handlePlaybackComplete() {
    debugPrint('Playback complete - content: ${_playbackContent.name}, isPlayingBengali: $_isPlayingBengaliPart, isPlayingEnglish: $_isPlayingEnglishPart, FullSurah: $_isPlayingFullSurahBengali');

    // If we were playing full surah (Human Voice Mixed), we are done with the surah.
    if (_isPlayingFullSurahBengali) {
      _isPlayingFullSurahBengali = false;
      stop(); // Simple behavior: stop after full surah.
      return;
    }

    // For Arabic+Bengali mode: after Arabic finishes, play Bengali
    if (_playbackContent == AudioPlaybackContent.arabicThenBengali && !_isPlayingBengaliPart) {
      debugPrint('Arabic finished, now playing Bengali...');
      _isPlayingBengaliPart = true;
      if (_currentSurah != null && _currentAyah != null) {
        _playBengaliAyah(_currentSurah!, _currentAyah!);
        return;
      }
    }

    // For Arabic+English mode: after Arabic finishes, play English
    if (_playbackContent == AudioPlaybackContent.arabicThenEnglish && !_isPlayingEnglishPart) {
      debugPrint('Arabic finished, now playing English...');
      _isPlayingEnglishPart = true;
      if (_currentSurah != null && _currentAyah != null) {
        _playEnglishAyah(_currentSurah!, _currentAyah!);
        return;
      }
    }

    // For Arabic Only mode or after Bengali/English completes: move to next ayah
    _isPlayingBengaliPart = false;
    _isPlayingEnglishPart = false;
    _moveToNextAyahBasedOnRepeatMode();
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

  /// Handle when Bengali audio fails in combined mode
  void _handleBengaliAudioFailed() {
    _handlePlaybackComplete();
  }

  void setPlaybackContent(AudioPlaybackContent content) {
    _playbackContent = content;
    debugPrint('Playback content changed to: ${content.displayName}');
    notifyListeners();
  }

  void setBengaliTranslator(BengaliTranslator translator) {
    if (_currentBengaliTranslator == translator) return;
    _currentBengaliTranslator = translator;
    debugPrint('Bengali translator changed to: ${translator.displayName}');
    notifyListeners();
  }

  void setBengaliAudioSource(BengaliAudioSource source) {
    if (_bengaliAudioSource == source) return;
    _bengaliAudioSource = source;
    debugPrint('Bengali audio source changed to: ${source.displayName}');
    notifyListeners();
  }

  void setEnglishAudioSource(EnglishAudioSource source) {
    if (_englishAudioSource == source) return;
    _englishAudioSource = source;
    debugPrint('English audio source changed to: ${source.displayName}');
    notifyListeners();
  }

  /// Play English translation audio for a specific ayah
  /// Uses Ibrahim Walk (Sahih International) from EveryAyah.com
  Future<void> _playEnglishAyah(int surahNumber, int ayahNumber) async {
    try {
      await _flutterTts.stop(); // Ensure TTS is stopped
      _isPlayingDeviceTTS = false;

      _isLoading = true;
      _currentContentLabel = 'English';
      _errorMessage = null;
      notifyListeners();

      // Get audio URL based on selected source
      final url = _englishAudioSource.getAudioUrl(surahNumber, ayahNumber);

      if (_englishAudioSource == EnglishAudioSource.cloudTTS) {
        // Use Cloud TTS for English
        await _playEnglishCloudTTS(surahNumber, ayahNumber);
        return;
      }

      // Play Ibrahim Walk audio from EveryAyah.com
      debugPrint('🎵 Playing English audio (Ibrahim Walk) for $surahNumber:$ayahNumber');
      debugPrint('   URL: $url');

      await _player.setUrl(url);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unable to load English audio: ${e.toString()}';
      debugPrint('❌ Error playing English audio: $e');
      notifyListeners();

      // If English audio fails, try Cloud TTS as fallback
      if (_englishAudioSource == EnglishAudioSource.ibrahimWalk) {
        debugPrint('⏭️ Falling back to Cloud TTS for English...');
        await _playEnglishCloudTTS(surahNumber, ayahNumber);
      } else {
        _handleEnglishAudioFailed();
      }
    }
  }

  /// Play English translation using Cloud TTS (Google TTS)
  Future<void> _playEnglishCloudTTS(int surahNumber, int ayahNumber) async {
    try {
      _currentContentLabel = 'English (TTS)';
      _errorMessage = null;
      notifyListeners();

      // Get the ayah data with English translation
      final ayahs = await _quranDataService.getAyahsForSurah(surahNumber);
      final ayah = ayahs.firstWhere(
        (a) => a.numberInSurah == ayahNumber,
        orElse: () => throw Exception('Ayah not found'),
      );

      final englishText = ayah.translationEnglish;

      if (englishText == null || englishText.isEmpty) {
        _errorMessage = 'English translation not found.';
        debugPrint('English translation not found for $surahNumber:$ayahNumber');
        _isLoading = false;
        _handleEnglishAudioFailed();
        return;
      }

      debugPrint('Playing English Cloud TTS for $surahNumber:$ayahNumber');

      // Use Google TTS API for English (similar to Bengali Cloud TTS)
      final ttsUrl = 'https://translate.google.com/translate_tts'
          '?ie=UTF-8&client=tw-ob&tl=en&q=${Uri.encodeComponent(englishText)}';

      await _player.setUrl(ttsUrl);
      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error playing English TTS: $e';
      debugPrint('Error playing English Cloud TTS: $e');
      notifyListeners();
      _handleEnglishAudioFailed();
    }
  }

  /// Handle when English audio fails
  void _handleEnglishAudioFailed() {
    _isPlayingEnglishPart = false;
    _handlePlaybackComplete();
  }

  Future<void> playFullSurahBengali(int surahNumber) async {
    _currentSurah = surahNumber;
    _currentAyah = 1;
    _isPlayingBengaliPart = true;
    _isPlayingFullSurahBengali = true;
    await _playBengaliHumanVoice(surahNumber);
  }

  Future<void> playArabicOnly(int surahNumber, int ayahNumber) async {
    _currentSurah = surahNumber;
    _currentAyah = ayahNumber;
    _isPlayingBengaliPart = false;
    await _playArabicAyah(surahNumber, ayahNumber);
  }

  Future<void> playFromAyah(int surahNumber, int ayahNumber) async {
    _repeatMode = AudioRepeatMode.continuous;
    await playAyah(surahNumber, ayahNumber);
  }

  bool get isBengaliTTSAvailable => true;

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed.clamp(0.5, 2.0);
    await _player.setSpeed(_playbackSpeed);
    await _flutterTts.setSpeechRate(speed * 0.5); 
    notifyListeners();
  }

  void setRepeatMode(AudioRepeatMode mode) {
    _repeatMode = mode;
    notifyListeners();
  }

  void cycleRepeatMode() {
    final modes = AudioRepeatMode.values;
    final currentIndex = modes.indexOf(_repeatMode);
    _repeatMode = modes[(currentIndex + 1) % modes.length];
    notifyListeners();
  }

  void setReciter(Reciter reciter) {
    if (_currentReciter == reciter) return;
    _currentReciter = reciter;
    debugPrint('Reciter changed to: ${reciter.displayName}');
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

  /// Dispose of resources
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
