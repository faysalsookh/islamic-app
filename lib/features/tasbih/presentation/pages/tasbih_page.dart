import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/tasbih_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tasbih_sound_service.dart';
import '../widgets/tasbih_beads_widget.dart';
import '../widgets/tasbih_counter_widget.dart';
import '../widgets/dhikr_selection_sheet.dart';

/// Main Tasbih (digital prayer beads) page
class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> with TickerProviderStateMixin {
  final TasbihService _tasbihService = TasbihService();
  final TasbihSoundService _soundService = TasbihSoundService();
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
    await _soundService.initialize();
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
    _soundService.dispose();
    super.dispose();
  }

  void _onTap() {
    _tapAnimationController.forward().then((_) {
      _tapAnimationController.reverse();
    });

    // Check if loop is about to complete
    final isLoopComplete = _tasbihService.count + 1 >= _tasbihService.target;

    // Haptic feedback
    if (_tasbihService.vibrationEnabled) {
      if (isLoopComplete) {
        // Strong feedback for loop completion
        HapticService().heavyImpact();
      } else {
        // Medium feedback for regular count
        HapticService().mediumImpact();
      }
    }

    // Play sound if enabled
    if (_tasbihService.soundEnabled) {
      if (isLoopComplete) {
        _soundService.playLoopCompleteSound();
      } else {
        _soundService.playClickSound();
      }
    }

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
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Counter widget
                            TasbihCounterWidget(
                              count: _tasbihService.count,
                              target: _tasbihService.target,
                              loop: _tasbihService.loop,
                              isTablet: isTablet,
                              onTargetTap: _showTargetDialog,
                            ),

                            SizedBox(height: isTablet ? 32 : 20),

                            // Beads visualization
                            TasbihBeadsWidget(
                              count: _tasbihService.count,
                              target: _tasbihService.target,
                              beadStyle: _tasbihService.beadStyle,
                              isTablet: isTablet,
                            ),

                            SizedBox(height: isTablet ? 24 : 16),

                            // Instructions
                            _buildInstructions(isTablet),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Bottom section - Muslim Pro style
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
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: isTablet ? 28 : 24,
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
            child: Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
          ),

          SizedBox(width: isTablet ? 24 : 20),

          // Sound toggle
          GestureDetector(
            onTap: () {
              HapticService().lightImpact();
              _tasbihService.toggleSound();
            },
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
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Start Dhikr header with View All button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start Dhikr',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _showDhikrSheet,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 12 : 8),

          // Bead style selector (horizontal scroll like Muslim Pro)
          SizedBox(
            height: isTablet ? 70 : 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12),
              itemCount: TasbihBeadStyle.values.length,
              itemBuilder: (context, index) {
                final style = TasbihBeadStyle.values[index];
                final isSelected = _tasbihService.beadStyle == style;
                final gradientColors = TasbihService.getBeadGradientValues(style)
                    .map((v) => Color(v))
                    .toList();

                return GestureDetector(
                  onTap: () {
                    HapticService().lightImpact();
                    _tasbihService.setBeadStyle(style);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isTablet ? 48 : 40,
                          height: isTablet ? 48 : 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: const Alignment(-0.3, -0.3),
                              radius: 1.0,
                              colors: gradientColors,
                            ),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF4CAF50),
                                    width: 3,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: isTablet ? 16 : 12,
                              height: isTablet ? 16 : 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Selected dhikr display (if any)
          if (_tasbihService.selectedDhikr != null) ...[
            SizedBox(height: isTablet ? 8 : 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              child: GestureDetector(
                onTap: _showDhikrSheet,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 14 : 10,
                    vertical: isTablet ? 10 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_tasbihService.selectedDhikr!.arabic}  •  ${_tasbihService.selectedDhikr!.transliteration}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: const Color(0xFF4CAF50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white38,
                        size: isTablet ? 20 : 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          SizedBox(height: isTablet ? 12 : 10),
        ],
      ),
    );
  }
}
