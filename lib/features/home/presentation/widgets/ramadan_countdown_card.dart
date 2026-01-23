import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/ramadan_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Beautiful countdown card for Sehri/Iftar times during Ramadan
class RamadanCountdownCard extends StatelessWidget {
  const RamadanCountdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RamadanProvider>(
      builder: (context, ramadanProvider, child) {
        // Don't show if not in Ramadan or no prayer times
        if (!ramadanProvider.isRamadan || ramadanProvider.todayPrayerTimes == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final prayerTimes = ramadanProvider.todayPrayerTimes!;
        
        // Determine if we're showing Sehri or Iftar countdown
        final timeUntilSehri = ramadanProvider.timeUntilSehriEnds;
        final timeUntilIftar = ramadanProvider.timeUntilIftar;
        final isShowingSehri = timeUntilSehri != null;
        
        final countdown = isShowingSehri ? timeUntilSehri : timeUntilIftar;
        final nextTime = isShowingSehri ? prayerTimes.fajr : prayerTimes.maghrib;
        final nextTimeLabel = isShowingSehri ? 'Sehri ends at' : 'Iftar at';
        final countdownLabel = isShowingSehri ? 'Sehri ends in' : 'Iftar in';

        return ElegantCard(
          padding: const EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isShowingSehri
                    ? [
                        // Dawn colors for Sehri
                        isDark 
                            ? const Color(0xFF1A4B6D)
                            : const Color(0xFF4A90E2),
                        isDark
                            ? const Color(0xFF2D5F7E)
                            : const Color(0xFF7CB9E8),
                      ]
                    : [
                        // Sunset colors for Iftar
                        isDark
                            ? const Color(0xFF6B3E8F)
                            : const Color(0xFFE8796C),
                        isDark
                            ? const Color(0xFF8B5FA8)
                            : const Color(0xFFF4A261),
                      ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative pattern overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: _IslamicPatternPainter(),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Ramadan day
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ramadan Day ${ramadanProvider.currentRamadanDay ?? 1}',
                                style: AppTypography.bodyMedium(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isShowingSehri 
                                      ? Icons.wb_twilight_rounded 
                                      : Icons.wb_sunny_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isShowingSehri ? 'Sehri' : 'Iftar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Countdown timer
                      if (countdown != null) ...[
                        Text(
                          countdownLabel,
                          style: AppTypography.bodyLarge(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCountdownDisplay(countdown),
                      ] else ...[
                        Text(
                          isShowingSehri 
                              ? 'Sehri time has passed' 
                              : 'Iftar time has passed',
                          style: AppTypography.heading2(
                            color: Colors.white,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Next prayer time
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              nextTimeLabel,
                              style: AppTypography.bodyMedium(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              DateFormat('h:mm a').format(nextTime),
                              style: AppTypography.heading3(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownDisplay(Duration countdown) {
    final hours = countdown.inHours;
    final minutes = countdown.inMinutes.remainder(60);
    final seconds = countdown.inSeconds.remainder(60);

    return Row(
      children: [
        _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours'),
        const SizedBox(width: 8),
        Text(
          ':',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Min'),
        const SizedBox(width: 8),
        Text(
          ':',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Sec'),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for Islamic geometric patterns
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw simple geometric pattern
    final spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 15, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
