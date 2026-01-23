import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Page displaying essential Ramadan Duas (supplications)
class RamadanDuasPage extends StatefulWidget {
  const RamadanDuasPage({super.key});

  @override
  State<RamadanDuasPage> createState() => _RamadanDuasPageState();
}

class _RamadanDuasPageState extends State<RamadanDuasPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Track which dua is currently playing (by title/id)
  String? _currentlyPlayingTitle;
  bool _isLoading = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleAudio(String title, String? audioUrl) async {
    // If pressing the same button for currently playing item
    if (_currentlyPlayingTitle == title) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      setState(() {}); // Update UI
      return;
    }

    // New item selected
    if (audioUrl == null || audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio coming soon for this Dua')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _currentlyPlayingTitle = title;
      });

      // Stop previous
      await _audioPlayer.stop();
      
      // Load new
      // Note: Using UrlSource for network, or AssetSource for local
      // Since we don't have assets committed, we assume network or future placeholder
      if (audioUrl.startsWith('http')) {
        await _audioPlayer.setUrl(audioUrl);
      } else {
         // Assuming asset for future
         // await _audioPlayer.setAsset(audioUrl);
         // For now, fail gracefully
         throw Exception("Local asset not found");
      }

      await _audioPlayer.play();

      // Listen for completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
           setState(() {
             _currentlyPlayingTitle = null;
           });
        }
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play audio: ${e.toString().split(':')[0]}')),
      );
      setState(() {
        _currentlyPlayingTitle = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramadan Duas'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDuaCard(
            title: 'Sehri Dua (Intention for Fasting)',
            titleBengali: 'সেহরির দোয়া (রোজার নিয়ত)',
            arabic: 'وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ',
            transliteration: 'Wa bisawmi ghadinn nawaiytu min shahri ramadan',
            translation: 'I intend to keep the fast for tomorrow in the month of Ramadan',
            translationBengali: 'আমি আগামীকাল রমজান মাসের রোজা রাখার নিয়ত করছি',
            audioUrl: null, // Placeholder
            isDark: isDark,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildDuaCard(
            title: 'Iftar Dua (Breaking the Fast)',
            titleBengali: 'ইফতারের দোয়া (রোজা ভাঙ্গার দোয়া)',
            arabic: 'اللَّهُمَّ إِنِّي لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَيْكَ تَوَكَّلْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ',
            transliteration: 'Allahumma inni laka sumtu wa bika aamantu wa \'alayka tawakkaltu wa \'ala rizq-ika aftartu',
            translation: 'O Allah! I fasted for You and I believe in You and I put my trust in You and I break my fast with Your sustenance',
            translationBengali: 'হে আল্লাহ! আমি তোমার জন্য রোজা রেখেছি এবং তোমার উপর ঈমান এনেছি এবং তোমার উপর ভরসা করেছি এবং তোমার দেয়া রিযিক দিয়ে ইফতার করছি',
            audioUrl: null,
            isDark: isDark,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildDuaCard(
            title: 'Short Iftar Dua',
            titleBengali: 'সংক্ষিপ্ত ইফতারের দোয়া',
            arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ',
            transliteration: 'Dhahaba al-zama\'u wa abtalat al-\'uruqu wa thabata al-ajru in sha Allah',
            translation: 'The thirst is gone, the veins are moistened, and the reward is confirmed, if Allah wills',
            translationBengali: 'পিপাসা দূর হয়েছে, শিরা-উপশিরা সিক্ত হয়েছে এবং ইনশাআল্লাহ সওয়াব নির্ধারিত হয়েছে',
            audioUrl: null,
            isDark: isDark,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildDuaCard(
            title: 'Laylatul Qadr Dua',
            titleBengali: 'লাইলাতুল কদরের দোয়া',
            arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
            transliteration: 'Allahumma innaka \'afuwwun tuhibbul \'afwa fa\'fu \'anni',
            translation: 'O Allah, You are Most Forgiving, and You love forgiveness; so forgive me',
            translationBengali: 'হে আল্লাহ! নিশ্চয়ই তুমি ক্ষমাশীল, ক্ষমা করা তুমি পছন্দ কর, অতএব আমাকে ক্ষমা করে দাও',
            audioUrl: null,
            isDark: isDark,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard({
    required String title,
    required String titleBengali,
    required String arabic,
    required String transliteration,
    required String translation,
    required String translationBengali,
    required String? audioUrl,
    required bool isDark,
    required ThemeData theme,
  }) {
    final isPlaying = _currentlyPlayingTitle == title;
    
    return ElegantCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Audio Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.heading3(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      titleBengali,
                      style: AppTypography.bodyMedium(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _handleAudio(title, audioUrl),
                icon: _isLoading && isPlaying 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    : Icon(
                        isPlaying && _audioPlayer.playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Arabic text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTypography.quranText(
                fontSize: 24,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Transliteration
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.warmBeige,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transliteration:',
                  style: AppTypography.bodySmall(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transliteration,
                  style: AppTypography.bodyMedium(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // English Translation
          _buildTranslation(
            'Translation:',
            translation,
            isDark,
          ),
          
          const SizedBox(height: 8),
          
          // Bengali Translation
          _buildTranslation(
            'বাংলা অনুবাদ:',
            translationBengali,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTranslation(String label, String text, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: AppTypography.bodyMedium(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
