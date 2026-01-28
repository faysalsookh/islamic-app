import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Compass theme styles
enum CompassTheme {
  classic,
  golden,
  minimal,
  elegant,
  nature,
}

/// Professional animated compass widget showing Qibla direction
/// Inspired by Muslim Pro's premium design
class QiblaCompassWidget extends StatefulWidget {
  final double heading;
  final double qiblaBearing;
  final double? sunBearing;
  final bool isTablet;
  final CompassTheme theme;

  const QiblaCompassWidget({
    super.key,
    required this.heading,
    required this.qiblaBearing,
    this.sunBearing,
    this.isTablet = false,
    this.theme = CompassTheme.golden,
  });

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Check if device is facing Qibla (within 5 degrees)
  bool get isFacingQibla {
    final qiblaDirection = (widget.qiblaBearing - widget.heading + 360) % 360;
    return qiblaDirection <= 5 || qiblaDirection >= 355;
  }

  /// Check if almost facing Qibla (within 15 degrees)
  bool get isAlmostFacingQibla {
    final qiblaDirection = (widget.qiblaBearing - widget.heading + 360) % 360;
    return (qiblaDirection <= 15 || qiblaDirection >= 345) && !isFacingQibla;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isTablet ? 320.0 : 280.0;
    final qiblaDirection = (widget.qiblaBearing - widget.heading + 360) % 360;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kaaba indicator at top
        _buildKaabaIndicator(),
        const SizedBox(height: 8),

        // Main compass
        SizedBox(
          width: size + 40,
          height: size + 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow when facing Qibla
              if (isFacingQibla)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: (size + 30) * _pulseAnimation.value,
                      height: (size + 30) * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getThemeColors().primary.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),

              // Golden/theme ring
              Container(
                width: size + 16,
                height: size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getThemeColors().ringGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),

              // Main compass body
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getThemeColors().background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // Compass dial (rotates with heading)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: -widget.heading),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                builder: (context, rotation, child) {
                  return Transform.rotate(
                    angle: rotation * pi / 180,
                    child: SizedBox(
                      width: size - 20,
                      height: size - 20,
                      child: CustomPaint(
                        painter: _ProfessionalCompassPainter(
                          themeColors: _getThemeColors(),
                          isTablet: widget.isTablet,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Qibla direction cone/indicator
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: qiblaDirection),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                builder: (context, angle, child) {
                  return Transform.rotate(
                    angle: angle * pi / 180,
                    child: _buildQiblaCone(size - 20),
                  );
                },
              ),

              // Sun position indicator (simplified)
              _buildSunIndicator(size - 20),

              // Center decoration
              _buildCenterDecoration(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKaabaIndicator() {
    final colors = _getThemeColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.square_rounded,
        color: Colors.white,
        size: widget.isTablet ? 20 : 16,
      ),
    );
  }

  Widget _buildQiblaCone(double size) {
    final colors = _getThemeColors();

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _QiblaConePainter(
          color: colors.qiblaIndicator,
          glowColor: isFacingQibla ? colors.primary : Colors.transparent,
          isFacingQibla: isFacingQibla,
        ),
      ),
    );
  }

  Widget _buildSunIndicator(double size) {
    if (widget.sunBearing == null) return const SizedBox.shrink();

    return Transform.rotate(
      angle: (widget.sunBearing! - widget.heading) * pi / 180,
      child: SizedBox(
        width: size,
        height: size,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: widget.isTablet ? 32 : 26,
              height: widget.isTablet ? 32 : 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFE082),
                    const Color(0xFFFFC107),
                    const Color(0xFFFF9800),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(Icons.wb_sunny_rounded, color: Colors.orange[900], size: widget.isTablet ? 20 : 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDecoration() {
    final colors = _getThemeColors();
    final centerSize = widget.isTablet ? 50.0 : 42.0;

    return Container(
      width: centerSize,
      height: centerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.centerGradient[0],
            colors.centerGradient[1],
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.background,
        ),
        child: Center(
          child: Container(
            width: centerSize * 0.4,
            height: centerSize * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }

  _CompassThemeColors _getThemeColors() {
    switch (widget.theme) {
      case CompassTheme.classic:
        return _CompassThemeColors(
          background: const Color(0xFF2C2C2C),
          primary: AppColors.forestGreen,
          ringGradient: [const Color(0xFF8B4513), const Color(0xFFD2691E)],
          cardinalColor: Colors.white,
          tickColor: Colors.white54,
          qiblaIndicator: AppColors.forestGreen,
          centerGradient: [const Color(0xFF8B4513), const Color(0xFF654321)],
        );
      case CompassTheme.golden:
        return _CompassThemeColors(
          background: const Color(0xFF1E1E1E),
          primary: const Color(0xFF4CAF50),
          ringGradient: [const Color(0xFFD4A853), const Color(0xFFB8860B), const Color(0xFFD4A853)],
          cardinalColor: Colors.white,
          tickColor: Colors.white60,
          qiblaIndicator: const Color(0xFF4CAF50),
          centerGradient: [const Color(0xFFD4A853), const Color(0xFFB8860B)],
        );
      case CompassTheme.minimal:
        return _CompassThemeColors(
          background: const Color(0xFFF5F5F5),
          primary: const Color(0xFF2196F3),
          ringGradient: [const Color(0xFF90CAF9), const Color(0xFF64B5F6)],
          cardinalColor: const Color(0xFF333333),
          tickColor: const Color(0xFF666666),
          qiblaIndicator: const Color(0xFF2196F3),
          centerGradient: [const Color(0xFF90CAF9), const Color(0xFF64B5F6)],
        );
      case CompassTheme.elegant:
        return _CompassThemeColors(
          background: const Color(0xFF1A1A2E),
          primary: const Color(0xFFE94560),
          ringGradient: [const Color(0xFFE94560), const Color(0xFF0F3460)],
          cardinalColor: Colors.white,
          tickColor: Colors.white54,
          qiblaIndicator: const Color(0xFFE94560),
          centerGradient: [const Color(0xFFE94560), const Color(0xFF0F3460)],
        );
      case CompassTheme.nature:
        return _CompassThemeColors(
          background: const Color(0xFF1B4332),
          primary: const Color(0xFF95D5B2),
          ringGradient: [const Color(0xFF95D5B2), const Color(0xFF52B788)],
          cardinalColor: Colors.white,
          tickColor: Colors.white60,
          qiblaIndicator: const Color(0xFF95D5B2),
          centerGradient: [const Color(0xFF74C69D), const Color(0xFF40916C)],
        );
    }
  }
}

/// Theme colors for compass
class _CompassThemeColors {
  final Color background;
  final Color primary;
  final List<Color> ringGradient;
  final Color cardinalColor;
  final Color tickColor;
  final Color qiblaIndicator;
  final List<Color> centerGradient;

  _CompassThemeColors({
    required this.background,
    required this.primary,
    required this.ringGradient,
    required this.cardinalColor,
    required this.tickColor,
    required this.qiblaIndicator,
    required this.centerGradient,
  });
}

/// Professional compass dial painter
class _ProfessionalCompassPainter extends CustomPainter {
  final _CompassThemeColors themeColors;
  final bool isTablet;

  _ProfessionalCompassPainter({
    required this.themeColors,
    required this.isTablet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw degree ticks
    _drawDegreeTicks(canvas, center, radius);

    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, radius);
  }

  void _drawDegreeTicks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = themeColors.tickColor
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 360; i += 1) {
      final angle = i * pi / 180 - pi / 2;
      final isMajor = i % 30 == 0;
      final isMedium = i % 10 == 0;
      final isMinor = i % 5 == 0;

      double startRadius;
      double endRadius;

      if (isMajor) {
        startRadius = radius - (isTablet ? 8 : 6);
        endRadius = radius - (isTablet ? 20 : 16);
        tickPaint.strokeWidth = isTablet ? 2.5 : 2;
        tickPaint.color = themeColors.cardinalColor;
      } else if (isMedium) {
        startRadius = radius - (isTablet ? 8 : 6);
        endRadius = radius - (isTablet ? 16 : 12);
        tickPaint.strokeWidth = isTablet ? 1.5 : 1.2;
        tickPaint.color = themeColors.tickColor;
      } else if (isMinor) {
        startRadius = radius - (isTablet ? 8 : 6);
        endRadius = radius - (isTablet ? 14 : 10);
        tickPaint.strokeWidth = 1;
        tickPaint.color = themeColors.tickColor.withValues(alpha: 0.8);
      } else {
        startRadius = radius - (isTablet ? 8 : 6);
        endRadius = radius - (isTablet ? 12 : 8);
        tickPaint.strokeWidth = 0.5;
        tickPaint.color = themeColors.tickColor.withValues(alpha: 0.3);
      }

      final startX = center.dx + startRadius * cos(angle);
      final startY = center.dy + startRadius * sin(angle);
      final endX = center.dx + endRadius * cos(angle);
      final endY = center.dy + endRadius * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (var i = 0; i < directions.length; i++) {
      final angle = angles[i] * pi / 180 - pi / 2;
      final textRadius = radius - (isTablet ? 38 : 32);

      final isNorth = directions[i] == 'N';

      final textStyle = TextStyle(
        fontSize: isTablet ? 22 : 18,
        fontWeight: FontWeight.bold,
        color: isNorth ? const Color(0xFFE53935) : themeColors.cardinalColor,
        letterSpacing: 1,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: directions[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final x = center.dx + textRadius * cos(angle) - textPainter.width / 2;
      final y = center.dy + textRadius * sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _ProfessionalCompassPainter oldDelegate) {
    return themeColors != oldDelegate.themeColors;
  }
}

/// Qibla direction cone painter
class _QiblaConePainter extends CustomPainter {
  final Color color;
  final Color glowColor;
  final bool isFacingQibla;

  _QiblaConePainter({
    required this.color,
    required this.glowColor,
    required this.isFacingQibla,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw cone/triangle pointing to Qibla
    final conePath = Path();
    final coneWidth = size.width * 0.12;
    final coneLength = radius - 30;

    // Top point
    conePath.moveTo(center.dx, center.dy - coneLength);
    // Bottom left
    conePath.lineTo(center.dx - coneWidth / 2, center.dy);
    // Bottom right
    conePath.lineTo(center.dx + coneWidth / 2, center.dy);
    conePath.close();

    // Gradient for cone
    final coneGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color,
        color.withValues(alpha: 0.7),
        color.withValues(alpha: 0.3),
      ],
    );

    final conePaint = Paint()
      ..shader = coneGradient.createShader(
        Rect.fromCenter(center: center, width: coneWidth, height: coneLength),
      );

    // Glow effect when facing Qibla
    if (isFacingQibla) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawPath(conePath, glowPaint);
    }

    canvas.drawPath(conePath, conePaint);

    // Draw opposite side (thin line)
    final oppositePath = Path();
    oppositePath.moveTo(center.dx, center.dy + coneLength * 0.6);
    oppositePath.lineTo(center.dx - 2, center.dy);
    oppositePath.lineTo(center.dx + 2, center.dy);
    oppositePath.close();

    final oppositePaint = Paint()..color = color.withValues(alpha: 0.4);
    canvas.drawPath(oppositePath, oppositePaint);
  }

  @override
  bool shouldRepaint(covariant _QiblaConePainter oldDelegate) {
    return color != oldDelegate.color ||
        glowColor != oldDelegate.glowColor ||
        isFacingQibla != oldDelegate.isFacingQibla;
  }
}
