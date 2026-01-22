import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/qibla_calculator.dart';
import '../../../../core/services/compass_service.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Card showing Qibla bearing, distance, and accuracy information
class QiblaInfoCard extends StatelessWidget {
  final double qiblaBearing;
  final double distanceKm;
  final CompassAccuracy accuracy;
  final bool isTablet;
  final VoidCallback? onCalibrateTap;

  const QiblaInfoCard({
    super.key,
    required this.qiblaBearing,
    required this.distanceKm,
    required this.accuracy,
    this.isTablet = false,
    this.onCalibrateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElegantCard(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        children: [
          // Main info row
          Row(
            children: [
              // Qibla bearing
              Expanded(
                child: _buildInfoColumn(
                  context,
                  'Qibla Direction',
                  QiblaCalculator.formatBearing(qiblaBearing),
                  QiblaCalculator.getFullDirectionName(qiblaBearing),
                  Icons.navigation_rounded,
                  AppColors.forestGreen,
                  isDark,
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: isTablet ? 80 : 70,
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
              // Distance
              Expanded(
                child: _buildInfoColumn(
                  context,
                  'Distance to Kaaba',
                  QiblaCalculator.formatDistance(distanceKm),
                  'Mecca, Saudi Arabia',
                  Icons.place_rounded,
                  AppColors.softRose,
                  isDark,
                ),
              ),
            ],
          ),

          // Accuracy indicator
          const SizedBox(height: 16),
          _buildAccuracyIndicator(context, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          width: isTablet ? 48 : 40,
          height: isTablet ? 48 : 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isTablet ? 24 : 20,
            color: color,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 13 : 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 12 : 10,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccuracyIndicator(BuildContext context, bool isDark) {
    final accuracyColor = Color(CompassService.getAccuracyColorValue(accuracy));
    final showCalibrate = accuracy == CompassAccuracy.low ||
                          accuracy == CompassAccuracy.unreliable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: accuracyColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accuracyColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              CompassService.getAccuracyDescription(accuracy),
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: accuracyColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (showCalibrate && onCalibrateTap != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onCalibrateTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accuracyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Calibrate',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: accuracyColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
