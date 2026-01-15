import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom painter for subtle Islamic geometric patterns
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final PatternType patternType;

  IslamicPatternPainter({
    this.color = AppColors.softRose,
    this.opacity = 0.1,
    this.patternType = PatternType.geometric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    switch (patternType) {
      case PatternType.geometric:
        _drawGeometricPattern(canvas, size, paint);
        break;
      case PatternType.stars:
        _drawStarPattern(canvas, size, paint);
        break;
      case PatternType.arabesque:
        _drawArabesquePattern(canvas, size, paint);
        break;
    }
  }

  void _drawGeometricPattern(Canvas canvas, Size size, Paint paint) {
    const spacing = 60.0;
    final rows = (size.height / spacing).ceil() + 1;
    final cols = (size.width / spacing).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = col * spacing;
        final y = row * spacing;
        _drawOctagon(canvas, Offset(x, y), spacing / 2.5, paint);
      }
    }
  }

  void _drawOctagon(Canvas canvas, Offset center, double radius, Paint paint) {
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

  void _drawStarPattern(Canvas canvas, Size size, Paint paint) {
    const spacing = 80.0;
    final rows = (size.height / spacing).ceil() + 1;
    final cols = (size.width / spacing).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = col * spacing + (row.isOdd ? spacing / 2 : 0);
        final y = row * spacing;
        _drawSixPointStar(canvas, Offset(x, y), spacing / 3, paint);
      }
    }
  }

  void _drawSixPointStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    // First triangle (pointing up)
    for (var i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Second triangle (pointing down)
    for (var i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) + math.pi / 2;
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

  void _drawArabesquePattern(Canvas canvas, Size size, Paint paint) {
    const spacing = 100.0;
    final rows = (size.height / spacing).ceil() + 1;
    final cols = (size.width / spacing).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = col * spacing;
        final y = row * spacing;
        _drawFlowerMotif(canvas, Offset(x, y), spacing / 3, paint);
      }
    }
  }

  void _drawFlowerMotif(
      Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw petals
    const petals = 6;
    for (var i = 0; i < petals; i++) {
      final angle = i * 2 * math.pi / petals;
      final petalCenter = Offset(
        center.dx + (radius / 2) * math.cos(angle),
        center.dy + (radius / 2) * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, radius / 3, paint);
    }
    // Draw center
    canvas.drawCircle(center, radius / 4, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.patternType != patternType;
  }
}

enum PatternType {
  geometric,
  stars,
  arabesque,
}

/// Widget wrapper for the pattern painter
class IslamicPatternBackground extends StatelessWidget {
  final Widget child;
  final Color patternColor;
  final double opacity;
  final PatternType patternType;

  const IslamicPatternBackground({
    super.key,
    required this.child,
    this.patternColor = AppColors.softRose,
    this.opacity = 0.08,
    this.patternType = PatternType.geometric,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicPatternPainter(
              color: patternColor,
              opacity: opacity,
              patternType: patternType,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
