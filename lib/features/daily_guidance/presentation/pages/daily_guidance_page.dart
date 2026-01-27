import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/daily_guidance_provider.dart';
import '../../../../core/services/haptic_service.dart';
import '../../data/daily_guidance_model.dart';
import '../widgets/guidance_card.dart';
import '../widgets/guidance_progress_bar.dart';
import '../widgets/share_card_builder.dart';

/// Premium Stories-style daily guidance page
class DailyGuidancePage extends StatefulWidget {
  const DailyGuidancePage({super.key});

  @override
  State<DailyGuidancePage> createState() => _DailyGuidancePageState();
}

class _DailyGuidancePageState extends State<DailyGuidancePage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _timerController;
  late AnimationController _fadeController;

  int _currentPage = 0;
  bool _isPaused = false;
  List<DailyGuidanceItem> _items = [];

  static const Duration _autoAdvanceDuration = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _timerController = AnimationController(
      vsync: this,
      duration: _autoAdvanceDuration,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Listen for timer completion to auto-advance
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isPaused) {
        _goToNextPage();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  void _loadItems() {
    final provider = context.read<DailyGuidanceProvider>();
    provider.markTodayViewed();
    setState(() {
      _items = provider.todayItems;
    });
    _fadeController.forward();
    _timerController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - close or loop
      Navigator.pop(context);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    HapticService().selectionClick();
    setState(() {
      _currentPage = page;
    });
    _timerController.reset();
    if (!_isPaused) {
      _timerController.forward();
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPaused = true);
    _timerController.stop();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPaused = false);
    _timerController.forward();
  }

  void _onTapCancel() {
    setState(() => _isPaused = false);
    _timerController.forward();
  }

  void _handleTap(TapUpDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth * 0.3) {
      _goToPreviousPage();
    } else if (tapX > screenWidth * 0.7) {
      _goToNextPage();
    }
  }

  void _toggleBookmark(DailyGuidanceItem item) {
    HapticService().lightImpact();
    context.read<DailyGuidanceProvider>().toggleBookmark(item);
  }

  void _shareItem(DailyGuidanceItem item) {
    HapticService().lightImpact();
    final provider = context.read<DailyGuidanceProvider>();
    ShareCardBuilder.shareItem(context, item, provider.currentDayNumber);
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FadeTransition(
          opacity: _fadeController,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: (details) {
              _onTapUp(details);
              _handleTap(details);
            },
            onTapCancel: _onTapCancel,
            onLongPressStart: (_) {
              setState(() => _isPaused = true);
              _timerController.stop();
            },
            onLongPressEnd: (_) {
              setState(() => _isPaused = false);
              _timerController.forward();
            },
            child: Stack(
              children: [
                // Page content
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Consumer<DailyGuidanceProvider>(
                      builder: (context, provider, _) {
                        return GuidanceCard(
                          item: item,
                          dayNumber: provider.currentDayNumber,
                          isBookmarked: provider.isBookmarked(item),
                          onBookmark: () => _toggleBookmark(item),
                          onShare: () => _shareItem(item),
                        );
                      },
                    );
                  },
                ),

                // Progress bar at top
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: AnimatedBuilder(
                    animation: _timerController,
                    builder: (context, child) {
                      return GuidanceProgressBar(
                        totalSegments: _items.length,
                        currentSegment: _currentPage,
                        progress: _timerController.value,
                      );
                    },
                  ),
                ),

                // Close button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 24,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      HapticService().lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Streak badge (top left below progress bar)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 24,
                  left: 16,
                  child: Consumer<DailyGuidanceProvider>(
                    builder: (context, provider, _) {
                      if (provider.currentStreak <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: Color(0xFFFF9800),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.currentStreak}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
