import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/ayah.dart';
import '../../../core/models/surah.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/tafsir_service.dart';

/// Bottom sheet showing Tafsir (interpretation) and Shani Nuzul (context of revelation)
class TafsirBottomSheet extends StatefulWidget {
  final Ayah ayah;
  final Surah surah;

  const TafsirBottomSheet({
    super.key,
    required this.ayah,
    required this.surah,
  });

  /// Show the Tafsir bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Ayah ayah,
    required Surah surah,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => TafsirBottomSheet(
          ayah: ayah,
          surah: surah,
        ),
      ),
    );
  }

  @override
  State<TafsirBottomSheet> createState() => _TafsirBottomSheetState();
}

class _TafsirBottomSheetState extends State<TafsirBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TafsirService _tafsirService = TafsirService();
  bool _isLoading = false;
  String? _apiTafsir;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch tafsir if Bengali tafsir is missing locally
    if (widget.ayah.tafsirBengali == null || widget.ayah.tafsirBengali!.isEmpty) {
      _fetchTafsir();
    }
  }

  Future<void> _fetchTafsir() async {
    setState(() {
      _isLoading = true;
    });

    final tafsir = await _tafsirService.fetchTafsir(
      widget.surah.number, 
      widget.ayah.numberInSurah
    );

    if (mounted) {
      setState(() {
        _apiTafsir = tafsir;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with ayah reference
          _buildHeader(isDark),

          // Tab bar
          _buildTabBar(isDark),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTafsirTab(isDark),
                _buildShaniNuzulTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // Ayah number badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.ayah.numberInSurah.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Surah and ayah info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.surah.nameTransliteration,
                  style: AppTypography.heading3(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Surah ${widget.surah.number}, Ayah ${widget.ayah.numberInSurah}',
                  style: AppTypography.bodySmall(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Share button
          IconButton(
            onPressed: () => _shareContent(),
            icon: Icon(
              Icons.share_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),

          // Close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Tafsir'),
          Tab(text: 'Shani Nuzul'),
        ],
      ),
    );
  }

  Widget _buildTafsirTab(bool isDark) {
    // Check for content availability
    final hasEnglishTafsir = widget.ayah.tafsir != null && widget.ayah.tafsir!.isNotEmpty;
    final hasBengaliTafsir = (widget.ayah.tafsirBengali != null && widget.ayah.tafsirBengali!.isNotEmpty) || (_apiTafsir != null && _apiTafsir!.isNotEmpty);
    final hasTafsir = hasEnglishTafsir || hasBengaliTafsir;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic text of ayah
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.ayah.textArabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppTypography.quranText(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 24,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tafsir title
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'তাফসীর / Tafsir',
                style: AppTypography.heading4(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tafsir content
           if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (hasTafsir) ...[
            if (widget.ayah.tafsirBengali != null && widget.ayah.tafsirBengali!.isNotEmpty)
              Text(
                widget.ayah.tafsirBengali!,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              )
            else if (_apiTafsir != null)
               Text(
                _apiTafsir!,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            
            if (hasBengaliTafsir && hasEnglishTafsir)
              const SizedBox(height: 16),
              
             if (hasEnglishTafsir && (!hasBengaliTafsir)) // Show English if Bengali is missing
              Text(
                widget.ayah.tafsir!,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: hasBengaliTafsir 
                      ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
              ),
          ] else
            _buildNoContentMessage(
              isDark,
              'Tafsir not available',
              'Detailed interpretation for this ayah will be added soon.',
            ),

          const SizedBox(height: 32),

          // Translation
          Text(
            'অনুবাদ / Translation',
            style: AppTypography.heading4(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Bengali translation (Prioritize Bengali)
          if (widget.ayah.translationBengali != null) ...[
            _buildTranslationSection(
              isDark,
              'বাংলা',
              widget.ayah.translationBengali!,
            ),
            const SizedBox(height: 16),
          ],

          // English translation
          if (widget.ayah.translationEnglish != null)
            _buildTranslationSection(
              isDark,
              'English',
              widget.ayah.translationEnglish!,
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildShaniNuzulTab(bool isDark) {
    final hasEnglishShaniNuzul = widget.ayah.shaniNuzul != null && widget.ayah.shaniNuzul!.isNotEmpty;
    final hasBengaliShaniNuzul = widget.ayah.shaniNuzulBengali != null && widget.ayah.shaniNuzulBengali!.isNotEmpty;
    // Use API Tafsir as fallback since it usually contains the context
    final hasShaniNuzul = hasEnglishShaniNuzul || hasBengaliShaniNuzul || (_apiTafsir != null && _apiTafsir!.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.history_edu_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'শানে নুযূল / Context',
                style: AppTypography.heading4(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Context of Revelation',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Content
          if (_isLoading)
             const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (hasShaniNuzul)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (hasBengaliShaniNuzul)
                    Text(
                      widget.ayah.shaniNuzulBengali!,
                      style: TextStyle(
                        fontSize: 16, // Slightly larger for Bengali
                        height: 1.7,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    )
                  else if (!hasEnglishShaniNuzul && _apiTafsir != null)
                    // Fallback to API Tafsir content which contains context
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note: Specific context not separated. Displaying full Tafsir which includes context:',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _apiTafsir!,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.7,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                  if (hasBengaliShaniNuzul && hasEnglishShaniNuzul)
                    Divider(height: 24, color: isDark ? Colors.white24 : Colors.black12),
                    
                  if (hasEnglishShaniNuzul)
                    Text(
                      widget.ayah.shaniNuzul!,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: hasBengaliShaniNuzul
                            ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                ],
              ),
            )
          else
            _buildNoContentMessage(
              isDark,
              'Context not available',
              'The historical context of this revelation will be added soon.',
            ),

          const SizedBox(height: 24),

          // Additional info about the surah
          _buildSurahInfo(isDark),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildTranslationSection(bool isDark, String language, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahInfo(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${widget.surah.nameTransliteration}',
            style: AppTypography.heading4(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(isDark, 'Surah Number', widget.surah.number.toString()),
          _buildInfoRow(isDark, 'Total Ayahs', widget.surah.ayahCount.toString()),
          _buildInfoRow(isDark, 'Revelation', widget.surah.revelationType),
          _buildInfoRow(isDark, 'Juz', widget.ayah.juz.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentMessage(bool isDark, String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 32,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _shareContent() {
    final shareText = '''
${widget.surah.nameTransliteration} (${widget.surah.nameArabic})
Ayah ${widget.ayah.numberInSurah}

${widget.ayah.textArabic}

${widget.ayah.translationEnglish ?? ''}

${widget.ayah.tafsir != null ? 'Tafsir: ${widget.ayah.tafsir}' : ''}
''';

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
