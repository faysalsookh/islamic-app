import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for Bengali Quran translation
/// Uses device's TTS engine to read Bengali text
class TTSService extends ChangeNotifier {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal() {
    _initializeTTS();
  }

  final FlutterTts _flutterTts = FlutterTts();

  // State
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  double _speechRate = 0.5; // 0.0 to 1.0
  double _pitch = 1.0; // 0.5 to 2.0
  double _volume = 1.0; // 0.0 to 1.0
  String _currentLanguage = 'bn-BD'; // Bengali (Bangladesh)
  List<dynamic> _availableLanguages = [];
  List<dynamic> _availableVoices = [];
  String? _selectedVoice;

  // Callbacks
  VoidCallback? onComplete;
  VoidCallback? onStart;
  Function(String)? onError;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
  String get currentLanguage => _currentLanguage;
  List<dynamic> get availableLanguages => _availableLanguages;
  List<dynamic> get availableVoices => _availableVoices;
  String? get selectedVoice => _selectedVoice;

  Future<void> _initializeTTS() async {
    try {
      // Get available languages
      _availableLanguages = await _flutterTts.getLanguages;
      debugPrint('TTS Available languages: $_availableLanguages');

      // Get available voices
      _availableVoices = await _flutterTts.getVoices;
      debugPrint('TTS Available voices: ${_availableVoices.length}');

      // Set Bengali language
      final bengaliLanguages = ['bn-BD', 'bn-IN', 'bn'];
      bool languageSet = false;

      for (final lang in bengaliLanguages) {
        if (_availableLanguages.contains(lang)) {
          await _flutterTts.setLanguage(lang);
          _currentLanguage = lang;
          languageSet = true;
          debugPrint('TTS Language set to: $lang');
          break;
        }
      }

      if (!languageSet) {
        // Try to find any Bengali voice
        for (final voice in _availableVoices) {
          if (voice is Map) {
            final locale = voice['locale']?.toString() ?? '';
            if (locale.startsWith('bn')) {
              await _flutterTts.setVoice({'name': voice['name'], 'locale': voice['locale']});
              _currentLanguage = locale;
              _selectedVoice = voice['name'];
              languageSet = true;
              debugPrint('TTS Voice set to: ${voice['name']}');
              break;
            }
          }
        }
      }

      if (!languageSet) {
        debugPrint('TTS: Bengali language not available, using default');
      }

      // Set default parameters
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setVolume(_volume);

      // Setup callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
        notifyListeners();
        onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        notifyListeners();
        onComplete?.call();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _isPaused = false;
        notifyListeners();
        debugPrint('TTS Error: $msg');
        onError?.call(msg.toString());
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        notifyListeners();
      });

      _flutterTts.setPauseHandler(() {
        _isPaused = true;
        notifyListeners();
      });

      _flutterTts.setContinueHandler(() {
        _isPaused = false;
        notifyListeners();
      });

      _isInitialized = true;
      notifyListeners();
      debugPrint('TTS Service initialized successfully');
    } catch (e) {
      debugPrint('TTS initialization error: $e');
      _isInitialized = false;
    }
  }

  /// Speak Bengali text
  Future<void> speak(String text) async {
    if (text.isEmpty) {
      onComplete?.call();
      return;
    }

    try {
      // Stop any current speech
      if (_isSpeaking) {
        await stop();
      }

      final result = await _flutterTts.speak(text);
      if (result == 1) {
        _isSpeaking = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
      onError?.call(e.toString());
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isPaused = false;
      notifyListeners();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isPaused = true;
      notifyListeners();
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
    notifyListeners();
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
    notifyListeners();
  }

  /// Set language
  Future<bool> setLanguage(String language) async {
    try {
      final result = await _flutterTts.setLanguage(language);
      if (result == 1) {
        _currentLanguage = language;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('TTS setLanguage error: $e');
    }
    return false;
  }

  /// Set voice
  Future<bool> setVoice(String voiceName, String locale) async {
    try {
      final result = await _flutterTts.setVoice({'name': voiceName, 'locale': locale});
      if (result == 1) {
        _selectedVoice = voiceName;
        _currentLanguage = locale;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('TTS setVoice error: $e');
    }
    return false;
  }

  /// Get Bengali voices
  List<Map<String, String>> getBengaliVoices() {
    final bengaliVoices = <Map<String, String>>[];
    for (final voice in _availableVoices) {
      if (voice is Map) {
        final locale = voice['locale']?.toString() ?? '';
        if (locale.startsWith('bn')) {
          bengaliVoices.add({
            'name': voice['name']?.toString() ?? '',
            'locale': locale,
          });
        }
      }
    }
    return bengaliVoices;
  }

  /// Check if Bengali is available
  bool get isBengaliAvailable {
    if (_availableLanguages.contains('bn-BD') ||
        _availableLanguages.contains('bn-IN') ||
        _availableLanguages.contains('bn')) {
      return true;
    }
    return getBengaliVoices().isNotEmpty;
  }

  /// Dispose TTS
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
