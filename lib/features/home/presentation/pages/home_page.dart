import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/services/haptic_service.dart';
import '../widgets/greeting_header.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/quick_access_section.dart';
import '../widgets/surah_list_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Reset nav index to home when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().setNavIndex(0);
    });
  }

  void _onNavItemTapped(int index) {
    HapticService().selectionClick();
    context.read<AppStateProvider>().setNavIndex(index);

    switch (index) {
      case 0:
        // Already on home
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: CustomScrollView(
              slivers: [
                // App bar with greeting and search
                SliverToBoxAdapter(
                  child: IslamicPatternBackground(
                    patternColor: theme.colorScheme.primary,
                    opacity: 0.03,
                    patternType: PatternType.geometric,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, isTablet ? 28 : 20, horizontalPadding, horizontalPadding),
                      child: Column(
                        children: [
                          const GreetingHeader(),
                          const SizedBox(height: 16),
                          // Search Bar
                          _buildSearchBar(isDark),
                        ],
                      ),
                    ),
                  ),
                ),

                // Continue Reading card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: const ContinueReadingCard(),
                  ),
                ),

                // Quick access buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, isTablet ? 32 : 24, horizontalPadding, 8),
                    child: Text(
                      'Quick Access',
                      style: AppTypography.heading3(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: QuickAccessSection(isTablet: isTablet),
                ),

                // Browse Quran section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, isTablet ? 32 : 24, horizontalPadding, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Browse Quran',
                          style: AppTypography.heading3(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/surah-list');
                          },
                          child: Text(
                            'See All',
                            style: AppTypography.bodyMedium(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Surah list preview
                SurahListSection(horizontalPadding: horizontalPadding),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService().lightImpact();
        Navigator.pushNamed(context, '/search');
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search surahs, ayahs...',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.keyboard_command_key,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : AppColors.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: appState.currentNavIndex == 0,
                    onTap: () => _onNavItemTapped(0),
                  ),
                  _NavItem(
                    icon: Icons.menu_book_rounded,
                    label: 'Read',
                    isSelected: appState.currentNavIndex == 1,
                    onTap: () => _onNavItemTapped(1),
                  ),
                  _NavItem(
                    icon: Icons.bookmark_rounded,
                    label: 'Bookmarks',
                    isSelected: appState.currentNavIndex == 2,
                    onTap: () => _onNavItemTapped(2),
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isSelected: appState.currentNavIndex == 3,
                    onTap: () => _onNavItemTapped(3),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isSelected
        ? theme.colorScheme.primary
        : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
