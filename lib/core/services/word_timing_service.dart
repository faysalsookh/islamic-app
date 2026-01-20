import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'audio_service.dart';

/// Represents timing data for a single word segment
/// Format from QuranCDN: [word_index, start_ms, end_ms]
class WordSegment {
  final int wordIndex;
  final int startMsec;
  final int endMsec;

  const WordSegment({
    required this.wordIndex,
    required this.startMsec,
    required this.endMsec,
  });

  factory WordSegment.fromList(List<dynamic> data) {
    return WordSegment(
      wordIndex: (data[0] as num).toInt(),
      startMsec: (data[1] as num).toInt(),
      endMsec: (data[2] as num).toInt(),
    );
  }

  /// Check if a position (in milliseconds) falls within this segment
  bool containsPosition(int positionMsec) {
    return positionMsec >= startMsec && positionMsec < endMsec;
  }
}

/// Represents timing data for a single ayah
class AyahTiming {
  final int surah;
  final int ayah;
  final List<WordSegment> segments; // Segments with timestamps relative to ayah start

  const AyahTiming({
    required this.surah,
    required this.ayah,
    required this.segments,
  });

  /// Get the word index that should be highlighted at a given position
  /// positionMsec is relative to the start of the ayah (for ayah-by-ayah audio)
  /// offsetMsec can be used to adjust for differences between audio sources
  /// Returns 0-based index (subtract 1 from QuranCDN's 1-based index)
  int? getHighlightedWordIndex(int positionMsec, {int offsetMsec = 0}) {
    // Apply offset to compensate for audio timing differences
    final adjustedPosition = positionMsec + offsetMsec;

    for (final segment in segments) {
      if (segment.containsPosition(adjustedPosition)) {
        // QuranCDN uses 1-based index, convert to 0-based
        return segment.wordIndex - 1;
      }
    }
    return null;
  }
}

/// Service for managing word-by-word timing data for Quran recitation
/// Uses QuranCDN API for word-level timing segments
class WordTimingService extends ChangeNotifier {
  static final WordTimingService _instance = WordTimingService._internal();
  factory WordTimingService() => _instance;
  WordTimingService._internal();

  // Cache for loaded timing data: Map<reciterId, Map<surahNumber, Map<ayahNumber, AyahTiming>>>
  final Map<int, Map<int, Map<int, AyahTiming>>> _timingCache = {};

  // Currently highlighted word index (-1 means none)
  int _highlightedWordIndex = -1;
  int get highlightedWordIndex => _highlightedWordIndex;

  // For compatibility with existing code
  Set<int> get highlightedWords =>
      _highlightedWordIndex >= 0 ? {_highlightedWordIndex} : {};

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  /// Timing offset to compensate for differences between EveryAyah audio and QuranCDN timing
  /// Positive value = highlight earlier, Negative value = highlight later
  /// Adjust this based on testing (typically -200 to 200ms)
  static const int _timingOffsetMsec = 0;

  /// QuranCDN API base URL
  static const String _apiBaseUrl = 'https://api.qurancdn.com/api/qdc/audio/reciters';

  /// Map reciters to their QuranCDN reciter IDs
  int? _getReciterId(Reciter reciter) {
    switch (reciter) {
      case Reciter.misharyRashidAlafasy:
        return 7; // Mishari Rashid al-Afasy
      case Reciter.abdulBasitAbdulSamad:
        return 1; // Abdul Basit Abdul Samad (Murattal)
      case Reciter.abdulRahmanAlSudais:
        return 6; // Abdul Rahman Al-Sudais
      case Reciter.abuBakrAlShatri:
        return 4; // Abu Bakr al-Shatri
      case Reciter.haniArRifai:
        return 9; // Hani ar-Rifai
      case Reciter.maherAlMuaiqly:
        return 5; // Maher Al Muaiqly
    }
  }

  /// Check if timing data is available for a reciter (all reciters supported now)
  bool hasTimingData(Reciter reciter) {
    return _getReciterId(reciter) != null;
  }

  /// Load timing data for a specific surah and reciter from QuranCDN
  Future<bool> loadTimingData(Reciter reciter, int surahNumber) async {
    final reciterId = _getReciterId(reciter);
    if (reciterId == null) {
      debugPrint('No reciter ID for ${reciter.displayName}');
      return false;
    }

    // Check cache first
    if (_timingCache.containsKey(reciterId) &&
        _timingCache[reciterId]!.containsKey(surahNumber)) {
      debugPrint('Using cached timing data for surah $surahNumber');
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '$_apiBaseUrl/$reciterId/audio_files?chapter=$surahNumber&segments=true';
      debugPrint('Loading timing data from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final audioFiles = jsonData['audio_files'] as List<dynamic>;

        if (audioFiles.isEmpty) {
          throw Exception('No audio files found');
        }

        final audioFile = audioFiles.first as Map<String, dynamic>;
        final verseTimings = audioFile['verse_timings'] as List<dynamic>;

        // Parse and cache the timing data
        _timingCache[reciterId] ??= {};
        _timingCache[reciterId]![surahNumber] = {};

        for (final verseTiming in verseTimings) {
          final verseKey = verseTiming['verse_key'] as String;
          final parts = verseKey.split(':');
          final ayahNumber = int.parse(parts[1]);

          final segmentsList = verseTiming['segments'] as List<dynamic>?;
          final timestampFrom = (verseTiming['timestamp_from'] as num?)?.toInt() ?? 0;

          if (segmentsList != null && segmentsList.isNotEmpty) {
            // Convert absolute timestamps to relative (subtract timestampFrom)
            // Also filter out invalid segments (those with less than 3 elements)
            final segments = <WordSegment>[];
            for (final s in segmentsList) {
              final segmentData = s as List<dynamic>;
              if (segmentData.length >= 3) {
                final wordIndex = (segmentData[0] as num).toInt();
                final startMsec = (segmentData[1] as num).toInt() - timestampFrom;
                final endMsec = (segmentData[2] as num).toInt() - timestampFrom;
                // Ensure non-negative relative timestamps
                segments.add(WordSegment(
                  wordIndex: wordIndex,
                  startMsec: startMsec < 0 ? 0 : startMsec,
                  endMsec: endMsec < 0 ? 0 : endMsec,
                ));
              }
            }

            if (segments.isNotEmpty) {
              _timingCache[reciterId]![surahNumber]![ayahNumber] = AyahTiming(
                surah: surahNumber,
                ayah: ayahNumber,
                segments: segments,
              );
              // Debug: log first ayah's timing data
              if (ayahNumber == 1) {
                debugPrint('Ayah 1 timing - timestampFrom: $timestampFrom, segments: ${segments.map((s) => "[${s.wordIndex}, ${s.startMsec}, ${s.endMsec}]").join(", ")}');
              }
            }
          }
        }

        _isLoading = false;
        notifyListeners();

        debugPrint('Loaded timing data for ${verseTimings.length} ayahs in surah $surahNumber');
        return true;
      } else {
        throw Exception('Failed to load timing data: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading timing data: $e');
      notifyListeners();
      return false;
    }
  }

  /// Get timing data for a specific ayah (from cache)
  AyahTiming? getAyahTiming(Reciter reciter, int surahNumber, int ayahNumber) {
    final reciterId = _getReciterId(reciter);
    if (reciterId == null) return null;

    return _timingCache[reciterId]?[surahNumber]?[ayahNumber];
  }

  /// Update highlighted words based on current audio position
  void updateHighlightedWords(
    Reciter reciter,
    int surahNumber,
    int ayahNumber,
    int positionMsec,
  ) {
    final timing = getAyahTiming(reciter, surahNumber, ayahNumber);
    if (timing == null) {
      debugPrint('No timing data for surah $surahNumber ayah $ayahNumber');
      if (_highlightedWordIndex != -1) {
        _highlightedWordIndex = -1;
        notifyListeners();
      }
      return;
    }

    final newIndex = timing.getHighlightedWordIndex(positionMsec, offsetMsec: _timingOffsetMsec) ?? -1;
    // Log every 500ms or on change
    if (positionMsec % 500 < 50 || newIndex != _highlightedWordIndex) {
      debugPrint('Ayah $ayahNumber, Position: $positionMsec ms (offset: $_timingOffsetMsec) -> word index: $newIndex');
      if (timing.segments.isNotEmpty && newIndex < 0) {
        final first = timing.segments.first;
        final last = timing.segments.last;
        debugPrint('  Segments range: ${first.startMsec}-${last.endMsec}ms');
      }
    }
    if (newIndex != _highlightedWordIndex) {
      _highlightedWordIndex = newIndex;
      notifyListeners();
    }
  }

  /// Clear highlighted words
  void clearHighlight() {
    if (_highlightedWordIndex != -1) {
      _highlightedWordIndex = -1;
      notifyListeners();
    }
  }

  /// Clear all cached data
  void clearCache() {
    _timingCache.clear();
    _highlightedWordIndex = -1;
    notifyListeners();
  }
}
