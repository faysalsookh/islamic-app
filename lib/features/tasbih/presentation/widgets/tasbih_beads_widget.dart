import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/services/tasbih_service.dart';

/// Animated prayer beads visualization with realistic wood grain effect
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
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final width = widget.isTablet ? min(500.0, screenWidth - 40) : min(360.0, screenWidth - 20);
    final height = widget.isTablet ? 120.0 : 90.0;

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
    final beadRadius = isTablet ? 22.0 : 16.0;
    final stringWidth = isTablet ? 2.5 : 2.0;
    final visibleBeads = 10;

    // Get gradient colors for bead style
    final gradientValues = TasbihService.getBeadGradientValues(beadStyle);
    final gradientColors = gradientValues.map((v) => Color(v)).toList();

    // Calculate positions along a curve (catenary-like)
    final curveHeight = size.height * 0.35;
    final startX = beadRadius + 5;
    final endX = size.width - beadRadius - 5;
    final beadSpacing = (endX - startX) / (visibleBeads - 1);

    // Draw string first (curved line behind beads)
    final stringPath = Path();
    final stringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = stringWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate string path points
    List<Offset> beadPositions = [];
    for (int i = 0; i < visibleBeads; i++) {
      final t = i / (visibleBeads - 1);
      final x = startX + i * beadSpacing;
      // Use catenary-like curve (parabola)
      final normalizedT = (t - 0.5) * 2; // -1 to 1
      final y = size.height * 0.5 + (1 - normalizedT * normalizedT) * curveHeight;
      beadPositions.add(Offset(x, y));
    }

    // Draw smooth curve through bead positions
    for (int i = 0; i < beadPositions.length - 1; i++) {
      final p1 = beadPositions[i];
      final p2 = beadPositions[i + 1];

      if (i == 0) {
        stringPath.moveTo(p1.dx, p1.dy);
      }

      // Use quadratic bezier for smooth curve
      final midX = (p1.dx + p2.dx) / 2;
      final midY = (p1.dy + p2.dy) / 2 + 2;
      stringPath.quadraticBezierTo(midX, midY + 5, p2.dx, p2.dy);
    }

    canvas.drawPath(stringPath, stringPaint);

    // Calculate how many beads to show as "counted"
    final countedBeads = count % visibleBeads;

    // Draw beads with overlap effect (back to front)
    for (int drawIndex = 0; drawIndex < visibleBeads; drawIndex++) {
      // Draw from edges to center for proper overlap
      int i;
      if (drawIndex < visibleBeads / 2) {
        i = drawIndex;
      } else {
        i = visibleBeads - 1 - (drawIndex - visibleBeads ~/ 2);
      }

      final position = beadPositions[i];

      // Determine if this bead is "counted"
      final isCounted = i < countedBeads || (count > 0 && countedBeads == 0);

      // Animation bounce for the latest bead
      final isLatestBead = count > 0 &&
          i == (countedBeads > 0 ? countedBeads - 1 : visibleBeads - 1);
      final bounceOffset = isLatestBead ? sin(animationValue * pi * 2) * 8 * (1 - animationValue) : 0.0;
      final scaleEffect = isLatestBead ? 1 + (0.15 * sin(animationValue * pi)) : 1.0;

      _drawBead(
        canvas,
        Offset(position.dx, position.dy - bounceOffset),
        beadRadius * scaleEffect,
        gradientColors,
        isCounted,
        isLatestBead && animationValue < 0.8,
        i, // Pass index for wood grain variation
      );
    }

    // Draw string ends extending from edges
    final leftEnd = beadPositions.first;
    final rightEnd = beadPositions.last;

    // Left string extension
    canvas.drawLine(
      Offset(0, leftEnd.dy + 5),
      leftEnd,
      stringPaint,
    );

    // Right string extension with slight curve down
    final extendPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = stringWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      rightEnd,
      Offset(size.width, rightEnd.dy + 8),
      extendPaint,
    );
  }

  void _drawBead(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> gradientColors,
    bool isCounted,
    bool isAnimating,
    int index,
  ) {
    // Outer shadow (more prominent)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center + const Offset(2, 4), radius, shadowPaint);

    // Base bead color
    final baseGradient = RadialGradient(
      center: const Alignment(-0.4, -0.4),
      radius: 1.2,
      colors: isCounted
          ? gradientColors
          : gradientColors.map((c) => c.withValues(alpha: 0.5)).toList(),
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, basePaint);

    // Wood grain effect (multiple curved lines)
    if (beadStyle == TasbihBeadStyle.wooden ||
        beadStyle == TasbihBeadStyle.amber) {
      _drawWoodGrain(canvas, center, radius, gradientColors, isCounted, index);
    }

    // Inner shadow for depth
    final innerShadowGradient = RadialGradient(
      center: const Alignment(0.5, 0.5),
      radius: 1.0,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: isCounted ? 0.3 : 0.15),
      ],
    );

    final innerShadowPaint = Paint()
      ..shader = innerShadowGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, innerShadowPaint);

    // Primary highlight (top-left)
    final highlightGradient = RadialGradient(
      center: const Alignment(-0.6, -0.6),
      radius: 0.6,
      colors: [
        Colors.white.withValues(alpha: isCounted ? 0.7 : 0.3),
        Colors.white.withValues(alpha: 0),
      ],
    );

    final highlightPaint = Paint()
      ..shader = highlightGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, highlightPaint);

    // Secondary smaller highlight
    final smallHighlight = Paint()
      ..color = Colors.white.withValues(alpha: isCounted ? 0.8 : 0.3);
    canvas.drawCircle(
      center + Offset(-radius * 0.4, -radius * 0.4),
      radius * 0.15,
      smallHighlight,
    );

    // Rim highlight
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: isCounted ? 0.2 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 1, rimPaint);

    // Glow effect for animating bead
    if (isAnimating) {
      final glowPaint = Paint()
        ..color = gradientColors[0].withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius + 6, glowPaint);
    }

    // Center hole hint (string hole)
    final holePaint = Paint()
      ..color = Colors.black.withValues(alpha: isCounted ? 0.3 : 0.15);
    canvas.drawCircle(center, radius * 0.08, holePaint);
  }

  void _drawWoodGrain(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> gradientColors,
    bool isCounted,
    int index,
  ) {
    // Create wood grain lines
    final grainPaint = Paint()
      ..color = gradientColors[2].withValues(alpha: isCounted ? 0.4 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw curved grain lines based on bead index for variation
    final grainCount = 4 + (index % 3);
    for (int i = 0; i < grainCount; i++) {
      final offset = (i - grainCount / 2) * (radius * 0.3);
      final path = Path();

      // Create curved line across the bead
      final startY = center.dy - radius * 0.7;
      final endY = center.dy + radius * 0.7;

      path.moveTo(center.dx + offset - radius * 0.2, startY);
      path.quadraticBezierTo(
        center.dx + offset + (i % 2 == 0 ? 5 : -5),
        center.dy,
        center.dx + offset + radius * 0.1,
        endY,
      );

      // Clip to circle
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.9)));
      canvas.drawPath(path, grainPaint);
      canvas.restore();
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
