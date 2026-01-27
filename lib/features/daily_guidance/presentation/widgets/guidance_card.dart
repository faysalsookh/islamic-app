import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/daily_guidance_model.dart';

/// Full-screen guidance card with beautiful layout per content type
class GuidanceCard extends StatelessWidget {
  final DailyGuidanceItem item;
  final int dayNumber;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const GuidanceCard({
    super.key,
    required this.item,
    required this.dayNumber,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradient(),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            children: [
              // Top section - type badge & day
              _buildTopSection(),
              const SizedBox(height: 24),
              // Main content
              Expanded(
                child: _buildContent(),
              ),
              // Bottom section - actions
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (item.type) {
      case DailyGuidanceType.ayah:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A4A3A), Color(0xFF0D6B4F), Color(0xFF2D7A7A)],
        );
      case DailyGuidanceType.hadith:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF4A6572)],
        );
      case DailyGuidanceType.dua:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3A5C), Color(0xFF2D5A7A), Color(0xFF3D7A9A)],
        );
      case DailyGuidanceType.dhikr:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D2B56), Color(0xFF5B3A7A), Color(0xFF7A5A9A)],
        );
      case DailyGuidanceType.reflection:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A3728), Color(0xFF6B5240), Color(0xFF8B7355)],
        );
      case DailyGuidanceType.dailyDeed:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B6914), Color(0xFFA68B3D), Color(0xFFC9A962)],
        );
    }
  }

  IconData _getTypeIcon() {
    switch (item.type) {
      case DailyGuidanceType.ayah:
        return Icons.menu_book_rounded;
      case DailyGuidanceType.hadith:
        return Icons.format_quote_rounded;
      case DailyGuidanceType.dua:
        return Icons.front_hand_rounded;
      case DailyGuidanceType.dhikr:
        return Icons.radio_button_on_rounded;
      case DailyGuidanceType.reflection:
        return Icons.lightbulb_rounded;
      case DailyGuidanceType.dailyDeed:
        return Icons.favorite_rounded;
    }
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTypeIcon(),
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                item.type.label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        // Day number
        Text(
          'Day $dayNumber',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Subtitle if present
          if (item.subtitle != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.subtitle!,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Arabic text
          if (item.arabicText.isNotEmpty) ...[
            Text(
              item.arabicText,
              style: AppTypography.quranText(
                fontSize: 28,
                color: Colors.white,
                height: 2.0,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 20),
          ],

          // Transliteration
          if (item.transliteration.isNotEmpty) ...[
            Text(
              item.transliteration,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],

          // Divider
          if (item.arabicText.isNotEmpty)
            Container(
              width: 40,
              height: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

          if (item.arabicText.isNotEmpty) const SizedBox(height: 16),

          // Translation / Main text
          Text(
            item.translation,
            style: GoogleFonts.outfit(
              fontSize: item.arabicText.isEmpty ? 20 : 16,
              fontWeight: item.arabicText.isEmpty ? FontWeight.w400 : FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.reference,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bookmark button
        _buildActionButton(
          icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          label: isBookmarked ? 'Saved' : 'Save',
          onTap: onBookmark,
        ),
        const SizedBox(width: 32),
        // Share button
        _buildActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: onShare,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
