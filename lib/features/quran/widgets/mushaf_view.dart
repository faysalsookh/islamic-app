import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/models/ayah.dart';
import '../../../../core/widgets/ayah_number_badge.dart';

/// Mushaf (page style) view of the Quran
class MushafView extends StatelessWidget {
  final Surah surah;
  final List<Ayah> ayahs;
  final double quranFontSize;

  const MushafView({
    super.key,
    required this.surah,
    required this.ayahs,
    required this.quranFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // In a real app, we would paginate by standard Mushaf pages (e.g., Madani).
    // For this demo, we'll just render the surah as a continuous text block
    // to simulate the look and feel.

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          BismillahHeader(fontSize: quranFontSize),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.ivory,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.softRose.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : AppColors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: RichText(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: ayahs.map((ayah) {
                  return TextSpan(
                    children: [
                      TextSpan(
                        text: '${ayah.textArabic} ',
                        style: AppTypography.quranText(
                          fontSize: quranFontSize,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textArabic,
                          height: 2.2, // Taller line height for Mushaf
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                         child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 4),
                           child: AyahNumberBadge(
                             number: ayah.numberInSurah,
                             size: quranFontSize * 0.8,
                             backgroundColor: Colors.transparent,
                             textColor: isDark ? AppColors.softRose : AppColors.forestGreen,
                           ),
                         ),
                      ),
                      const TextSpan(text: '  '), // Spacing after ayah end
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
