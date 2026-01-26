import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/haptic_service.dart';
import '../../data/umrah_duas_data.dart';
import '../widgets/umrah_dua_card.dart';
import '../widgets/umrah_cover_card.dart';

/// Premium Umrah Duas Page with swipeable cards
class UmrahDuasPage extends StatefulWidget {
  const UmrahDuasPage({super.key});

  @override
  State<UmrahDuasPage> createState() => _UmrahDuasPageState();
}

class _UmrahDuasPageState extends State<UmrahDuasPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  bool _showBengali = true;

  // Total pages = cover card + all duas
  int get _totalPages => UmrahDuasData.duas.length + 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.92,
      initialPage: 0,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    HapticService().selectionClick();
    setState(() {
      _currentPage = page;
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _toggleBengali() {
    HapticService().lightImpact();
    setState(() {
      _showBengali = !_showBengali;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5EDE4),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Cards PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Cover card
                    return UmrahCoverCard(
                      totalDuas: UmrahDuasData.duas.length,
                      onStart: () => _goToPage(1),
                    );
                  } else {
                    // Dua cards
                    final dua = UmrahDuasData.duas[index - 1];
                    return UmrahDuaCard(
                      dua: dua,
                      totalCards: UmrahDuasData.duas.length,
                      showBengali: _showBengali,
                    );
                  }
                },
              ),
            ),

            // Page indicator and controls
            _buildBottomSection(isDark, theme),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Bengali toggle
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _toggleBengali,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCard.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showBengali
                        ? Icons.translate_rounded
                        : Icons.translate_outlined,
                    size: 18,
                    color: _showBengali
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'BN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _showBengali
                          ? Theme.of(context).colorScheme.primary
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            _buildProgressIndicator(isDark, theme),

            const SizedBox(height: 20),

            // Navigation controls
            _buildNavigationControls(isDark, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark, ThemeData theme) {
    return Column(
      children: [
        // Page counter text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentPage == 0)
              Text(
                'Cover',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_currentPage',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${UmrahDuasData.duas.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _currentPage / (_totalPages - 1),
            backgroundColor: isDark
                ? AppColors.darkCard
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 4,
          ),
        ),

        const SizedBox(height: 12),

        // Dot indicators (for first few and current position)
        _buildDotIndicators(isDark, theme),
      ],
    );
  }

  Widget _buildDotIndicators(bool isDark, ThemeData theme) {
    // Show max 7 dots centered around current position
    const maxDots = 7;
    int startIndex = 0;
    int endIndex = _totalPages;

    if (_totalPages > maxDots) {
      startIndex = (_currentPage - maxDots ~/ 2).clamp(0, _totalPages - maxDots);
      endIndex = startIndex + maxDots;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        endIndex - startIndex,
        (index) {
          final pageIndex = startIndex + index;
          final isActive = pageIndex == _currentPage;
          final isCover = pageIndex == 0;

          return GestureDetector(
            onTap: () => _goToPage(pageIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : (isCover ? 10 : 8),
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : (isDark
                        ? AppColors.darkCard
                        : theme.colorScheme.primary.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationControls(bool isDark, ThemeData theme) {
    final canGoBack = _currentPage > 0;
    final canGoForward = _currentPage < _totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button
        _buildNavButton(
          icon: Icons.arrow_back_rounded,
          label: 'Previous',
          onPressed: canGoBack ? () => _goToPage(_currentPage - 1) : null,
          isDark: isDark,
          theme: theme,
        ),

        // Category indicator (when viewing duas)
        if (_currentPage > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              UmrahDuasData.duas[_currentPage - 1].category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          )
        else
          const SizedBox(width: 80),

        // Next button
        _buildNavButton(
          icon: Icons.arrow_forward_rounded,
          label: 'Next',
          onPressed: canGoForward ? () => _goToPage(_currentPage + 1) : null,
          isDark: isDark,
          theme: theme,
          isNext: true,
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isDark,
    required ThemeData theme,
    bool isNext = false,
  }) {
    final isEnabled = onPressed != null;

    return GestureDetector(
      onTap: () {
        if (isEnabled) {
          HapticService().lightImpact();
          onPressed();
        }
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isEnabled
                ? theme.colorScheme.primary
                : (isDark ? AppColors.darkCard : AppColors.divider),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNext) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isEnabled
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
                ),
              ),
              if (isNext) ...[
                const SizedBox(width: 6),
                Icon(
                  icon,
                  size: 18,
                  color: isEnabled
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
