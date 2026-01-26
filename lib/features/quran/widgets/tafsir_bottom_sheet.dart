import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/ayah.dart';
import '../../../core/models/surah.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/tafsir_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/providers/app_state_provider.dart';

import 'package:provider/provider.dart';

/// Premium bottom sheet showing Tafsir (interpretation) and Shani Nuzul (context of revelation)
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
        initialChildSize: 0.75,
        minChildSize: 0.5,
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
    setState(() => _isLoading = true);

    final tafsir = await _tafsirService.fetchTafsir(
      widget.surah.number,
      widget.ayah.numberInSurah,
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
    final fontFamily = context.select<AppStateProvider, String>(
        (s) => s.arabicFontStyle.fontFamily);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary)
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Premium Header
          _buildPremiumHeader(isDark, theme, fontFamily),

          // Tab bar
          _buildPremiumTabBar(isDark, theme),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTafsirTab(isDark, theme),
                _buildShaniNuzulTab(isDark, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(bool isDark, ThemeData theme, String? fontFamily) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          // Top row with close button
          Row(
            children: [
              // Ayah badge with ornamental design
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _toArabicNumerals(widget.ayah.numberInSurah),
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        'آية',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.surah.nameArabic,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.surah.nameTransliteration} • Ayah ${widget.ayah.numberInSurah}',
                      style: TextStyle(
                      fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              _buildIconButton(
                icon: Icons.copy_rounded,
                onTap: () => _copyContent(),
                isDark: isDark,
                tooltip: 'Copy',
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
                isDark: isDark,
                tooltip: 'Close',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Arabic ayah text in ornamental card
          _buildArabicAyahCard(isDark, theme, fontFamily),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticService().selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.cream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArabicAyahCard(bool isDark, ThemeData theme, String? fontFamily) {
    final ornamentColor = isDark
        ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
        : const Color(0xFFB8860B).withValues(alpha: 0.3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ornamentColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Decorative top element
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 30, height: 1, color: ornamentColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '۞',
                  style: TextStyle(fontSize: 14, color: ornamentColor),
                ),
              ),
              Container(width: 30, height: 1, color: ornamentColor),
            ],
          ),
          const SizedBox(height: 12),
          // Arabic text
          Text(
            widget.ayah.textArabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: AppTypography.quranText(
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A),
              fontSize: 26,
              height: 2.0,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 12),
          // Decorative bottom element
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 30, height: 1, color: ornamentColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '۞',
                  style: TextStyle(fontSize: 14, color: ornamentColor),
                ),
              ),
              Container(width: 30, height: 1, color: ornamentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTabBar(bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.cream.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book_rounded, size: 16),
                const SizedBox(width: 6),
                const Text('তাফসীর'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_edu_rounded, size: 16),
                const SizedBox(width: 6),
                const Text('শানে নুযূল'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTafsirTab(bool isDark, ThemeData theme) {
    final hasEnglishTafsir = widget.ayah.tafsir != null && widget.ayah.tafsir!.isNotEmpty;
    final hasBengaliTafsir = (widget.ayah.tafsirBengali != null && widget.ayah.tafsirBengali!.isNotEmpty) ||
        (_apiTafsir != null && _apiTafsir!.isNotEmpty);
    final hasTafsir = hasEnglishTafsir || hasBengaliTafsir;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guide card
          _buildGuideCard(
            isDark: isDark,
            theme: theme,
            icon: Icons.lightbulb_outline_rounded,
            title: 'What is Tafsir?',
            titleBengali: 'তাফসীর কী?',
            description: 'Tafsir is the scholarly interpretation and explanation of the Quran, helping understand the deeper meaning of each verse.',
            descriptionBengali: 'তাফসীর হলো কুরআনের পণ্ডিত ব্যাখ্যা ও বিশ্লেষণ, যা প্রতিটি আয়াতের গভীর অর্থ বুঝতে সাহায্য করে।',
          ),

          const SizedBox(height: 20),

          // Tafsir Section
          _buildSectionHeader(
            isDark: isDark,
            theme: theme,
            icon: Icons.menu_book_rounded,
            title: 'Tafsir Ibn Kathir',
            titleBengali: 'তাফসীর ইবনে কাসীর',
          ),

          const SizedBox(height: 12),

          // Tafsir content
          if (_isLoading)
            _buildLoadingState(isDark)
          else if (hasTafsir)
            _buildTafsirContent(isDark, theme, hasBengaliTafsir, hasEnglishTafsir)
          else
            _buildNoContentCard(
              isDark: isDark,
              theme: theme,
              icon: Icons.auto_stories_rounded,
              title: 'Tafsir Coming Soon',
              titleBengali: 'তাফসীর শীঘ্রই আসছে',
              message: 'Detailed interpretation for this ayah will be added soon.',
              messageBengali: 'এই আয়াতের বিস্তারিত ব্যাখ্যা শীঘ্রই যোগ করা হবে।',
            ),

          const SizedBox(height: 24),

          // Translation Section
          _buildSectionHeader(
            isDark: isDark,
            theme: theme,
            icon: Icons.translate_rounded,
            title: 'Translation',
            titleBengali: 'অনুবাদ',
          ),

          const SizedBox(height: 12),

          // Translations
          if (widget.ayah.translationBengali != null)
            _buildTranslationCard(
              isDark: isDark,
              theme: theme,
              language: 'বাংলা',
              languageIcon: '🇧🇩',
              text: widget.ayah.translationBengali!,
              isBengali: true,
            ),

          if (widget.ayah.translationBengali != null && widget.ayah.translationEnglish != null)
            const SizedBox(height: 12),

          if (widget.ayah.translationEnglish != null)
            _buildTranslationCard(
              isDark: isDark,
              theme: theme,
              language: 'English',
              languageIcon: '🇬🇧',
              text: widget.ayah.translationEnglish!,
              isBengali: false,
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildShaniNuzulTab(bool isDark, ThemeData theme) {
    final hasEnglishShaniNuzul = widget.ayah.shaniNuzul != null && widget.ayah.shaniNuzul!.isNotEmpty;
    final hasBengaliShaniNuzul = widget.ayah.shaniNuzulBengali != null && widget.ayah.shaniNuzulBengali!.isNotEmpty;
    final hasShaniNuzul = hasEnglishShaniNuzul || hasBengaliShaniNuzul;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guide card
          _buildGuideCard(
            isDark: isDark,
            theme: theme,
            icon: Icons.history_rounded,
            title: 'What is Shan-e-Nuzul?',
            titleBengali: 'শানে নুযূল কী?',
            description: 'Shan-e-Nuzul describes the historical context and circumstances under which a verse was revealed, helping understand its specific meaning.',
            descriptionBengali: 'শানে নুযূল হলো কোন আয়াত কোন প্রেক্ষাপটে এবং কোন ঘটনার পরিপ্রেক্ষিতে নাযিল হয়েছিল তার বর্ণনা, যা আয়াতের নির্দিষ্ট অর্থ বুঝতে সাহায্য করে।',
          ),

          const SizedBox(height: 20),

          // Revelation Context Section
          _buildSectionHeader(
            isDark: isDark,
            theme: theme,
            icon: Icons.history_edu_rounded,
            title: 'Context of Revelation',
            titleBengali: 'নাযিলের প্রেক্ষাপট',
          ),

          const SizedBox(height: 12),

          // Content
          if (_isLoading)
            _buildLoadingState(isDark)
          else if (hasShaniNuzul)
            _buildShaniNuzulContent(isDark, theme, hasBengaliShaniNuzul, hasEnglishShaniNuzul)
          else
            _buildNoContentCard(
              isDark: isDark,
              theme: theme,
              icon: Icons.history_toggle_off_rounded,
              title: 'Context Coming Soon',
              titleBengali: 'প্রেক্ষাপট শীঘ্রই আসছে',
              message: 'The historical context of this revelation will be added soon.',
              messageBengali: 'এই আয়াত নাযিলের ঐতিহাসিক প্রেক্ষাপট শীঘ্রই যোগ করা হবে।',
            ),

          const SizedBox(height: 24),

          // Surah Info Section
          _buildSurahInfoCard(isDark, theme),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildGuideCard({
    required bool isDark,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String titleBengali,
    required String description,
    required String descriptionBengali,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$titleBengali / $title',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descriptionBengali,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'NotoSansBengali',
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                        : AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required bool isDark,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String titleBengali,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleBengali,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansBengali',
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.cream.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTafsirContent(bool isDark, ThemeData theme, bool hasBengali, bool hasEnglish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ibn Kathir',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bengali Tafsir
          if (widget.ayah.tafsirBengali != null && widget.ayah.tafsirBengali!.isNotEmpty)
            Text(
              widget.ayah.tafsirBengali!,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'NotoSansBengali',
                height: 1.8,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            )
          else if (_apiTafsir != null && _apiTafsir!.isNotEmpty)
            Text(
              _apiTafsir!,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'NotoSansBengali',
                height: 1.8,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),

          // English Tafsir (if Bengali is missing)
          if (hasEnglish && !hasBengali) ...[
            const SizedBox(height: 12),
            Text(
              widget.ayah.tafsir!,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShaniNuzulContent(bool isDark, ThemeData theme, bool hasBengali, bool hasEnglish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 2,
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Historical Context',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bengali Shani Nuzul
          if (hasBengali)
            Text(
              widget.ayah.shaniNuzulBengali!,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'NotoSansBengali',
                height: 1.8,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),

          if (hasBengali && hasEnglish)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
            ),

          // English Shani Nuzul
          if (hasEnglish)
            Text(
              widget.ayah.shaniNuzul!,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: hasBengali
                    ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard({
    required bool isDark,
    required ThemeData theme,
    required String language,
    required String languageIcon,
    required String text,
    required bool isBengali,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.cream.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(languageIcon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                language,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: isBengali ? 15 : 14,
              fontFamily: isBengali ? 'NotoSansBengali' : null,
              height: 1.7,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahInfoCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurface,
                  AppColors.darkCard,
                ]
              : [
                  Colors.white,
                  AppColors.cream.withValues(alpha: 0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'About ${widget.surah.nameTransliteration}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  isDark: isDark,
                  theme: theme,
                  icon: Icons.tag_rounded,
                  label: 'Surah',
                  value: widget.surah.number.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  isDark: isDark,
                  theme: theme,
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Ayahs',
                  value: widget.surah.ayahCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  isDark: isDark,
                  theme: theme,
                  icon: Icons.location_on_outlined,
                  label: 'Revelation',
                  value: widget.surah.revelationType,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  isDark: isDark,
                  theme: theme,
                  icon: Icons.layers_outlined,
                  label: 'Juz',
                  value: widget.ayah.juz.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required bool isDark,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withValues(alpha: 0.5)
            : theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentCard({
    required bool isDark,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String titleBengali,
    required String message,
    required String messageBengali,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.cream.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            titleBengali,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'NotoSansBengali',
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            messageBengali,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'NotoSansBengali',
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _copyContent() {
    HapticService().mediumImpact();

    final shareText = '''
${widget.surah.nameTransliteration} (${widget.surah.nameArabic})
Ayah ${widget.ayah.numberInSurah}

${widget.ayah.textArabic}

${widget.ayah.translationBengali ?? ''}

${widget.ayah.translationEnglish ?? ''}
'''.trim();

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text('Copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _toArabicNumerals(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? arabicNumerals[index] : digit;
    }).join();
  }
}
