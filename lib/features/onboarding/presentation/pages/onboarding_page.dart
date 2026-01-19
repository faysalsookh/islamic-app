import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/theme_selection_page.dart';
import '../widgets/font_size_selection_page.dart';
import '../widgets/name_input_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _onboardingContent = [
    const OnboardingContent(
      title: 'Read Quran Easily',
      description:
          'Access the complete Holy Quran with beautiful Arabic typography designed for comfortable reading.',
      icon: Icons.menu_book_rounded,
    ),
    const OnboardingContent(
      title: 'Beautiful Arabic Font',
      description:
          'Experience Quran in elegant Mushaf-style fonts with clear diacritics and adjustable sizes.',
      icon: Icons.text_fields_rounded,
    ),
    const OnboardingContent(
      title: 'Bookmark Your Progress',
      description:
          'Never lose your place. Save bookmarks and continue reading right where you left off.',
      icon: Icons.bookmark_rounded,
    ),
    const OnboardingContent(
      title: 'Night Mode for Comfort',
      description:
          'Read comfortably at any time with our carefully crafted light and dark themes.',
      icon: Icons.nightlight_round,
    ),
  ];

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final appState = context.read<AppStateProvider>();
    await appState.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: IslamicPatternBackground(
          patternColor: primaryColor,
          opacity: 0.05,
          patternType: PatternType.arabesque,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 700 : double.infinity,
              ),
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: _currentPage < 4
                          ? GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  4,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  color: primaryColor,
                                ),
                              ),
                            )
                          : SizedBox(height: isTablet ? 32 : 24),
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        // Intro pages
                        ..._onboardingContent.map(
                          (content) => OnboardingPageContent(content: content),
                        ),
                        // Theme selection
                        const ThemeSelectionPage(),
                        // Font size selection
                        const FontSizeSelectionPage(),
                        // Name input
                        NameInputPage(onComplete: _completeOnboarding),
                      ],
                    ),
                  ),

                  // Page indicator and navigation
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 32 : 24),
                    child: Column(
                      children: [
                        // Page dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            7,
                            (index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
                              width: _currentPage == index ? (isTablet ? 32 : 24) : (isTablet ? 10 : 8),
                              height: isTablet ? 10 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? primaryColor
                                    : primaryColor.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Navigation buttons
                        if (_currentPage < 6)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              SizedBox(
                                width: isTablet ? 120 : 100,
                                child: _currentPage > 0
                                    ? GestureDetector(
                                        onTap: _previousPage,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_rounded,
                                              color: primaryColor,
                                              size: isTablet ? 24 : 20,
                                            ),
                                            SizedBox(width: isTablet ? 6 : 4),
                                            Text(
                                              'Back',
                                              style: TextStyle(
                                                fontSize: isTablet ? 18 : 16,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              // Next button
                              GestureDetector(
                                onTap: _nextPage,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 40 : 32,
                                    vertical: isTablet ? 18 : 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _currentPage < 3 ? 'Next' : 'Continue',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: isTablet ? 10 : 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: isTablet ? 24 : 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for onboarding content
class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
  });
}
