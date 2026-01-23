import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/services/haptic_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().setNavIndex(0);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    HapticService().selectionClick();
    context.read<AppStateProvider>().setNavIndex(index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/quran-reader', arguments: 1);
        break;
      case 2:
        Navigator.pushNamed(context, '/bookmarks');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 20) return 'Good Evening';
    return 'Good Night';
  }

  String _getArabicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صَبَاحُ الْخَيْر';
    if (hour < 17) return 'مَسَاءُ الْخَيْر';
    return 'مَسَاءُ النُّور';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 900 : double.infinity,
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Premium Header
                  SliverToBoxAdapter(
                    child: _buildPremiumHeader(theme, isDark, horizontalPadding),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 20),
                      child: _buildSearchBar(isDark),
                    ),
                  ),

                  // Featured Ayah Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: _buildFeaturedCard(theme, isDark),
                    ),
                  ),

                  // Continue Reading Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 0),
                      child: _buildContinueReading(theme, isDark),
                    ),
                  ),

                  // Quick Actions Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 0),
                      child: _buildSectionHeader('Quick Actions', isDark),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
                      child: _buildQuickActions(theme, isDark),
                    ),
                  ),

                  // Quran & Learning Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 0),
                      child: _buildSectionHeader('Quran & Learning', isDark),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
                      child: _buildQuranSection(theme, isDark),
                    ),
                  ),

                  // Islamic Tools Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 0),
                      child: _buildSectionHeader('Islamic Tools', isDark),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
                      child: _buildIslamicToolsSection(theme, isDark),
                    ),
                  ),

                  // Ramadan Special Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 0),
                      child: _buildSectionHeader('Ramadan Special', isDark),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
                      child: _buildRamadanSection(theme, isDark),
                    ),
                  ),

                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildPremiumBottomNav(context),
    );
  }

  Widget _buildPremiumHeader(ThemeData theme, bool isDark, double padding) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final userName = appState.userName.isNotEmpty ? appState.userName : 'Dear Reader';

        return Container(
          margin: EdgeInsets.fromLTRB(padding, 8, padding, 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.darkCard, AppColors.darkSurface]
                  : [Colors.white, AppColors.cream.withValues(alpha: 0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : AppColors.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // User Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Greeting Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getArabicGreeting(),
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      userName,
                      style: AppTypography.heading2(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                    theme: theme,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    theme: theme,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        onTap();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.darkTextSecondary : theme.colorScheme.primary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        Navigator.pushNamed(context, '/search');
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 1,
          ),
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
              child: Text(
                'Search Quran, Surahs, Duas...',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_command_key,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'K',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
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

  Widget _buildFeaturedCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
            AppColors.mutedTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Verse of the Day',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              color: Colors.white,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Al-Fatiha 1:1',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticService().lightImpact();
                  Navigator.pushNamed(context, '/quran-reader', arguments: 1);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Read More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueReading(ThemeData theme, bool isDark) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final progress = appState.readingProgress;
        final lastSurah = progress.lastSurahNumber;
        final lastAyah = progress.lastAyahNumber;
        final surahName = progress.lastSurahNameEnglish;
        final progressPercent = progress.progressPercentage;

        return ElegantCard(
          onTap: () {
            HapticService().lightImpact();
            Navigator.pushNamed(
              context,
              '/quran-reader',
              arguments: {'surahNumber': lastSurah, 'ayahNumber': lastAyah},
            );
          },
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.forestGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue Reading',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$surahName - Ayah $lastAyah',
                          style: AppTypography.heading4(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quran Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${progressPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercent / 100,
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.forestGreen.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.heading3(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isDark) {
    final actions = [
      _QuickAction(
        icon: Icons.menu_book_rounded,
        label: 'Read\nQuran',
        color: AppColors.forestGreen,
        gradientColors: [const Color(0xFF2D4739), const Color(0xFF4A7C59)],
        route: '/quran-reader',
        arguments: 1,
      ),
      _QuickAction(
        icon: Icons.explore_rounded,
        label: 'Qibla\nDirection',
        color: AppColors.mutedTeal,
        gradientColors: [const Color(0xFF5B8A8A), const Color(0xFF7BA3A8)],
        route: '/qibla',
      ),
      _QuickAction(
        icon: Icons.radio_button_on_rounded,
        label: 'Tasbih\nCounter',
        color: AppColors.softRoseDark,
        gradientColors: [const Color(0xFFB76E79), const Color(0xFFD4A5A5)],
        route: '/tasbih',
      ),
      _QuickAction(
        icon: Icons.calculate_rounded,
        label: 'Zakat\nCalculator',
        color: AppColors.mutedTealDark,
        gradientColors: [const Color(0xFF3D6B6B), const Color(0xFF5B9A9A)],
        route: '/zakat-calculator',
      ),
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _buildPremiumQuickActionCard(actions[index], theme, isDark);
        },
      ),
    );
  }

  Widget _buildPremiumQuickActionCard(_QuickAction action, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        Navigator.pushNamed(context, action.route, arguments: action.arguments);
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: action.gradientColors ?? [action.color, action.color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with glow effect
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                action.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Spacer(),
            // Label
            Text(
              action.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            // Arrow indicator
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranSection(ThemeData theme, bool isDark) {
    final items = [
      _FeatureItem(
        icon: Icons.list_alt_rounded,
        title: 'Surah List',
        subtitle: '114 Surahs',
        color: AppColors.forestGreen,
        route: '/surah-list',
      ),
      _FeatureItem(
        icon: Icons.layers_rounded,
        title: 'Juz List',
        subtitle: '30 Juz',
        color: AppColors.mutedTeal,
        route: '/juz-list',
      ),
      _FeatureItem(
        icon: Icons.bookmark_rounded,
        title: 'Bookmarks',
        subtitle: 'Saved verses',
        color: AppColors.softRoseDark,
        route: '/bookmarks',
      ),
      _FeatureItem(
        icon: Icons.school_rounded,
        title: 'Tajweed',
        subtitle: 'Learn rules',
        color: AppColors.roseGoldPrimary,
        route: '/tajweed-rules',
      ),
    ];

    return _buildFeatureGrid(items, isDark);
  }

  Widget _buildIslamicToolsSection(ThemeData theme, bool isDark) {
    final items = [
      _FeatureItem(
        icon: Icons.explore_rounded,
        title: 'Qibla Direction',
        subtitle: 'Find Kaaba',
        color: AppColors.mutedTealDark,
        route: '/qibla',
      ),
      _FeatureItem(
        icon: Icons.radio_button_on_rounded,
        title: 'Tasbih Counter',
        subtitle: 'Digital dhikr',
        color: AppColors.roseGoldPrimary,
        route: '/tasbih',
      ),
      _FeatureItem(
        icon: Icons.calculate_rounded,
        title: 'Zakat Calculator',
        subtitle: 'Calculate zakat',
        color: AppColors.forestGreen,
        route: '/zakat-calculator',
      ),
      _FeatureItem(
        icon: Icons.search_rounded,
        title: 'Search',
        subtitle: 'Find anything',
        color: AppColors.mutedTeal,
        route: '/search',
      ),
    ];

    return _buildFeatureGrid(items, isDark);
  }

  Widget _buildRamadanSection(ThemeData theme, bool isDark) {
    final items = [
      _FeatureItem(
        icon: Icons.calendar_month_rounded,
        title: 'Ramadan Calendar',
        subtitle: 'Schedule & times',
        color: AppColors.softRoseDark,
        route: '/ramadan-calendar',
      ),
      _FeatureItem(
        icon: Icons.auto_stories_rounded,
        title: 'Ramadan Duas',
        subtitle: 'Daily prayers',
        color: AppColors.forestGreen,
        route: '/ramadan-duas',
      ),
      _FeatureItem(
        icon: Icons.check_circle_rounded,
        title: 'Daily Tracker',
        subtitle: 'Track ibadah',
        color: AppColors.mutedTeal,
        route: '/daily-tracker',
      ),
      _FeatureItem(
        icon: Icons.event_note_rounded,
        title: 'Quran Planner',
        subtitle: 'Reading goals',
        color: AppColors.roseGoldPrimary,
        route: '/quran-planner',
      ),
    ];

    return _buildFeatureGrid(items, isDark);
  }

  Widget _buildFeatureGrid(List<_FeatureItem> items, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) => _buildFeatureCard(item, isDark)).toList(),
    );
  }

  Widget _buildFeatureCard(_FeatureItem item, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        Navigator.pushNamed(context, item.route);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black38 : AppColors.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: appState.currentNavIndex == 0,
                  onTap: () => _onNavItemTapped(0),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Read',
                  isSelected: appState.currentNavIndex == 1,
                  onTap: () => _onNavItemTapped(1),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.bookmark_rounded,
                  label: 'Saved',
                  isSelected: appState.currentNavIndex == 2,
                  onTap: () => _onNavItemTapped(2),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: appState.currentNavIndex == 3,
                  onTap: () => _onNavItemTapped(3),
                  theme: theme,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final List<Color>? gradientColors;
  final String route;
  final dynamic arguments;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.gradientColors,
    required this.route,
    this.arguments,
  });
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}
