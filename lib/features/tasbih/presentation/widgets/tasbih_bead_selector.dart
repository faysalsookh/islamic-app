import 'package:flutter/material.dart';
import '../../../../core/services/tasbih_service.dart';
import '../../../../core/services/haptic_service.dart';

/// Horizontal bead style selector
class TasbihBeadSelector extends StatelessWidget {
  final TasbihBeadStyle selectedStyle;
  final ValueChanged<TasbihBeadStyle> onStyleChanged;
  final bool isTablet;

  const TasbihBeadSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleChanged,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemSize = isTablet ? 56.0 : 48.0;

    return SizedBox(
      height: itemSize + 8,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
        itemCount: TasbihBeadStyle.values.length,
        itemBuilder: (context, index) {
          final style = TasbihBeadStyle.values[index];
          final isSelected = style == selectedStyle;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6),
            child: GestureDetector(
              onTap: () {
                HapticService().lightImpact();
                onStyleChanged(style);
              },
              child: _BeadStyleItem(
                style: style,
                isSelected: isSelected,
                size: itemSize,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BeadStyleItem extends StatelessWidget {
  final TasbihBeadStyle style;
  final bool isSelected;
  final double size;

  const _BeadStyleItem({
    required this.style,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final gradientValues = TasbihService.getBeadGradientValues(style);
    final gradientColors = gradientValues.map((v) => Color(v)).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? const Color(0xFF4CAF50)
              : Colors.white.withValues(alpha: 0.2),
          width: isSelected ? 3 : 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
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
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 1.0,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.5, -0.5),
              radius: 0.8,
              colors: [
                Colors.white.withValues(alpha: 0.5),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
