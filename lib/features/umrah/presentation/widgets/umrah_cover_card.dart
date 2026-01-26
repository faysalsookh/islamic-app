import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Cover card for Umrah Dua collection with Kaaba illustration
class UmrahCoverCard extends StatelessWidget {
  final int totalDuas;
  final VoidCallback? onStart;

  const UmrahCoverCard({
    super.key,
    required this.totalDuas,
    this.onStart,
  });

  static const Color _cardBackground = Color(0xFFFAF6F1);
  static const Color _primaryBrown = Color(0xFF6D4C3D);
  static const Color _goldAccent = Color(0xFFD4A853);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [


            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate responsive sizes based on available height
                  final availableHeight = constraints.maxHeight;
                  final kaabaHeight = (availableHeight * 0.28).clamp(120.0, 180.0);
                  final titleFontSize = (availableHeight * 0.07).clamp(32.0, 48.0);
                  final subtitleFontSize = (availableHeight * 0.05).clamp(24.0, 36.0);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bismillah
                      Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          color: _goldAccent,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Title section
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'UMRAH',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: _primaryBrown,
                              letterSpacing: 6,
                            ),
                          ),
                          Text(
                            'Dua Card',
                            style: GoogleFonts.dancingScript(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: _primaryBrown.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),

                      //Kaaba illustration
                      SizedBox(
                        height: kaabaHeight,
                        width: kaabaHeight * 1.4,
                        child: Image.asset("assets/images/meccan.png")
                      ),

                      // Dua count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '$totalDuas Essential Duas',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _primaryBrown,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      // Swipe instruction
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.swipe_rounded,
                            size: 18,
                            color: _primaryBrown.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Swipe to begin',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: _primaryBrown.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Background painter for the cover card
class _CoverBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw subtle clouds/mountains in background
    paint.color = const Color(0xFFE8DFD5);

    // Left mountain
    final leftMountain = Path();
    leftMountain.moveTo(0, size.height * 0.7);
    leftMountain.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.5,
      size.width * 0.3,
      size.height * 0.65,
    );
    leftMountain.lineTo(0, size.height * 0.65);
    leftMountain.close();
    canvas.drawPath(leftMountain, paint);

    // Right mountain
    final rightMountain = Path();
    rightMountain.moveTo(size.width, size.height * 0.7);
    rightMountain.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.65,
    );
    rightMountain.lineTo(size.width, size.height * 0.65);
    rightMountain.close();
    canvas.drawPath(rightMountain, paint);

    // Decorative stars
    paint.color = const Color(0xFFD4A853).withValues(alpha: 0.3);
    _drawStar(canvas, Offset(size.width * 0.15, size.height * 0.15), 4, paint);
    _drawStar(canvas, Offset(size.width * 0.85, size.height * 0.12), 3, paint);
    _drawStar(canvas, Offset(size.width * 0.75, size.height * 0.2), 2, paint);
    _drawStar(canvas, Offset(size.width * 0.25, size.height * 0.22), 2.5, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) - math.pi / 4;
      final outerPoint = Offset(
        center.dx + math.cos(angle) * size,
        center.dy + math.sin(angle) * size,
      );
      final innerAngle = angle + math.pi / 4;
      final innerPoint = Offset(
        center.dx + math.cos(innerAngle) * size * 0.4,
        center.dy + math.sin(innerAngle) * size * 0.4,
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for Kaaba illustration
class _KaabaIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.85;

    // Colors
    const kaabaBlack = Color(0xFF1A1A1A);
    const goldStripe = Color(0xFFD4A853);
    const brownBase = Color(0xFF8B6914);
    const cream = Color(0xFFF5EDE4);

    // Draw minarets
    _drawMinaret(canvas, Offset(size.width * 0.1, baseY), size.height * 0.6, goldStripe);
    _drawMinaret(canvas, Offset(size.width * 0.9, baseY), size.height * 0.6, goldStripe);

    // Draw small lanterns
    _drawLantern(canvas, Offset(size.width * 0.2, baseY - size.height * 0.3), 15, goldStripe);
    _drawLantern(canvas, Offset(size.width * 0.8, baseY - size.height * 0.3), 15, goldStripe);

    // Draw crescent and star
    _drawCrescentAndStar(canvas, Offset(centerX, size.height * 0.15), goldStripe);

    // Draw Kaaba base (brick)
    final basePaint = Paint()..color = brownBase;
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY - 10),
        width: size.width * 0.45,
        height: 20,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(baseRect, basePaint);

    // Draw Kaaba main body
    final kaabaPaint = Paint()..color = kaabaBlack;
    final kaabaPath = Path();

    // 3D isometric view of Kaaba
    final kaabaWidth = size.width * 0.4;
    final kaabaHeight = size.height * 0.45;
    final depth = kaabaWidth * 0.3;

    // Front face
    kaabaPath.moveTo(centerX - kaabaWidth / 2, baseY - 20);
    kaabaPath.lineTo(centerX - kaabaWidth / 2, baseY - 20 - kaabaHeight);
    kaabaPath.lineTo(centerX + kaabaWidth / 2, baseY - 20 - kaabaHeight);
    kaabaPath.lineTo(centerX + kaabaWidth / 2, baseY - 20);
    kaabaPath.close();
    canvas.drawPath(kaabaPath, kaabaPaint);

    // Right side face (darker)
    final sidePaint = Paint()..color = const Color(0xFF0D0D0D);
    final sidePath = Path();
    sidePath.moveTo(centerX + kaabaWidth / 2, baseY - 20);
    sidePath.lineTo(centerX + kaabaWidth / 2, baseY - 20 - kaabaHeight);
    sidePath.lineTo(centerX + kaabaWidth / 2 + depth, baseY - 20 - kaabaHeight + depth * 0.3);
    sidePath.lineTo(centerX + kaabaWidth / 2 + depth, baseY - 20 + depth * 0.3);
    sidePath.close();
    canvas.drawPath(sidePath, sidePaint);

    // Top face
    final topPaint = Paint()..color = const Color(0xFF2A2A2A);
    final topPath = Path();
    topPath.moveTo(centerX - kaabaWidth / 2, baseY - 20 - kaabaHeight);
    topPath.lineTo(centerX - kaabaWidth / 2 + depth, baseY - 20 - kaabaHeight + depth * 0.3);
    topPath.lineTo(centerX + kaabaWidth / 2 + depth, baseY - 20 - kaabaHeight + depth * 0.3);
    topPath.lineTo(centerX + kaabaWidth / 2, baseY - 20 - kaabaHeight);
    topPath.close();
    canvas.drawPath(topPath, topPaint);

    // Gold stripe (Kiswah band)
    final stripePaint = Paint()
      ..color = goldStripe
      ..style = PaintingStyle.fill;
    final stripeY = baseY - 20 - kaabaHeight * 0.65;
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - kaabaWidth / 2,
        stripeY,
        kaabaWidth,
        kaabaHeight * 0.08,
      ),
      stripePaint,
    );

    // Kiswah bottom decoration (scalloped edge)
    final kiswahPaint = Paint()
      ..color = cream.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final kiswahY = baseY - 25;
    final scallops = 8;
    final scallopWidth = kaabaWidth / scallops;

    for (int i = 0; i < scallops; i++) {
      final x = centerX - kaabaWidth / 2 + i * scallopWidth + scallopWidth / 2;
      final path = Path();
      path.moveTo(x - scallopWidth / 2, kiswahY - 15);
      path.quadraticBezierTo(
        x,
        kiswahY,
        x + scallopWidth / 2,
        kiswahY - 15,
      );
      path.lineTo(x + scallopWidth / 2, kiswahY - 30);
      path.lineTo(x - scallopWidth / 2, kiswahY - 30);
      path.close();
      canvas.drawPath(path, kiswahPaint);
    }

    // Draw pilgrims (simplified)
    _drawPilgrim(canvas, Offset(centerX - kaabaWidth / 2 - 25, baseY - 15), true);
    _drawPilgrim(canvas, Offset(centerX + kaabaWidth / 2 + 40, baseY - 15), false);
  }

  void _drawMinaret(Canvas canvas, Offset base, double height, Color color) {
    final paint = Paint()..color = color;

    // Minaret body
    final bodyWidth = 12.0;
    canvas.drawRect(
      Rect.fromLTWH(base.dx - bodyWidth / 2, base.dy - height, bodyWidth, height),
      paint,
    );

    // Minaret top
    final topPath = Path();
    topPath.moveTo(base.dx - bodyWidth / 2 - 4, base.dy - height);
    topPath.lineTo(base.dx, base.dy - height - 20);
    topPath.lineTo(base.dx + bodyWidth / 2 + 4, base.dy - height);
    topPath.close();
    canvas.drawPath(topPath, paint);

    // Decorative bands
    paint.color = color.withValues(alpha: 0.6);
    for (int i = 1; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          base.dx - bodyWidth / 2 - 2,
          base.dy - height + i * height / 4,
          bodyWidth + 4,
          3,
        ),
        paint,
      );
    }
  }

  void _drawLantern(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;

    // Lantern body
    final bodyPath = Path();
    bodyPath.moveTo(center.dx - size / 2, center.dy);
    bodyPath.lineTo(center.dx - size / 3, center.dy - size);
    bodyPath.lineTo(center.dx + size / 3, center.dy - size);
    bodyPath.lineTo(center.dx + size / 2, center.dy);
    bodyPath.lineTo(center.dx + size / 3, center.dy + size * 0.3);
    bodyPath.lineTo(center.dx - size / 3, center.dy + size * 0.3);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);

    // Lantern glow
    paint.color = const Color(0xFFFFE082).withValues(alpha: 0.5);
    canvas.drawCircle(center, size * 0.3, paint);

    // Hook
    paint.color = color;
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy - size - 10),
      paint..strokeWidth = 2,
    );
  }

  void _drawCrescentAndStar(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;

    // Crescent
    final crescentPath = Path();
    crescentPath.addArc(
      Rect.fromCircle(center: center, radius: 15),
      -math.pi / 2,
      math.pi * 1.5,
    );
    crescentPath.addArc(
      Rect.fromCircle(center: Offset(center.dx + 5, center.dy), radius: 12),
      math.pi,
      -math.pi * 1.5,
    );
    canvas.drawPath(crescentPath, paint);

    // Star
    _drawSixPointStar(
      canvas,
      Offset(center.dx + 25, center.dy - 5),
      8,
      paint,
    );
  }

  void _drawSixPointStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) - math.pi / 2;
      final outerPoint = Offset(
        center.dx + math.cos(angle) * size,
        center.dy + math.sin(angle) * size,
      );
      final innerAngle = angle + math.pi / 6;
      final innerPoint = Offset(
        center.dx + math.cos(innerAngle) * size * 0.5,
        center.dy + math.sin(innerAngle) * size * 0.5,
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  void _drawPilgrim(Canvas canvas, Offset base, bool facingRight) {
    final paint = Paint();

    // Ihram (white garment)
    paint.color = const Color(0xFFF5EDE4);
    final bodyPath = Path();
    final direction = facingRight ? 1.0 : -1.0;

    // Body
    bodyPath.moveTo(base.dx, base.dy);
    bodyPath.quadraticBezierTo(
      base.dx + direction * 15,
      base.dy - 25,
      base.dx + direction * 5,
      base.dy - 40,
    );
    bodyPath.quadraticBezierTo(
      base.dx - direction * 10,
      base.dy - 25,
      base.dx,
      base.dy,
    );
    canvas.drawPath(bodyPath, paint);

    // Head
    paint.color = const Color(0xFFD4A27C);
    canvas.drawCircle(Offset(base.dx + direction * 5, base.dy - 45), 8, paint);

    // Raised hands (dua position)
    paint.color = const Color(0xFFD4A27C);
    canvas.drawCircle(Offset(base.dx + direction * 20, base.dy - 35), 4, paint);
    canvas.drawCircle(Offset(base.dx - direction * 5, base.dy - 35), 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
