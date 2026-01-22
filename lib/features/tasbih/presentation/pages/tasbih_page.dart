import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/tasbih_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../widgets/tasbih_beads_widget.dart';
import '../widgets/tasbih_counter_widget.dart';
import '../widgets/tasbih_bead_selector.dart';
import '../widgets/dhikr_selection_sheet.dart';

/// Main Tasbih (digital prayer beads) page
class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> with TickerProviderStateMixin {
  final TasbihService _tasbihService = TasbihService();
  bool _isInitialized = false;

  late AnimationController _tapAnimationController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _setupAnimations();
  }

  void _setupAnimations() {
    _tapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _tapAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeService() async {
    await _tasbihService.initialize();
    _tasbihService.addListener(_onServiceChanged);
    setState(() {
      _isInitialized = true;
    });
  }

  void _onServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tasbihService.removeListener(_onServiceChanged);
    _tapAnimationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _tapAnimationController.forward().then((_) {
      _tapAnimationController.reverse();
    });

    if (_tasbihService.vibrationEnabled) {
      HapticService().lightImpact();
    }

    // TODO: Add sound if enabled

    _tasbihService.increment();
  }

  void _onSwipeLeft() {
    if (_tasbihService.vibrationEnabled) {
      HapticService().lightImpact();
    }
    _tasbihService.decrement();
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Reset Counter?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will reset your current count and loop. Total count will be preserved.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _tasbihService.reset();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog() async {
    final newTarget = await TargetSelectionDialog.show(
      context,
      currentTarget: _tasbihService.target,
      presets: TasbihService.commonTargets,
    );

    if (newTarget != null) {
      _tasbihService.setTarget(newTarget);
    }
  }

  void _showDhikrSheet() {
    DhikrSelectionSheet.show(
      context,
      selectedDhikr: _tasbihService.selectedDhikr,
      onDhikrSelected: (dhikr) {
        _tasbihService.selectDhikr(dhikr);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: _isInitialized
              ? _buildContent(isTablet)
              : const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isTablet) {
    return Column(
      children: [
        // App bar
        _buildAppBar(isTablet),

        // Main tappable area
        Expanded(
          child: GestureDetector(
            onTap: _onTap,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 0) {
                // Swipe right - decrement
                _onSwipeLeft();
              }
            },
            child: AnimatedBuilder(
              animation: _tapAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _tapAnimation.value,
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Counter widget
                        TasbihCounterWidget(
                          count: _tasbihService.count,
                          target: _tasbihService.target,
                          loop: _tasbihService.loop,
                          isTablet: isTablet,
                          onTargetTap: _showTargetDialog,
                        ),

                        SizedBox(height: isTablet ? 48 : 32),

                        // Beads visualization
                        TasbihBeadsWidget(
                          count: _tasbihService.count,
                          target: _tasbihService.target,
                          beadStyle: _tasbihService.beadStyle,
                          isTablet: isTablet,
                        ),

                        SizedBox(height: isTablet ? 32 : 24),

                        // Instructions
                        _buildInstructions(isTablet),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Bottom section
        _buildBottomSection(isTablet),
      ],
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              'Tasbih',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // Reset button
          GestureDetector(
            onTap: _showResetConfirmation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Sound toggle
          GestureDetector(
            onTap: () {
              HapticService().lightImpact();
              _tasbihService.toggleSound();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _tasbihService.soundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: _tasbihService.soundEnabled
                    ? Colors.white
                    : Colors.white38,
                size: isTablet ? 28 : 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(bool isTablet) {
    return Column(
      children: [
        Text(
          'Tap anywhere to begin',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: isTablet ? 8 : 4),
        Text(
          '(right-left swipe will decrease count)',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Dhikr section
          _buildDhikrSection(isTablet),

          SizedBox(height: isTablet ? 20 : 16),

          // Bead style selector
          _buildBeadStyleSection(isTablet),
        ],
      ),
    );
  }

  Widget _buildDhikrSection(bool isTablet) {
    final selectedDhikr = _tasbihService.selectedDhikr;

    return GestureDetector(
      onTap: _showDhikrSheet,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Dhikr info or prompt
            Expanded(
              child: selectedDhikr != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDhikr.arabic,
                          style: TextStyle(
                            fontSize: isTablet ? 22 : 18,
                            fontFamily: 'Amiri',
                            color: const Color(0xFF4CAF50),
                            height: 1.4,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedDhikr.transliteration} • ${selectedDhikr.meaning}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.white54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Dhikr',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Don't just count your Tasbihs, make your Tasbihs count",
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(width: 16),

            // Select button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                selectedDhikr != null ? 'Change' : 'Select a Dhikr',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeadStyleSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: isTablet ? 8 : 4, bottom: 8),
          child: Text(
            'Bead Style',
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TasbihBeadSelector(
          selectedStyle: _tasbihService.beadStyle,
          onStyleChanged: (style) {
            _tasbihService.setBeadStyle(style);
          },
          isTablet: isTablet,
        ),
      ],
    );
  }
}
