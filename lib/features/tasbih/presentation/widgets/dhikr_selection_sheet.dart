import 'package:flutter/material.dart';
import '../../../../core/services/tasbih_service.dart';
import '../../../../core/services/haptic_service.dart';

/// Bottom sheet for selecting Dhikr presets
class DhikrSelectionSheet extends StatelessWidget {
  final Dhikr? selectedDhikr;
  final ValueChanged<Dhikr?> onDhikrSelected;

  const DhikrSelectionSheet({
    super.key,
    this.selectedDhikr,
    required this.onDhikrSelected,
  });

  static Future<void> show(
    BuildContext context, {
    Dhikr? selectedDhikr,
    required ValueChanged<Dhikr?> onDhikrSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DhikrSelectionSheet(
        selectedDhikr: selectedDhikr,
        onDhikrSelected: onDhikrSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select a Dhikr',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (selectedDhikr != null)
                  TextButton(
                    onPressed: () {
                      onDhikrSelected(null);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Dhikr list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: TasbihService.presetDhikrs.length,
              itemBuilder: (context, index) {
                final dhikr = TasbihService.presetDhikrs[index];
                final isSelected = selectedDhikr?.id == dhikr.id;

                return _DhikrListItem(
                  dhikr: dhikr,
                  isSelected: isSelected,
                  onTap: () {
                    HapticService().lightImpact();
                    onDhikrSelected(dhikr);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrListItem extends StatelessWidget {
  final Dhikr dhikr;
  final bool isSelected;
  final VoidCallback onTap;

  const _DhikrListItem({
    required this.dhikr,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.white24,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Dhikr info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic text
                  Text(
                    dhikr.arabic,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Amiri',
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.white,
                      height: 1.5,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),

                  // Transliteration
                  Text(
                    dhikr.transliteration,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Meaning
                  Text(
                    dhikr.meaning,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),

            // Recommended count
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dhikr.recommendedCount}x',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
