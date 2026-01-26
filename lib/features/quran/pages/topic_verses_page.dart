import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/models/quran_topic.dart';
import '../../../core/models/surah.dart';

class TopicVersesPage extends StatefulWidget {
  final QuranTopic topic;

  const TopicVersesPage({super.key, required this.topic});

  @override
  State<TopicVersesPage> createState() => _TopicVersesPageState();
}

class _TopicVersesPageState extends State<TopicVersesPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _showScrollToTop = false;
  int? _expandedCategoryIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    HapticService().lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  String _getSurahNameBengali(int surahNumber) {
    if (surahNumber > 0 && surahNumber <= SurahData.surahs.length) {
      return SurahData.surahs[surahNumber - 1].nameBengali;
    }
    return 'সূরা $surahNumber';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 900 : double.infinity,
            ),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(theme, isDark, horizontalPadding),
                ),
                // Topic Info Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 20),
                    child: _buildTopicInfoCard(theme, isDark),
                  ),
                ),
                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
                    child: Text(
                      'Categories (${widget.topic.categories.length})',
                      style: AppTypography.heading3(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                // Category List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= widget.topic.categories.length) {
                        return const SizedBox(height: 100);
                      }
                      return Padding(
                        padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
                        child: _buildCategoryCard(
                          widget.topic.categories[index],
                          index,
                          theme,
                          isDark,
                        ),
                      );
                    },
                    childCount: widget.topic.categories.length + 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              backgroundColor: widget.topic.color,
              child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, double padding) {
    return Container(
      padding: EdgeInsets.fromLTRB(padding, 16, padding, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticService().lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black12 : AppColors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.topic.color,
                      widget.topic.color.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: widget.topic.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.topic.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            widget.topic.nameBengali,
            style: TextStyle(
              fontFamily: 'Hind Siliguri',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.topic.nameEnglish,
            style: AppTypography.heading3(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicInfoCard(ThemeData theme, bool isDark) {
    final totalVerses = widget.topic.categories.fold<int>(
      0,
      (sum, cat) => sum + cat.verses.fold<int>(0, (s, v) => s + v.verseCount),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.topic.color,
            widget.topic.color.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.topic.color.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic Name
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.topic.nameArabic,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 32,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            widget.topic.descriptionBengali,
            style: TextStyle(
              fontFamily: 'Hind Siliguri',
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.topic.descriptionEnglish,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            children: [
              _buildStatBadge(
                Icons.category_rounded,
                '${widget.topic.categories.length}',
                'Categories',
              ),
              const SizedBox(width: 12),
              _buildStatBadge(
                Icons.format_list_numbered_rounded,
                '$totalVerses+',
                'Verses',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    QuranTopicCategory category,
    int index,
    ThemeData theme,
    bool isDark,
  ) {
    final isExpanded = _expandedCategoryIndex == index;
    final verseCount = category.verses.fold<int>(0, (sum, v) => sum + v.verseCount);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.25),
            blurRadius: isExpanded ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isExpanded
            ? Border.all(color: widget.topic.color.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Column(
        children: [
          // Header (always visible)
          GestureDetector(
            onTap: () {
              HapticService().lightImpact();
              setState(() {
                _expandedCategoryIndex = isExpanded ? null : index;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Number Badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.topic.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.topic.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Category Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.nameBengali,
                          style: TextStyle(
                            fontFamily: 'Hind Siliguri',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.format_list_numbered_rounded,
                              size: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$verseCount verses',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.bookmark_border_rounded,
                              size: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${category.verses.length} refs',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expand Icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? widget.topic.color
                            : widget.topic.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isExpanded ? Colors.white : widget.topic.color,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(category, isDark),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(QuranTopicCategory category, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // English Translation
          if (category.nameEnglish.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                category.nameEnglish,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),
          // Verse References
          Text(
            'আয়াত সমূহ:',
            style: TextStyle(
              fontFamily: 'Hind Siliguri',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: category.verses.map((verse) {
              return _buildVerseChip(verse, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseChip(VerseReference verse, bool isDark) {
    final surahName = _getSurahNameBengali(verse.surahNumber);

    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        Navigator.pushNamed(
          context,
          '/quran-reader',
          arguments: {'surahNumber': verse.surahNumber, 'ayahNumber': verse.startAyah},
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.topic.color.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.topic.color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 14,
              color: widget.topic.color,
            ),
            const SizedBox(width: 6),
            Text(
              '$surahName: ${verse.displayReference.split(':').last}',
              style: TextStyle(
                fontFamily: 'Hind Siliguri',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.topic.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
