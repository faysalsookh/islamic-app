import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/models/quran_word.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/bengali_translation_service.dart';

/// Bottom sheet that displays word-by-word translation details
class WordDetailsSheet extends StatefulWidget {
  final QuranWord word;
  final String verseKey;
  final bool isDark;
  final ThemeData theme;

  const WordDetailsSheet({
    super.key,
    required this.word,
    required this.verseKey,
    required this.isDark,
    required this.theme,
  });

  @override
  State<WordDetailsSheet> createState() => _WordDetailsSheetState();
}

class _WordDetailsSheetState extends State<WordDetailsSheet> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final BengaliTranslationService _bengaliService = BengaliTranslationService();

  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  String? _bengaliTranslation;
  bool _isLoadingBengali = false;

  @override
  void initState() {
    super.initState();
    _initBengaliTranslation();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Initialize Bengali translation - use API translation if available, fallback to local/online
  Future<void> _initBengaliTranslation() async {
    // First check if we already have Bengali translation from API
    if (widget.word.translationBn != null && widget.word.translationBn!.isNotEmpty) {
      setState(() {
        _bengaliTranslation = widget.word.translationBn;
        _isLoadingBengali = false;
      });
      return;
    }

    // Fallback: try local dictionary or online translation
    if (widget.word.translationEn == null) return;

    setState(() => _isLoadingBengali = true);

    // First try local dictionary
    final localTranslation = _bengaliService.translate(widget.word.translationEn);
    if (localTranslation != null) {
      setState(() {
        _bengaliTranslation = localTranslation;
        _isLoadingBengali = false;
      });
      return;
    }

    // Then try online translation
    final onlineTranslation = await _bengaliService.translateOnline(widget.word.translationEn!);
    if (mounted) {
      setState(() {
        _bengaliTranslation = onlineTranslation;
        _isLoadingBengali = false;
      });
    }
  }

  Future<void> _playAudio() async {
    final audioUrl = widget.word.fullAudioUrl;
    if (audioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Audio not available for this word'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticService().lightImpact();

    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    setState(() => _isLoadingAudio = true);

    try {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAudio = false);
      }
    }
  }

  // Getters for cleaner access
  QuranWord get word => widget.word;
  String get verseKey => widget.verseKey;
  bool get isDark => widget.isDark;
  ThemeData get theme => widget.theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary)
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Arabic Word - Large Display with Audio Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    // Arabic Text
                    GestureDetector(
                      onLongPress: () {
                        HapticService().mediumImpact();
                        Clipboard.setData(ClipboardData(text: word.textUthmani));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Word copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Text(
                        word.textUthmani,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Scheherazade',
                          fontSize: 48,
                          height: 1.5,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),

                    // Audio Play Button
                    if (word.audioUrl != null) ...[
                      const SizedBox(height: 12),
                      _buildAudioButton(),
                    ],
                    if (word.transliteration != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        word.transliteration!,
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Translations
              _buildTranslationSection(),
              const SizedBox(height: 16),

              // Grammar & Root Info
              if (word.grammar != null) ...[
                _buildGrammarSection(),
                const SizedBox(height: 16),
              ],

              // Word Position
              _buildInfoChip(
                icon: Icons.pin_drop_rounded,
                label: 'Position',
                value: 'Word ${word.position} in verse $verseKey',
              ),
              const SizedBox(height: 16),

              // Tip
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Long press the Arabic word to copy',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _playAudio,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _isPlaying
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoadingAudio)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _isPlaying ? Colors.white : theme.colorScheme.primary,
                  ),
                )
              else
                Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                  size: 20,
                  color: _isPlaying ? Colors.white : theme.colorScheme.primary,
                ),
              const SizedBox(width: 8),
              Text(
                _isPlaying ? 'Playing...' : 'Listen Pronunciation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isPlaying ? Colors.white : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationSection() {
    final hasTranslation = word.translationEn != null && word.translationEn!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Meaning / অর্থ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (hasTranslation) ...[
            // English Translation
            _buildTranslationCard(
              translation: word.translationEn!,
              language: 'English',
              flag: '🇬🇧',
              isPrimary: true,
            ),

            // Bengali Translation
            const SizedBox(height: 10),
            if (_isLoadingBengali)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Loading Bengali translation...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              )
            else if (_bengaliTranslation != null)
              _buildTranslationCard(
                translation: _bengaliTranslation!,
                language: 'বাংলা (Bengali)',
                flag: '🇧🇩',
                isPrimary: false,
                isBengali: true,
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🇧🇩', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Bengali translation not available',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Transliteration if available
            if (word.transliteration != null && word.transliteration!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.record_voice_over_rounded,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pronunciation: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.blue.shade300
                            : Colors.blue.shade700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        word.transliteration!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? Colors.blue.shade200
                              : Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ] else
            // No translation available
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Translation not available for this word.\nThis may be a grammatical particle or connector.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.orange.shade300
                            : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard({
    required String translation,
    required String language,
    required String flag,
    required bool isPrimary,
    bool isBengali = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPrimary
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : (isDark
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.green.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            translation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isPrimary ? 20 : 18,
              fontWeight: FontWeight.w600,
              fontFamily: isBengali ? 'NotoSansBengali' : null,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                language,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: isBengali ? 'NotoSansBengali' : null,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildGrammarSection() {
    final grammar = word.grammar!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Grammar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grammar chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Part of Speech
              _buildGrammarChip(
                'Part of Speech',
                grammar.partOfSpeechDisplay,
                grammar.partOfSpeechBengali,
                Icons.category_rounded,
                Colors.blue,
              ),

              // Root Word
              if (grammar.root != null)
                _buildGrammarChip(
                  'Root',
                  grammar.root!,
                  'মূল শব্দ',
                  Icons.account_tree_rounded,
                  Colors.green,
                  isArabic: true,
                ),

              // Lemma
              if (grammar.lemma != null)
                _buildGrammarChip(
                  'Lemma',
                  grammar.lemma!,
                  'শব্দমূল',
                  Icons.text_fields_rounded,
                  Colors.orange,
                  isArabic: true,
                ),

              // Form (for verbs)
              if (grammar.form != null)
                _buildGrammarChip(
                  'Form',
                  grammar.form!,
                  'রূপ',
                  Icons.format_shapes_rounded,
                  Colors.purple,
                ),

              // Gender
              if (grammar.gender != null)
                _buildGrammarChip(
                  'Gender',
                  grammar.gender!,
                  grammar.gender == 'M' ? 'পুংলিঙ্গ' : 'স্ত্রীলিঙ্গ',
                  Icons.wc_rounded,
                  Colors.pink,
                ),

              // Number
              if (grammar.number != null)
                _buildGrammarChip(
                  'Number',
                  _formatNumber(grammar.number!),
                  _formatNumberBn(grammar.number!),
                  Icons.format_list_numbered_rounded,
                  Colors.teal,
                ),

              // Person
              if (grammar.person != null)
                _buildGrammarChip(
                  'Person',
                  _formatPerson(grammar.person!),
                  _formatPersonBn(grammar.person!),
                  Icons.person_rounded,
                  Colors.indigo,
                ),

              // Voice
              if (grammar.voice != null)
                _buildGrammarChip(
                  'Voice',
                  grammar.voice!,
                  grammar.voice == 'ACT' ? 'কর্তৃবাচ্য' : 'কর্মবাচ্য',
                  Icons.record_voice_over_rounded,
                  Colors.cyan,
                ),

              // Mood
              if (grammar.mood != null)
                _buildGrammarChip(
                  'Mood',
                  _formatMood(grammar.mood!),
                  _formatMoodBn(grammar.mood!),
                  Icons.mood_rounded,
                  Colors.amber,
                ),

              // State
              if (grammar.state != null)
                _buildGrammarChip(
                  'State',
                  grammar.state!,
                  _formatStateBn(grammar.state!),
                  Icons.layers_rounded,
                  Colors.brown,
                ),

              // Case
              if (grammar.case_ != null)
                _buildGrammarChip(
                  'Case',
                  _formatCase(grammar.case_!),
                  _formatCaseBn(grammar.case_!),
                  Icons.cases_rounded,
                  Colors.deepOrange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarChip(
    String label,
    String value,
    String bengaliValue,
    IconData icon,
    Color color, {
    bool isArabic = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: isArabic ? 18 : 14,
              fontWeight: FontWeight.w600,
              fontFamily: isArabic ? 'Scheherazade' : null,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          Text(
            bengaliValue,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for formatting grammar values
  String _formatNumber(String number) {
    switch (number.toUpperCase()) {
      case 'S':
        return 'Singular';
      case 'D':
        return 'Dual';
      case 'P':
        return 'Plural';
      default:
        return number;
    }
  }

  String _formatNumberBn(String number) {
    switch (number.toUpperCase()) {
      case 'S':
        return 'একবচন';
      case 'D':
        return 'দ্বিবচন';
      case 'P':
        return 'বহুবচন';
      default:
        return number;
    }
  }

  String _formatPerson(String person) {
    switch (person.toUpperCase()) {
      case '1':
        return 'First Person';
      case '2':
        return 'Second Person';
      case '3':
        return 'Third Person';
      default:
        return person;
    }
  }

  String _formatPersonBn(String person) {
    switch (person.toUpperCase()) {
      case '1':
        return 'প্রথম পুরুষ';
      case '2':
        return 'মধ্যম পুরুষ';
      case '3':
        return 'উত্তম পুরুষ';
      default:
        return person;
    }
  }

  String _formatMood(String mood) {
    switch (mood.toUpperCase()) {
      case 'IND':
        return 'Indicative';
      case 'SUBJ':
        return 'Subjunctive';
      case 'JUS':
        return 'Jussive';
      case 'IMPV':
        return 'Imperative';
      default:
        return mood;
    }
  }

  String _formatMoodBn(String mood) {
    switch (mood.toUpperCase()) {
      case 'IND':
        return 'নির্দেশক';
      case 'SUBJ':
        return 'সন্দেহবাচক';
      case 'JUS':
        return 'আদেশাত্মক';
      case 'IMPV':
        return 'আদেশসূচক';
      default:
        return mood;
    }
  }

  String _formatCase(String caseValue) {
    switch (caseValue.toUpperCase()) {
      case 'NOM':
        return 'Nominative';
      case 'ACC':
        return 'Accusative';
      case 'GEN':
        return 'Genitive';
      default:
        return caseValue;
    }
  }

  String _formatCaseBn(String caseValue) {
    switch (caseValue.toUpperCase()) {
      case 'NOM':
        return 'কর্তৃকারক';
      case 'ACC':
        return 'কর্মকারক';
      case 'GEN':
        return 'সম্বন্ধ পদ';
      default:
        return caseValue;
    }
  }

  String _formatStateBn(String state) {
    switch (state.toUpperCase()) {
      case 'DEF':
        return 'নির্দিষ্ট';
      case 'INDEF':
        return 'অনির্দিষ্ট';
      default:
        return state;
    }
  }
}

/// Show the word details sheet
void showWordDetailsSheet({
  required BuildContext context,
  required QuranWord word,
  required String verseKey,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  HapticService().lightImpact();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => WordDetailsSheet(
      word: word,
      verseKey: verseKey,
      isDark: isDark,
      theme: theme,
    ),
  );
}
