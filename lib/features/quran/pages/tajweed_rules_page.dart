import 'package:flutter/material.dart';
import '../../../core/models/tajweed_rules_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/tajweed_rule_card.dart';

// ArabicLetter and ArabicAlphabetData are imported from tajweed_rules_data.dart

/// Page displaying comprehensive Tajweed rules guide
class TajweedRulesPage extends StatelessWidget {
  const TajweedRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkCard : AppColors.forestGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'তাজবীদের নিয়মাবলী',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.darkCard,
                            AppColors.darkCard.withOpacity(0.8),
                          ]
                        : [
                            AppColors.forestGreen,
                            AppColors.forestGreen.withOpacity(0.8),
                          ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          // Introduction
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.softRose.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: isDark ? AppColors.softRose : AppColors.forestGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'তাজবীদ সম্পর্কে',
                          style: AppTypography.heading2(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'তাজবীদ হলো কুরআন সঠিকভাবে পড়ার নিয়ম। প্রতিটি রঙ একটি বিশেষ উচ্চারণ নিয়ম নির্দেশ করে। নিচের নিয়মগুলো শিখে আপনি কুরআন সুন্দর ও শুদ্ধভাবে পড়তে পারবেন।',
                    style: AppTypography.bodyLarge(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tajweed is the set of rules for proper Quranic recitation. Each color represents a specific pronunciation rule. Learn these rules to recite the Quran beautifully and correctly.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary.withOpacity(0.7)
                          : AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.softRose : AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'সকল তাজবীদ নিয়ম',
                    style: AppTypography.heading3(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rules list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final rule = TajweedRulesData.allRules[index];
                return TajweedRuleCard(
                  rule: rule,
                  initiallyExpanded: index == 0, // First card expanded by default
                );
              },
              childCount: TajweedRulesData.allRules.length,
            ),
          ),

          // Arabic Alphabet Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.softRose : AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আরবি বর্ণমালা ও মাখরাজ',
                          style: AppTypography.heading3(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Arabic Alphabet & Articulation Points',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Arabic Alphabet description
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : AppColors.cardShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'মাখরাজ হলো আরবি হরফ উচ্চারণের স্থান। প্রতিটি হরফ সঠিক জায়গা থেকে উচ্চারণ করা কুরআন তিলাওয়াতের জন্য অত্যন্ত গুরুত্বপূর্ণ।',
                style: AppTypography.bodyLarge(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Arabic Alphabet Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final letter = ArabicAlphabetData.allLetters[index];
                  return _ArabicLetterCard(letter: letter, isDark: isDark);
                },
                childCount: ArabicAlphabetData.allLetters.length,
              ),
            ),
          ),

          // Waqf Signs Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.softRose : AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ওয়াকফের চিহ্ন (বিরতির চিহ্ন)',
                          style: AppTypography.heading3(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Waqf Signs (Stopping Marks)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Waqf description
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : AppColors.cardShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'ওয়াকুফ অর্থ থামা বা বিলম্ব করা। তিলাওয়াতকালে নিঃশ্বাস ত্যাগ করে পুনরায় শ্বাস নেওয়ার জন্য যে বিরতি নেয়া হয় তাকে ওয়াকুফ বলে।',
                style: AppTypography.bodyLarge(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Waqf Signs List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final sign = WaqfSignsData.allSigns[index];
                return _WaqfSignCard(sign: sign, isDark: isDark, index: index + 1);
              },
              childCount: WaqfSignsData.allSigns.length,
            ),
          ),

          // Translation Color Info Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.softRose : AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'অনুবাদে রঙের ব্যবহার',
                          style: AppTypography.heading3(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Color Coding in Translation',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Translation Colors List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final colorInfo = TranslationColorsData.allColors[index];
                return _TranslationColorCard(colorInfo: colorInfo, isDark: isDark);
              },
              childCount: TranslationColorsData.allColors.length,
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),

      // Floating action button to view original guide image
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGuideImage(context),
        backgroundColor: isDark ? AppColors.softRose : AppColors.forestGreen,
        icon: const Icon(Icons.image_rounded, color: Colors.white),
        label: const Text(
          'মূল গাইড',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showGuideImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Image
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/tajweed_rules_guide.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying an Arabic letter with its Makhraj
class _ArabicLetterCard extends StatelessWidget {
  final ArabicLetter letter;
  final bool isDark;

  const _ArabicLetterCard({
    required this.letter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showLetterDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Arabic Letter
                Text(
                  letter.letter,
                  style: TextStyle(
                    fontSize: 42,
                    fontFamily: 'Amiri',
                    color: isDark ? AppColors.softRose : AppColors.forestGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Bengali Name
                Text(
                  letter.nameBengali,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                // Pronunciation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.softRose.withValues(alpha: 0.2)
                        : AppColors.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    letter.pronunciationBengali,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.softRose : AppColors.forestGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLetterDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Arabic Letter
            Text(
              letter.letter,
              style: TextStyle(
                fontSize: 72,
                fontFamily: 'Amiri',
                color: isDark ? AppColors.softRose : AppColors.forestGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Bengali Name and Pronunciation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  letter.nameBengali,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.softRose.withOpacity(0.2)
                        : AppColors.forestGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    letter.pronunciationBengali,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.softRose : AppColors.forestGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Makhraj section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        size: 20,
                        color: isDark ? AppColors.softRose : AppColors.forestGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'মাখরাজ (উচ্চারণ স্থান)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.softRose : AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    letter.makhrajBengali,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a Waqf sign
class _WaqfSignCard extends StatelessWidget {
  final WaqfSign sign;
  final bool isDark;
  final int index;

  const _WaqfSignCard({
    required this.sign,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on stop type
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (sign.mustStop) {
      statusColor = Colors.red;
      statusText = 'অবশ্যই থামতে হবে';
      statusIcon = Icons.stop_circle_rounded;
    } else if (sign.mustNotStop) {
      statusColor = Colors.orange;
      statusText = 'থামা যাবে না';
      statusIcon = Icons.not_interested_rounded;
    } else if (sign.preferredStop) {
      statusColor = Colors.green;
      statusText = 'থামা উত্তম';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = Colors.blue;
      statusText = 'ঐচ্ছিক';
      statusIcon = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showSignDetail(context, statusColor, statusText, statusIcon),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Index number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.softRose.withValues(alpha: 0.2)
                        : AppColors.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.softRose : AppColors.forestGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Symbol
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      sign.symbol,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Amiri',
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sign.nameBengali,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sign.nameEnglish,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignDetail(
    BuildContext context,
    Color statusColor,
    String statusText,
    IconData statusIcon,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Symbol
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  sign.symbol,
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'Amiri',
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Names
            Text(
              sign.nameBengali,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sign.nameArabic,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Amiri',
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                sign.descriptionBengali,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying translation color info
class _TranslationColorCard extends StatelessWidget {
  final TranslationColorInfo colorInfo;
  final bool isDark;

  const _TranslationColorCard({
    required this.colorInfo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorInfo.color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colorInfo.nameBengali,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorInfo.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    colorInfo.descriptionBengali,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
