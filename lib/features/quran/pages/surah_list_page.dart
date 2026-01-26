import 'package:flutter/material.dart';
import '../../../core/models/surah.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/haptic_service.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state_provider.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late AnimationController _animationController;

  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Meccan, Medinan
  bool _showScrollToTop = false;

  final List<String> _filters = ['All', 'Meccan', 'Medinan'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Surah> get _filteredSurahs {
    return SurahData.surahs.where((surah) {
      // Filter by revelation type
      if (_selectedFilter != 'All' && surah.revelationType != _selectedFilter) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return surah.nameTransliteration.toLowerCase().contains(query) ||
            surah.nameEnglish.toLowerCase().contains(query) ||
            surah.nameArabic.contains(query) ||
            surah.number.toString().contains(query);
      }

      return true;
    }).toList();
  }

  void _scrollToTop() {
    HapticService().lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);
    final filteredSurahs = _filteredSurahs;
    final fontFamily = context.select<AppStateProvider, String>(
        (s) => s.arabicFontStyle.fontFamily);

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
                // Premium Header
                SliverToBoxAdapter(
                  child: _buildHeader(theme, isDark, horizontalPadding),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                    child: _buildSearchBar(isDark),
                  ),
                ),

                // Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
                    child: _buildFilterChips(theme, isDark),
                  ),
                ),

                // Stats Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 16),
                    child: _buildStatsBar(isDark, filteredSurahs),
                  ),
                ),

                // Surah List
                filteredSurahs.isEmpty
                    ? SliverToBoxAdapter(
                        child: _buildEmptyState(isDark),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final surah = filteredSurahs[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: 6,
                              ),
                              child: _buildPremiumSurahTile(
                                surah,
                                theme,
                                isDark,
                                index,
                                fontFamily,
                              ),
                            );
                          },
                          childCount: filteredSurahs.length,
                        ),
                      ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              backgroundColor: theme.colorScheme.primary,
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
          // Back button and title row
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
              // Quran Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'Surah List',
            style: AppTypography.heading1(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Browse all 114 chapters of the Holy Quran',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, number...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticService().lightImpact();
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                HapticService().selectionClick();
                setState(() => _selectedFilter = filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.dividerDark : AppColors.divider),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filter != 'All')
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: 8),
                        child: Image.asset(
                          filter == 'Meccan'
                              ? 'assets/images/meccan.png'
                              : 'assets/images/Madina.png',
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsBar(bool isDark, List<Surah> filteredSurahs) {
    final meccanCount = filteredSurahs.where((s) => s.revelationType == 'Meccan').length;
    final medinanCount = filteredSurahs.where((s) => s.revelationType == 'Medinan').length;
    final totalAyahs = filteredSurahs.fold(0, (sum, s) => sum + s.ayahCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '${filteredSurahs.length}',
            'Surahs',
            Icons.list_rounded,
            isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItemWithImage(
            '$meccanCount',
            'Meccan',
            'assets/images/meccan.png',
            isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItemWithImage(
            '$medinanCount',
            'Medinan',
            'assets/images/Madina.png',
            isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            totalAyahs > 999 ? '${(totalAyahs / 1000).toStringAsFixed(1)}k' : '$totalAyahs',
            'Ayahs',
            Icons.format_list_numbered_rounded,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, bool isDark,
      {Color? iconColor, double iconSize = 14}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.dividerDark : AppColors.divider,
    );
  }

  Widget _buildStatItemWithImage(String value, String label, String imagePath, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          width: 18,
          height: 18,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumSurahTile(Surah surah, ThemeData theme, bool isDark, int index, String? fontFamily) {
    final isMeccan = surah.revelationType == 'Meccan';

    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        Navigator.pushNamed(
          context,
          '/quran-reader',
          arguments: surah.number,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Surah Number Badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMeccan
                      ? [AppColors.forestGreen, AppColors.forestGreen.withValues(alpha: 0.7)]
                      : [AppColors.mutedTeal, AppColors.mutedTeal.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (isMeccan ? AppColors.forestGreen : AppColors.mutedTeal)
                        .withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  surah.number.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Surah Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameTransliteration,
                    style: AppTypography.heading4(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.nameEnglish,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildRevelationChip(
                        isMeccan ? 'Meccan' : 'Medinan',
                        isMeccan ? 'assets/images/meccan.png' : 'assets/images/Madina.png',
                        isMeccan ? AppColors.forestGreen : AppColors.mutedTeal,
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        '${surah.ayahCount} Ayahs',
                        isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                        isDark,
                        isOutlined: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arabic Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                  Text(
                    surah.nameArabic,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.surahNameArabic(
                      fontSize: 24,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, bool isDark, {bool isOutlined = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: isOutlined
            ? Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
                width: 1,
              )
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOutlined
              ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
              : color,
        ),
      ),
    );
  }

  Widget _buildRevelationChip(String text, String imagePath, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 14,
            height: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Surahs Found',
              style: AppTypography.heading3(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or filter',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
