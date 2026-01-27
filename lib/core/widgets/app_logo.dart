import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// App Logo - Rushd
/// Design: Simple vertical light line/path motif symbolizing guidance (Sirat al-Mustaqim)
class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final bool isLightMode;

  const AppLogo({
    super.key,
    this.width = 40,
    this.height = 40,
    this.color,
    this.isLightMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? (isLightMode ? AppColors.mutedTeal : AppColors.darkTealAccent);
    
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _LogoPainter(color: effectiveColor),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Center point
    final cx = size.width / 2;
    
    // Main vertical path (Guidance)
    final pathPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Glow effect for the "Light"
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = size.width * 0.25
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Start from bottom, slightly wider base implied by tapering if we could, 
    // but a straight strong line is "Calm, Confident"
    path.moveTo(cx, size.height * 0.85);
    path.lineTo(cx, size.height * 0.15);

    // Draw glow
    canvas.drawPath(path, glowPaint);
    
    // Draw main path
    canvas.drawPath(path, pathPaint);
    
    // Draw the "Light" at the top (Symbolizing the destination/divine guidance)
    // A small diamond or circle shape at the top
    final lightPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    // Diamond shape at the top
    // final diamondPath = Path();
    // final topY = size.height * 0.15;
    // final diamondSize = size.width * 0.15;
    
    // diamondPath.moveTo(cx, topY - diamondSize);
    // diamondPath.lineTo(cx + diamondSize, topY);
    // diamondPath.lineTo(cx, topY + diamondSize);
    // diamondPath.lineTo(cx - diamondSize, topY);
    // diamondPath.close();
    
    // canvas.drawPath(diamondPath, lightPaint);
    
    // Or just a simple circle for "Minimal, Calm"
     canvas.drawCircle(Offset(cx, size.height * 0.15), size.width * 0.08, lightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
