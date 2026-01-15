import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _patternController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Pulse animation for the decorative ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Pattern rotation
    _patternController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Logo scale animation
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Logo opacity
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // App name text opacity
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    // Tagline opacity
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    // Shimmer effect
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.forestGreen,
              AppColors.forestGreenDark,
              Color(0xFF1A2F23),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background pattern
            _buildAnimatedPattern(size),

            // Decorative circles
            _buildDecorativeElements(size),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo with animations
                  _buildAnimatedLogo(),

                  const SizedBox(height: 32),

                  // App name with shimmer
                  _buildAppName(),

                  const SizedBox(height: 12),

                  // Tagline
                  _buildTagline(),

                  const Spacer(flex: 2),

                  // Bottom branding
                  _buildBottomBranding(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPattern(Size size) {
    return AnimatedBuilder(
      animation: _patternController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: _IslamicPatternPainter(
              rotation: _patternController.value * 2 * math.pi,
              opacity: 0.03,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecorativeElements(Size size) {
    return Stack(
      children: [
        // Top left decoration
        Positioned(
          top: -50,
          left: -50,
          child: _buildDecorativeCircle(150, 0.05),
        ),
        // Bottom right decoration
        Positioned(
          bottom: -80,
          right: -80,
          child: _buildDecorativeCircle(200, 0.04),
        ),
        // Small accents
        Positioned(
          top: size.height * 0.15,
          right: 30,
          child: _buildSmallStar(),
        ),
        Positioned(
          bottom: size.height * 0.25,
          left: 40,
          child: _buildSmallStar(),
        ),
      ],
    );
  }

  Widget _buildDecorativeCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.softRose.withValues(alpha: opacity),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildSmallStar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_pulseController.value * 0.4),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softRose,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    // Responsive sizing for tablets
    final isTablet = Responsive.isTabletOrLarger(context);
    final scale = isTablet ? 1.4 : 1.0;
    final outerRingSize = 180.0 * scale;
    final middleRingSize = 160.0 * scale;
    final innerCircleSize = 140.0 * scale;
    final iconContainerSize = 100.0 * scale;
    final iconSize = 50.0 * scale;

    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing ring
                Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: Container(
                    width: outerRingSize,
                    height: outerRingSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.softRose
                            .withValues(alpha: 0.2 - (_pulseController.value * 0.1)),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Middle ring
                Container(
                  width: middleRingSize,
                  height: middleRingSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.softRose.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                ),

                // Inner gradient circle
                Container(
                  width: innerCircleSize,
                  height: innerCircleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.softRose.withValues(alpha: 0.2),
                        AppColors.mutedTeal.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.softRose.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.softRose.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),

                // Quran icon
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    // Responsive font sizes for tablets
    final isTablet = Responsive.isTabletOrLarger(context);
    final arabicFontSize = isTablet ? 48.0 : 36.0;
    final englishFontSize = isTablet ? 24.0 : 18.0;
    final letterSpacing = isTablet ? 12.0 : 8.0;

    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Colors.white,
                  AppColors.softRoseLight,
                  Colors.white,
                ],
                stops: [
                  _shimmerAnimation.value - 0.3,
                  _shimmerAnimation.value,
                  _shimmerAnimation.value + 0.3,
                ].map((e) => e.clamp(0.0, 1.0)).toList(),
              ).createShader(bounds);
            },
            child: Column(
              children: [
                // Arabic name
                Text(
                  'القرآن الكريم',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: arabicFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                // English name
                Text(
                  'QURAN READER',
                  style: TextStyle(
                    fontSize: englishFontSize,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: letterSpacing,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline() {
    // Responsive sizing for tablets
    final isTablet = Responsive.isTabletOrLarger(context);
    final fontSize = isTablet ? 18.0 : 14.0;
    final letterSpacing = isTablet ? 5.0 : 3.0;
    final horizontalPadding = isTablet ? 32.0 : 20.0;

    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _taglineOpacity.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.softRose.withValues(alpha: 0.3),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: AppColors.softRose.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'Read • Reflect • Remember',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w300,
                color: AppColors.softRoseLight.withValues(alpha: 0.8),
                letterSpacing: letterSpacing,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBranding() {
    // Responsive sizing for tablets
    final isTablet = Responsive.isTabletOrLarger(context);
    final loaderWidth = isTablet ? 180.0 : 120.0;
    final fontSize = isTablet ? 14.0 : 12.0;

    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _taglineOpacity.value,
          child: Column(
            children: [
              // Loading indicator
              SizedBox(
                width: loaderWidth,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.softRose.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.softRose.withValues(alpha: 0.5),
                  ),
                  minHeight: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Designed for Muslim Women',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for subtle Islamic geometric pattern
class _IslamicPatternPainter extends CustomPainter {
  final double rotation;
  final double opacity;

  _IslamicPatternPainter({
    required this.rotation,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.softRose.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.height * 0.6;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Draw concentric geometric patterns
    for (var i = 1; i <= 5; i++) {
      final radius = maxRadius * (i / 5);
      _drawOctagonalPattern(canvas, center, radius, paint);
    }

    canvas.restore();
  }

  void _drawOctagonalPattern(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const sides = 8;

    for (var i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 8;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.opacity != opacity;
  }
}
