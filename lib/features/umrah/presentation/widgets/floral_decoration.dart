import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom painter for elegant floral decoration at the top of cards
/// Inspired by sepia-toned botanical illustrations
class FloralDecorationPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double opacity;

  FloralDecorationPainter({
    this.primaryColor = const Color(0xFF8B5A3C),
    this.secondaryColor = const Color(0xFFBE9B7B),
    this.opacity = 0.85,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw left side florals
    _drawFloralCluster(
      canvas,
      Offset(size.width * 0.15, size.height * 0.3),
      size.width * 0.35,
      paint,
      isLeft: true,
    );

    // Draw right side florals
    _drawFloralCluster(
      canvas,
      Offset(size.width * 0.85, size.height * 0.3),
      size.width * 0.35,
      paint,
      isLeft: false,
    );

    // Draw top center accent
    _drawTopCenterAccent(canvas, size, paint);
  }

  void _drawFloralCluster(
    Canvas canvas,
    Offset center,
    double scale,
    Paint paint, {
    required bool isLeft,
  }) {
    final direction = isLeft ? 1.0 : -1.0;

    // Draw main flower
    _drawFlower(
      canvas,
      Offset(center.dx + direction * scale * 0.1, center.dy - scale * 0.2),
      scale * 0.25,
      paint,
      petals: 5,
    );

    // Draw secondary flower
    _drawFlower(
      canvas,
      Offset(center.dx + direction * scale * 0.35, center.dy + scale * 0.1),
      scale * 0.18,
      paint,
      petals: 6,
    );

    // Draw buds
    _drawBud(
      canvas,
      Offset(center.dx - direction * scale * 0.1, center.dy + scale * 0.3),
      scale * 0.08,
      paint,
      angle: isLeft ? -0.3 : 0.3,
    );

    _drawBud(
      canvas,
      Offset(center.dx + direction * scale * 0.5, center.dy - scale * 0.1),
      scale * 0.06,
      paint,
      angle: isLeft ? 0.5 : -0.5,
    );

    // Draw leaves
    _drawLeaf(
      canvas,
      Offset(center.dx + direction * scale * 0.2, center.dy + scale * 0.4),
      scale * 0.15,
      paint,
      angle: isLeft ? 0.8 : -0.8,
    );

    _drawLeaf(
      canvas,
      Offset(center.dx + direction * scale * 0.45, center.dy + scale * 0.35),
      scale * 0.12,
      paint,
      angle: isLeft ? 0.4 : -0.4,
    );

    // Draw connecting stems
    _drawStem(
      canvas,
      center,
      Offset(center.dx + direction * scale * 0.1, center.dy - scale * 0.2),
      paint,
    );

    _drawStem(
      canvas,
      center,
      Offset(center.dx + direction * scale * 0.35, center.dy + scale * 0.1),
      paint,
    );
  }

  void _drawFlower(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint, {
    int petals = 5,
  }) {
    // Outer petals
    paint
      ..color = primaryColor.withValues(alpha: opacity * 0.7)
      ..strokeWidth = 1.5;

    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi / petals) - math.pi / 2;
      final petalCenter = Offset(
        center.dx + math.cos(angle) * radius * 0.6,
        center.dy + math.sin(angle) * radius * 0.6,
      );

      // Draw petal outline
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx + math.cos(angle - 0.3) * radius,
        center.dy + math.sin(angle - 0.3) * radius,
        petalCenter.dx + math.cos(angle) * radius * 0.5,
        petalCenter.dy + math.sin(angle) * radius * 0.5,
      );
      path.quadraticBezierTo(
        center.dx + math.cos(angle + 0.3) * radius,
        center.dy + math.sin(angle + 0.3) * radius,
        center.dx,
        center.dy,
      );
      canvas.drawPath(path, paint);
    }

    // Center of flower
    paint
      ..color = secondaryColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.15, paint);

    paint
      ..color = primaryColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.15, paint);

    // Inner details
    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi / petals) - math.pi / 2;
      final start = Offset(
        center.dx + math.cos(angle) * radius * 0.2,
        center.dy + math.sin(angle) * radius * 0.2,
      );
      final end = Offset(
        center.dx + math.cos(angle) * radius * 0.4,
        center.dy + math.sin(angle) * radius * 0.4,
      );
      paint
        ..color = primaryColor.withValues(alpha: opacity * 0.5)
        ..strokeWidth = 0.8;
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawBud(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint, {
    double angle = 0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();

    // Bud shape
    path.moveTo(0, size);
    path.quadraticBezierTo(-size * 0.8, 0, 0, -size * 1.5);
    path.quadraticBezierTo(size * 0.8, 0, 0, size);

    paint
      ..color = primaryColor.withValues(alpha: opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, paint);

    // Bud details
    paint
      ..color = primaryColor.withValues(alpha: opacity * 0.4)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(0, size * 0.5), Offset(0, -size * 0.8), paint);

    canvas.restore();
  }

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint, {
    double angle = 0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();

    // Leaf shape
    path.moveTo(0, size);
    path.quadraticBezierTo(-size * 0.6, size * 0.3, -size * 0.3, -size * 0.8);
    path.quadraticBezierTo(0, -size * 1.2, size * 0.3, -size * 0.8);
    path.quadraticBezierTo(size * 0.6, size * 0.3, 0, size);

    paint
      ..color = primaryColor.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, paint);

    // Leaf vein
    paint
      ..color = primaryColor.withValues(alpha: opacity * 0.3)
      ..strokeWidth = 0.6;
    canvas.drawLine(Offset(0, size * 0.8), Offset(0, -size * 0.6), paint);

    // Side veins
    for (int i = 0; i < 3; i++) {
      final y = size * 0.4 - i * size * 0.35;
      canvas.drawLine(
        Offset(0, y),
        Offset(-size * 0.2, y - size * 0.15),
        paint,
      );
      canvas.drawLine(
        Offset(0, y),
        Offset(size * 0.2, y - size * 0.15),
        paint,
      );
    }

    canvas.restore();
  }

  void _drawStem(Canvas canvas, Offset start, Offset end, Paint paint) {
    paint
      ..color = primaryColor.withValues(alpha: opacity * 0.4)
      ..strokeWidth = 1.0;

    final controlPoint = Offset(
      (start.dx + end.dx) / 2 + (end.dx - start.dx) * 0.2,
      (start.dy + end.dy) / 2,
    );

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  void _drawTopCenterAccent(Canvas canvas, Size size, Paint paint) {
    // Small decorative dots at top center
    paint
      ..color = secondaryColor.withValues(alpha: opacity * 0.4)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final topY = size.height * 0.15;

    canvas.drawCircle(Offset(centerX, topY), 2, paint);
    canvas.drawCircle(Offset(centerX - 15, topY + 5), 1.5, paint);
    canvas.drawCircle(Offset(centerX + 15, topY + 5), 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant FloralDecorationPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.opacity != opacity;
  }
}

/// Widget wrapper for the floral decoration
class FloralDecoration extends StatelessWidget {
  final double height;
  final Color? primaryColor;
  final Color? secondaryColor;

  const FloralDecoration({
    super.key,
    this.height = 120,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: FloralDecorationPainter(
        primaryColor: primaryColor ?? const Color(0xFF8B5A3C),
        secondaryColor: secondaryColor ?? const Color(0xFFBE9B7B),
      ),
    );
  }
}
