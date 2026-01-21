/// Bengali Quran Audio URLs
/// Source: TrueMuslims.net - High Quality Bangla Quran Audio
/// URL Pattern: https://www.truemuslims.net/Quran/Bangla/[SSS].mp3
/// Features: Full surah audio with Arabic recitation + Bengali translation

class BengaliAudioUrls {
  /// Base URL for Bengali Quran audio CDN
  static const String baseUrl = 'https://www.truemuslims.net/Quran/Bangla';

  /// Get the audio URL for a specific surah (1-114)
  /// Returns the full surah audio with Arabic recitation + Bengali translation
  /// URL format: https://www.truemuslims.net/Quran/Bangla/001.mp3
  static String? getSurahAudioUrl(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return null;
    // Zero-pad surah number to 3 digits (001-114)
    final surahStr = surahNumber.toString().padLeft(3, '0');
    return '$baseUrl/$surahStr.mp3';
  }
}
