import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/data/quran_topics_data.dart';
import '../../../core/models/quran_topic.dart';

class QuranTopicsPage extends StatefulWidget {
  const QuranTopicsPage({super.key});

  @override
  State<QuranTopicsPage> createState() => _QuranTopicsPageState();
}

class _QuranTopicsPageState extends State<QuranTopicsPage>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late TabController _tabController;

  String _searchQuery = '';
  bool _showScrollToTop = false;
  int _currentTabIndex = 0;

  final List<String> _tabs = ['Topics', 'Sajdah', 'Word Stats'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
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
    _tabController.dispose();
    super.dispose();
  }

  List<QuranTopic> get _filteredTopics {
    if (_searchQuery.isEmpty) return QuranTopicsData.topics;
    final query = _searchQuery.toLowerCase();
    return QuranTopicsData.topics.where((topic) {
      return topic.nameBengali.toLowerCase().contains(query) ||
          topic.nameEnglish.toLowerCase().contains(query) ||
          topic.nameArabic.contains(query);
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 900 : double.infinity,
            ),
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // Header
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
                // Tab Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                    child: _buildTabBar(theme, isDark),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildTopicsTab(theme, isDark, horizontalPadding),
                  _buildSajdahTab(theme, isDark, horizontalPadding),
                  _buildWordStatsTab(theme, isDark, horizontalPadding),
                ],
              ),
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
                  Icons.category_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'বিষয়ভিত্তিক আয়াত',
            style: TextStyle(
              fontFamily: 'Hind Siliguri',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Topic-Based Quran Verses',
            style: AppTypography.heading3(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Browse Quran verses organized by themes and topics',
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
                hintText: 'Search topics...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
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

  Widget _buildTabBar(ThemeData theme, bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: _currentTabIndex == 0
              ? theme.colorScheme.primary
              : _currentTabIndex == 1
                  ? AppColors.forestGreen
                  : AppColors.mutedTeal,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildTopicsTab(ThemeData theme, bool isDark, double padding) {
    final topics = _filteredTopics;

    if (topics.isEmpty) {
      return _buildEmptyState(isDark, 'No topics found');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      itemCount: topics.length + 1,
      itemBuilder: (context, index) {
        if (index == topics.length) {
          return const SizedBox(height: 100);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTopicCard(topics[index], theme, isDark),
        );
      },
    );
  }

  Widget _buildTopicCard(QuranTopic topic, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        Navigator.pushNamed(
          context,
          '/topic-verses',
          arguments: topic,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    topic.color,
                    topic.color.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: topic.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                topic.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Topic Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.nameBengali,
                    style: TextStyle(
                      fontFamily: 'Hind Siliguri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic.nameEnglish,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        '${topic.categories.length} Categories',
                        topic.color,
                        isDark,
                      ),
                      _buildInfoChip(
                        '${topic.totalVerses}+ Verses',
                        isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                        isDark,
                        isOutlined: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arabic Name & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  topic.nameArabic,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    color: topic.color,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: topic.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: topic.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSajdahTab(ThemeData theme, bool isDark, double padding) {
    final sajdahVerses = QuranTopicsData.sajdahVerses;

    return CustomScrollView(
      slivers: [
        // Info Card
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 16),
            child: _buildSajdahInfoCard(theme, isDark),
          ),
        ),
        // Sajdah List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == sajdahVerses.length) {
                return const SizedBox(height: 100);
              }
              return Padding(
                padding: EdgeInsets.fromLTRB(padding, 0, padding, 12),
                child: _buildSajdahCard(sajdahVerses[index], theme, isDark),
              );
            },
            childCount: sajdahVerses.length + 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSajdahInfoCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.airline_seat_flat_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'সেজদার আয়াত (তেলাওয়াতে সেজদা)',
                  style: TextStyle(
                    fontFamily: 'Hind Siliguri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'কুরআনে এমন ১৪টি আয়াত আছে যেগুলো পড়লে বা শুনলে সেজদা দেওয়া ওয়াজিব হয়ে যায়।',
            style: TextStyle(
              fontFamily: 'Hind Siliguri',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '14 Prostration Verses',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSajdahCard(SajdahVerse sajdah, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        Navigator.pushNamed(
          context,
          '/quran-reader',
          arguments: {'surahNumber': sajdah.surahNumber, 'ayahNumber': sajdah.ayahNumber},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Number Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.forestGreen, AppColors.forestGreen.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${sajdah.number}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sajdah.nameBengali,
                    style: TextStyle(
                      fontFamily: 'Hind Siliguri',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sajdah.juzNumber} পারার ${sajdah.surahNameBengali} - ${sajdah.ayahNumber}',
                    style: TextStyle(
                      fontFamily: 'Hind Siliguri',
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arabic & Go
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  sajdah.surahNameArabic,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: AppColors.forestGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sajdah.surahNumber}:${sajdah.ayahNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordStatsTab(ThemeData theme, bool isDark, double padding) {
    final wordStats = QuranTopicsData.wordStats;

    return CustomScrollView(
      slivers: [
        // Header Info
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 16),
            child: _buildWordStatsHeader(theme, isDark),
          ),
        ),
        // Word Stats Grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= wordStats.length) return null;
                return _buildWordStatCard(wordStats[index], isDark);
              },
              childCount: wordStats.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildWordStatsHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.mutedTeal, AppColors.mutedTeal.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedTeal.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'কোরআনে কোন শব্দটি কতবার এসেছে',
                  style: TextStyle(
                    fontFamily: 'Hind Siliguri',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Word Frequency Statistics in the Holy Quran',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordStatCard(QuranWordStat stat, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.wordBengali,
                  style: TextStyle(
                    fontFamily: 'Hind Siliguri',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stat.count}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stat.wordArabic,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
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
            ? Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider)
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

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
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
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
