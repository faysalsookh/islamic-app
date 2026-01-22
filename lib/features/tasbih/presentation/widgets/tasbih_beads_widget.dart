import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/services/tasbih_service.dart';

/// Animated prayer beads visualization
class TasbihBeadsWidget extends StatefulWidget {
  final int count;
  final int target;
  final TasbihBeadStyle beadStyle;
  final bool isTablet;

  const TasbihBeadsWidget({
    super.key,
    required this.count,
    required this.target,
    required this.beadStyle,
    this.isTablet = false,
  });

  @override
  State<TasbihBeadsWidget> createState() => _TasbihBeadsWidgetState();
}

class _TasbihBeadsWidgetState extends State<TasbihBeadsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.count;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(TasbihBeadsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != _lastCount) {
      _controller.forward(from: 0);
      _lastCount = widget.count;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.isTablet ? 400.0 : 320.0;
    final height = widget.isTablet ? 100.0 : 80.0;

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _BeadsPainter(
              count: widget.count,
              target: widget.target,
              beadStyle: widget.beadStyle,
              animationValue: _animation.value,
              isTablet: widget.isTablet,
            ),
          );
        },
      ),
    );
  }
}

class _BeadsPainter extends CustomPainter {
  final int count;
  final int target;
  final TasbihBeadStyle beadStyle;
  final double animationValue;
  final bool isTablet;

  _BeadsPainter({
    required this.count,
    required this.target,
    required this.beadStyle,
    required this.animationValue,
    required this.isTablet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final beadRadius = isTablet ? 18.0 : 14.0;
    final stringWidth = isTablet ? 3.0 : 2.0;
    final visibleBeads = 10;

    // Get gradient colors for bead style
    final gradientValues = TasbihService.getBeadGradientValues(beadStyle);
    final gradientColors = gradientValues.map((v) => Color(v)).toList();

    // Calculate positions along a curve
    final curveHeight = size.height * 0.4;
    final startX = size.width * 0.05;
    final endX = size.width * 0.95;
    final beadSpacing = (endX - startX) / (visibleBeads - 1);

    // Draw string first (curved line)
    final stringPath = Path();
    final stringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = stringWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= visibleBeads * 10; i++) {
      final t = i / (visibleBeads * 10);
      final x = startX + t * (endX - startX);
      final y = size.height / 2 + sin(t * pi) * curveHeight;

      if (i == 0) {
        stringPath.moveTo(x, y);
      } else {
        stringPath.lineTo(x, y);
      }
    }
    canvas.drawPath(stringPath, stringPaint);

    // Calculate how many beads to show as "counted"
    final countedBeads = (count % visibleBeads);

    // Draw beads
    for (int i = 0; i < visibleBeads; i++) {
      final t = i / (visibleBeads - 1);
      final x = startX + i * beadSpacing;
      final y = size.height / 2 + sin(t * pi) * curveHeight;

      // Determine if this bead is "counted"
      final isCounted = i < countedBeads || (count > 0 && count % visibleBeads == 0);

      // Animation bounce for the latest bead
      final isLatestBead = i == (countedBeads > 0 ? countedBeads - 1 : visibleBeads - 1) && count > 0;
      final bounceOffset = isLatestBead ? sin(animationValue * pi) * 5 : 0.0;

      _drawBead(
        canvas,
        Offset(x, y - bounceOffset),
        beadRadius,
        gradientColors,
        isCounted,
        isLatestBead && animationValue < 1,
      );
    }

    // Draw string end decoration (tassel hint)
    final tasselPaint = Paint()
      ..color = Color(gradientValues[1])
      ..strokeWidth = stringWidth * 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tasselStartX = endX;
    final tasselStartY = size.height / 2 + sin(pi) * curveHeight;
    canvas.drawLine(
      Offset(tasselStartX, tasselStartY),
      Offset(tasselStartX + 20, tasselStartY + 15),
      tasselPaint,
    );
  }

  void _drawBead(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> gradientColors,
    bool isCounted,
    bool isAnimating,
  ) {
    // Outer shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(2, 3), radius, shadowPaint);

    // Main bead gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: isCounted
          ? gradientColors
          : gradientColors.map((c) => c.withValues(alpha: 0.4)).toList(),
    );

    final beadPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, beadPaint);

    // Highlight
    final highlightGradient = RadialGradient(
      center: const Alignment(-0.5, -0.5),
      radius: 0.8,
      colors: [
        Colors.white.withValues(alpha: isCounted ? 0.6 : 0.2),
        Colors.white.withValues(alpha: 0),
      ],
    );

    final highlightPaint = Paint()
      ..shader = highlightGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, highlightPaint);

    // Glow effect for animating bead
    if (isAnimating) {
      final glowPaint = Paint()
        ..color = gradientColors[0].withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius + 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BeadsPainter oldDelegate) {
    return count != oldDelegate.count ||
        target != oldDelegate.target ||
        beadStyle != oldDelegate.beadStyle ||
        animationValue != oldDelegate.animationValue;
  }
}
