import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/models/bookmark.dart';
import '../../../../core/widgets/elegant_card.dart';
import '../../../../core/utils/responsive.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  String? _selectedLabel;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Bookmark> _getFilteredBookmarks(List<Bookmark> bookmarks) {
    var filtered = bookmarks;

    // Filter by label
    if (_selectedLabel != null) {
      filtered = filtered.where((b) => b.label == _selectedLabel).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((b) =>
              b.surahNameEnglish.toLowerCase().contains(query) ||
              b.surahNameArabic.contains(query) ||
              b.ayahSnippet.contains(query))
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  void _showLabelEditDialog(Bookmark bookmark) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Label',
                style: AppTypography.heading2(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...BookmarkLabels.all.map(
                    (label) => _LabelChip(
                      label: label,
                      isSelected: bookmark.label == label,
                      onTap: () {
                        final appState = context.read<AppStateProvider>();
                        appState.updateBookmark(
                          bookmark.copyWith(label: label),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  _LabelChip(
                    label: 'Remove Label',
                    isSelected: false,
                    onTap: () {
                      final appState = context.read<AppStateProvider>();
                      appState.updateBookmark(
                        bookmark.copyWith(label: null),
                      );
                      Navigator.pop(context);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Bookmark bookmark) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: Text(
          'Remove bookmark for ${bookmark.surahNameEnglish}, Ayah ${bookmark.ayahNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppStateProvider>().removeBookmark(bookmark.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: AppTypography.heading2(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final filteredBookmarks = _getFilteredBookmarks(appState.bookmarks);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 800 : double.infinity,
              ),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search bookmarks...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textTertiary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedLabel == null,
                          onSelected: (_) {
                            setState(() {
                              _selectedLabel = null;
                            });
                          },
                          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                          checkmarkColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        ...BookmarkLabels.all.map(
                          (label) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(label),
                              selected: _selectedLabel == label,
                              onSelected: (_) {
                                setState(() {
                                  _selectedLabel =
                                      _selectedLabel == label ? null : label;
                                });
                              },
                              selectedColor:
                                  theme.colorScheme.primary.withValues(alpha: 0.2),
                              checkmarkColor: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bookmarks list - Grid on tablet
                  Expanded(
                    child: filteredBookmarks.isEmpty
                        ? _EmptyState(
                            hasBookmarks: appState.bookmarks.isNotEmpty,
                            isDark: isDark,
                          )
                        : isTablet
                            ? GridView.builder(
                                padding: EdgeInsets.all(horizontalPadding),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  mainAxisExtent: 200,
                                ),
                                itemCount: filteredBookmarks.length,
                                itemBuilder: (context, index) {
                                  final bookmark = filteredBookmarks[index];
                                  return _BookmarkTile(
                                    bookmark: bookmark,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/quran-reader',
                                        arguments: bookmark.surahNumber,
                                      );
                                    },
                                    onLabelTap: () => _showLabelEditDialog(bookmark),
                                    onDelete: () => _confirmDelete(bookmark),
                                  );
                                },
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(horizontalPadding),
                                itemCount: filteredBookmarks.length,
                                itemBuilder: (context, index) {
                                  final bookmark = filteredBookmarks[index];
                                  return _BookmarkTile(
                                    bookmark: bookmark,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/quran-reader',
                                        arguments: bookmark.surahNumber,
                                      );
                                    },
                                    onLabelTap: () => _showLabelEditDialog(bookmark),
                                    onDelete: () => _confirmDelete(bookmark),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onLabelTap;
  final VoidCallback onDelete;

  const _BookmarkTile({
    required this.bookmark,
    required this.onTap,
    required this.onLabelTap,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(bookmark.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: ElegantCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Surah number badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            bookmark.surahNumber.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookmark.surahNameEnglish,
                              style: AppTypography.heading3(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Ayah ${bookmark.ayahNumber}',
                              style: AppTypography.bodySmall(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bookmark.surahNameArabic,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.surahNameArabic(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ayah snippet
            Text(
              bookmark.ayahSnippet,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.quranText(
                fontSize: 18,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Bottom row with label and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (bookmark.label != null)
                  GestureDetector(
                    onTap: onLabelTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bookmark.label!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onLabelTap,
                    child: Text(
                      '+ Add Label',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                Text(
                  _formatDate(bookmark.createdAt),
                  style: AppTypography.caption(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary,
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

class _LabelChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDestructive;

  const _LabelChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : (isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDestructive
                ? AppColors.error
                : (isSelected ? Colors.white : theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasBookmarks;
  final bool isDark;

  const _EmptyState({
    required this.hasBookmarks,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasBookmarks ? Icons.search_off_rounded : Icons.bookmark_border_rounded,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              hasBookmarks ? 'No matching bookmarks' : 'No bookmarks yet',
              style: AppTypography.heading3(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasBookmarks
                  ? 'Try adjusting your search or filters'
                  : 'Save your favorite ayahs while reading',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
