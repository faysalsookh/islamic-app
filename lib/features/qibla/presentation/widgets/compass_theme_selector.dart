import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/haptic_service.dart';
import 'qibla_compass_widget.dart';

/// Horizontal selector for compass themes
class CompassThemeSelector extends StatelessWidget {
  final CompassTheme selectedTheme;
  final ValueChanged<CompassTheme> onThemeChanged;
  final bool isTablet;

  const CompassThemeSelector({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemSize = isTablet ? 64.0 : 52.0;

    return SizedBox(
      height: itemSize + 16,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
        itemCount: CompassTheme.values.length,
        itemBuilder: (context, index) {
          final theme = CompassTheme.values[index];
          final isSelected = theme == selectedTheme;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6),
            child: _CompassThemeItem(
              theme: theme,
              isSelected: isSelected,
              size: itemSize,
              onTap: () {
                HapticService().lightImpact();
                onThemeChanged(theme);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CompassThemeItem extends StatelessWidget {
  final CompassTheme theme;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  const _CompassThemeItem({
    required this.theme,
    required this.isSelected,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getThemePreviewColors(theme);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? colors.ring : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.ring.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.background,
            border: Border.all(
              color: colors.ring,
              width: 2,
            ),
          ),
          child: CustomPaint(
            painter: _MiniCompassPainter(
              backgroundColor: colors.background,
              ringColor: colors.ring,
              needleColor: colors.needle,
            ),
          ),
        ),
      ),
    );
  }

  _ThemePreviewColors _getThemePreviewColors(CompassTheme theme) {
    switch (theme) {
      case CompassTheme.classic:
        return _ThemePreviewColors(
          background: const Color(0xFF2C2C2C),
          ring: const Color(0xFFD2691E),
          needle: AppColors.forestGreen,
        );
      case CompassTheme.golden:
        return _ThemePreviewColors(
          background: const Color(0xFF1E1E1E),
          ring: const Color(0xFFD4A853),
          needle: const Color(0xFF4CAF50),
        );
      case CompassTheme.minimal:
        return _ThemePreviewColors(
          background: const Color(0xFFF5F5F5),
          ring: const Color(0xFF64B5F6),
          needle: const Color(0xFF2196F3),
        );
      case CompassTheme.elegant:
        return _ThemePreviewColors(
          background: const Color(0xFF1A1A2E),
          ring: const Color(0xFFE94560),
          needle: const Color(0xFFE94560),
        );
      case CompassTheme.nature:
        return _ThemePreviewColors(
          background: const Color(0xFF1B4332),
          ring: const Color(0xFF95D5B2),
          needle: const Color(0xFF95D5B2),
        );
    }
  }
}

class _ThemePreviewColors {
  final Color background;
  final Color ring;
  final Color needle;

  _ThemePreviewColors({
    required this.background,
    required this.ring,
    required this.needle,
  });
}

/// Mini compass preview painter
class _MiniCompassPainter extends CustomPainter {
  final Color backgroundColor;
  final Color ringColor;
  final Color needleColor;

  _MiniCompassPainter({
    required this.backgroundColor,
    required this.ringColor,
    required this.needleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw ticks
    final tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final angle = i * 3.14159 / 2;
      final startX = center.dx + (radius - 3) * -_sin(angle);
      final startY = center.dy + (radius - 3) * -_cos(angle);
      final endX = center.dx + (radius - 6) * -_sin(angle);
      final endY = center.dy + (radius - 6) * -_cos(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    // Draw needle
    final needlePath = Path();
    needlePath.moveTo(center.dx, center.dy - radius + 8);
    needlePath.lineTo(center.dx - 3, center.dy);
    needlePath.lineTo(center.dx + 3, center.dy);
    needlePath.close();

    final needlePaint = Paint()..color = needleColor;
    canvas.drawPath(needlePath, needlePaint);

    // Draw center dot
    canvas.drawCircle(center, 3, Paint()..color = ringColor);
  }

  double _sin(double angle) => _toDouble(angle, true);
  double _cos(double angle) => _toDouble(angle, false);

  double _toDouble(double angle, bool isSin) {
    if (isSin) {
      if (angle == 0) return 0;
      if (angle == 1.5708) return 1;
      if (angle == 3.14159) return 0;
      if (angle == 4.71239) return -1;
    } else {
      if (angle == 0) return 1;
      if (angle == 1.5708) return 0;
      if (angle == 3.14159) return -1;
      if (angle == 4.71239) return 0;
    }
    return 0;
  }

  @override
  bool shouldRepaint(covariant _MiniCompassPainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        ringColor != oldDelegate.ringColor ||
        needleColor != oldDelegate.needleColor;
  }
}
