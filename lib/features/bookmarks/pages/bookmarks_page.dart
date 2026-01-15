import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/models/bookmark.dart';
import '../../../../core/widgets/elegant_card.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
      ),
      body: IslamicPatternBackground(
        patternColor: theme.colorScheme.primary,
        opacity: 0.03,
        child: Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            final bookmarks = appState.bookmarks;

            if (bookmarks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 64,
                      color: isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                          : AppColors.textTertiary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarks yet',
                      style: AppTypography.heading3(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon while reading\nto save your place.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(
                         color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BookmarkCard(bookmark: bookmark),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;

  const _BookmarkCard({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElegantCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/quran-reader',
          arguments: bookmark.surahNumber,
        );
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Surah Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ayah ${bookmark.ayahNumber}',
                      style: AppTypography.label(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    bookmark.surahNameEnglish,
                    style: AppTypography.heading3(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              // Delete button (mockup)
              Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Snippet
          Text(
            bookmark.ayahSnippet,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.quranText(
              fontSize: 22,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textArabic,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          // Metadata
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                'Last read 2 hours ago', // Mock data
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                ),
              ),
              if (bookmark.label != null) ...[
                const SizedBox(width: 12),
                 Icon(
                  Icons.label_outline_rounded,
                  size: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  bookmark.label!,
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
