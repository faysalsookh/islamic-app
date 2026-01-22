import 'package:flutter/material.dart';

/// Large animated counter display for Tasbih
class TasbihCounterWidget extends StatelessWidget {
  final int count;
  final int target;
  final int loop;
  final bool isTablet;
  final VoidCallback? onTargetTap;

  const TasbihCounterWidget({
    super.key,
    required this.count,
    required this.target,
    required this.loop,
    this.isTablet = false,
    this.onTargetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loop indicator
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Loop $loop',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(height: isTablet ? 24 : 16),

        // Main count - animated
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: count.toDouble()),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Text(
              value.round().toString(),
              style: TextStyle(
                fontSize: isTablet ? 96 : 72,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF4CAF50),
                height: 1,
              ),
            );
          },
        ),

        SizedBox(height: isTablet ? 8 : 4),

        // Target indicator (tappable to edit)
        GestureDetector(
          onTap: onTargetTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '/ $target',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  color: Colors.white54,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Icon(
                Icons.edit_rounded,
                size: isTablet ? 18 : 14,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Target selection dialog
class TargetSelectionDialog extends StatefulWidget {
  final int currentTarget;
  final List<int> presets;

  const TargetSelectionDialog({
    super.key,
    required this.currentTarget,
    required this.presets,
  });

  static Future<int?> show(
    BuildContext context, {
    required int currentTarget,
    List<int> presets = const [33, 99, 100, 500, 1000],
  }) {
    return showDialog<int>(
      context: context,
      builder: (context) => TargetSelectionDialog(
        currentTarget: currentTarget,
        presets: presets,
      ),
    );
  }

  @override
  State<TargetSelectionDialog> createState() => _TargetSelectionDialogState();
}

class _TargetSelectionDialogState extends State<TargetSelectionDialog> {
  late TextEditingController _controller;
  late int _selectedTarget;

  @override
  void initState() {
    super.initState();
    _selectedTarget = widget.currentTarget;
    _controller = TextEditingController(text: _selectedTarget.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Target Count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Preset buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: widget.presets.map((preset) {
                final isSelected = _selectedTarget == preset;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTarget = preset;
                      _controller.text = preset.toString();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      preset.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Custom input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    cursorColor: const Color(0xFF4CAF50),
                    decoration: InputDecoration(
                      labelText: 'Custom',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        setState(() {
                          _selectedTarget = parsed;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final value = int.tryParse(_controller.text);
                      if (value != null && value > 0) {
                        Navigator.pop(context, value);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Set',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
