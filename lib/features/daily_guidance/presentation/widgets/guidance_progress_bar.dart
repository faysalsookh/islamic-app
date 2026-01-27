import 'package:flutter/material.dart';

/// Instagram Stories-style segmented progress bar
class GuidanceProgressBar extends StatelessWidget {
  final int totalSegments;
  final int currentSegment;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;

  const GuidanceProgressBar({
    super.key,
    required this.totalSegments,
    required this.currentSegment,
    this.progress = 0.0,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x55FFFFFF),
    this.completedColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSegments, (index) {
        final isCompleted = index < currentSegment;
        final isActive = index == currentSegment;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < totalSegments - 1 ? 3 : 0,
            ),
            height: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1.5),
              child: isActive
                  ? LinearProgressIndicator(
                      value: progress,
                      backgroundColor: inactiveColor,
                      valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                      minHeight: 3,
                    )
                  : Container(
                      color: isCompleted ? completedColor : inactiveColor,
                    ),
            ),
          ),
        );
      }),
    );
  }
}
