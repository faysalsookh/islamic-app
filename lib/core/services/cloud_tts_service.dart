import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Cloud-based Text-to-Speech service for Bengali translation
/// Uses Google Translate TTS API - no device TTS engine required
class CloudTTSService {
  static final CloudTTSService _instance = CloudTTSService._internal();
  factory CloudTTSService() => _instance;
  CloudTTSService._internal();

  /// Maximum characters per TTS request (Google TTS limit)
  static const int _maxCharsPerRequest = 200;

  /// Generate TTS audio URL for Bengali text
  /// Returns a URL that can be played directly with audio player
  String generateAudioUrl(String text, {String language = 'bn'}) {
    final encodedText = Uri.encodeComponent(text);
    return 'https://translate.google.com/translate_tts'
        '?ie=UTF-8'
        '&client=tw-ob'
        '&tl=$language'
        '&q=$encodedText';
  }

  /// Generate multiple audio URLs for longer text (splits into chunks)
  /// Returns list of URLs to be played in sequence
  List<String> generateAudioUrls(String text, {String language = 'bn'}) {
    if (text.length <= _maxCharsPerRequest) {
      return [generateAudioUrl(text, language: language)];
    }

    // Split text into chunks at sentence boundaries
    final chunks = _splitTextIntoChunks(text);
    return chunks.map((chunk) => generateAudioUrl(chunk, language: language)).toList();
  }

  /// Split text into chunks respecting sentence boundaries
  List<String> _splitTextIntoChunks(String text) {
    final chunks = <String>[];

    // Bengali sentence endings: । (dari), ? (question), ! (exclamation)
    // Also handle Arabic-style endings and regular punctuation
    final sentenceEndings = RegExp(r'[।?!.؟]');

    String remaining = text.trim();

    while (remaining.isNotEmpty) {
      if (remaining.length <= _maxCharsPerRequest) {
        chunks.add(remaining);
        break;
      }

      // Find the best break point within the limit
      String chunk = remaining.substring(0, _maxCharsPerRequest);
      int breakPoint = -1;

      // Try to find a sentence ending
      final matches = sentenceEndings.allMatches(chunk);
      if (matches.isNotEmpty) {
        breakPoint = matches.last.end;
      }

      // If no sentence ending, try to find a comma or space
      if (breakPoint == -1) {
        final commaIndex = chunk.lastIndexOf(',');
        if (commaIndex > _maxCharsPerRequest ~/ 2) {
          breakPoint = commaIndex + 1;
        }
      }

      if (breakPoint == -1) {
        final spaceIndex = chunk.lastIndexOf(' ');
        if (spaceIndex > _maxCharsPerRequest ~/ 2) {
          breakPoint = spaceIndex + 1;
        }
      }

      // If still no good break point, just use the max length
      if (breakPoint == -1) {
        breakPoint = _maxCharsPerRequest;
      }

      chunks.add(remaining.substring(0, breakPoint).trim());
      remaining = remaining.substring(breakPoint).trim();
    }

    return chunks;
  }

  /// Verify if the TTS service is accessible
  Future<bool> isServiceAvailable() async {
    try {
      final testUrl = generateAudioUrl('পরীক্ষা'); // "Test" in Bengali
      final response = await http.head(Uri.parse(testUrl)).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Cloud TTS service check failed: $e');
      return false;
    }
  }

  /// Get audio content as bytes (for caching or offline use)
  Future<Uint8List?> getAudioBytes(String text, {String language = 'bn'}) async {
    try {
      final url = generateAudioUrl(text, language: language);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching TTS audio: $e');
      return null;
    }
  }
}
