import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated compass widget showing Qibla direction
class QiblaCompassWidget extends StatefulWidget {
  final double heading;
  final double qiblaBearing;
  final bool isTablet;

  const QiblaCompassWidget({
    super.key,
    required this.heading,
    required this.qiblaBearing,
    this.isTablet = false,
  });

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = widget.isTablet ? 340.0 : 280.0;

    // Calculate the qibla direction relative to device heading
    final qiblaDirection = (widget.qiblaBearing - widget.heading + 360) % 360;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative ring
          _buildOuterRing(size, isDark),

          // Main compass dial (rotates with device)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: -widget.heading),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            builder: (context, rotation, child) {
              return Transform.rotate(
                angle: rotation * pi / 180,
                child: _buildCompassDial(size - 40, isDark),
              );
            },
          ),

          // Qibla indicator (points to Mecca)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: qiblaDirection),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            builder: (context, angle, child) {
              return Transform.rotate(
                angle: angle * pi / 180,
                child: _buildQiblaIndicator(size - 40, isDark),
              );
            },
          ),

          // Center Kaaba icon
          _buildCenterIcon(isDark),

          // Fixed north indicator at top
          Positioned(
            top: 0,
            child: _buildNorthIndicator(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildOuterRing(double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDark
              ? [
                  AppColors.darkCard,
                  AppColors.darkSurface,
                ]
              : [
                  Colors.white,
                  AppColors.warmBeige,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black38
                : AppColors.cardShadow.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildCompassDial(double size, bool isDark) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassDialPainter(
          isDark: isDark,
          primaryColor: AppColors.forestGreen,
          isTablet: widget.isTablet,
        ),
      ),
    );
  }

  Widget _buildQiblaIndicator(double size, bool isDark) {
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        children: [
          // Qibla arrow at the top
          Container(
            width: widget.isTablet ? 50 : 42,
            height: widget.isTablet ? 50 : 42,
            decoration: BoxDecoration(
              color: AppColors.forestGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.forestGreen.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.mosque_rounded,
              color: Colors.white,
              size: widget.isTablet ? 26 : 22,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCenterIcon(bool isDark) {
    final centerSize = widget.isTablet ? 80.0 : 65.0;

    return Container(
      width: centerSize,
      height: centerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.forestGreen,
            AppColors.forestGreenDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.square_rounded,
            color: Colors.white,
            size: widget.isTablet ? 24 : 20,
          ),
          Text(
            'Kaaba',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isTablet ? 11 : 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNorthIndicator(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black26
                    : AppColors.cardShadow,
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            'N',
            style: TextStyle(
              fontSize: widget.isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ),
        CustomPaint(
          size: Size(2, widget.isTablet ? 12 : 8),
          painter: _TrianglePainter(color: AppColors.error),
        ),
      ],
    );
  }
}

/// Custom painter for compass dial
class _CompassDialPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;
  final bool isTablet;

  _CompassDialPainter({
    required this.isDark,
    required this.primaryColor,
    required this.isTablet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw cardinal directions
    final cardinalStyle = TextStyle(
      fontSize: isTablet ? 18 : 15,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );

    final ordinalStyle = TextStyle(
      fontSize: isTablet ? 14 : 12,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
    );

    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final angles = [0, 45, 90, 135, 180, 225, 270, 315];

    for (var i = 0; i < directions.length; i++) {
      final angle = angles[i] * pi / 180 - pi / 2;
      final isCardinal = i % 2 == 0;
      final textRadius = radius - (isTablet ? 30 : 25);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: isCardinal ? cardinalStyle : ordinalStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final x = center.dx + textRadius * cos(angle) - textPainter.width / 2;
      final y = center.dy + textRadius * sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(x, y));
    }

    // Draw degree marks
    final tickPaint = Paint()
      ..color = isDark
          ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
          : AppColors.textSecondary.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 360; i += 5) {
      final angle = i * pi / 180 - pi / 2;
      final isMajor = i % 30 == 0;
      final isMinor = i % 15 == 0;

      double startRadius;
      double endRadius;

      if (isMajor) {
        startRadius = radius - (isTablet ? 50 : 42);
        endRadius = radius - (isTablet ? 58 : 50);
        tickPaint.strokeWidth = 2;
      } else if (isMinor) {
        startRadius = radius - (isTablet ? 50 : 42);
        endRadius = radius - (isTablet ? 54 : 46);
        tickPaint.strokeWidth = 1.5;
      } else {
        startRadius = radius - (isTablet ? 50 : 42);
        endRadius = radius - (isTablet ? 52 : 44);
        tickPaint.strokeWidth = 1;
      }

      final startX = center.dx + startRadius * cos(angle);
      final startY = center.dy + startRadius * sin(angle);
      final endX = center.dx + endRadius * cos(angle);
      final endY = center.dy + endRadius * sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        tickPaint,
      );
    }

    // Draw inner circle
    final innerCirclePaint = Paint()
      ..color = isDark
          ? AppColors.darkCard
          : Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, isTablet ? 55 : 45, innerCirclePaint);

    // Draw inner circle border
    final borderPaint = Paint()
      ..color = isDark
          ? AppColors.dividerDark
          : AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, isTablet ? 55 : 45, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) {
    return isDark != oldDelegate.isDark;
  }
}

/// Triangle pointer painter
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
