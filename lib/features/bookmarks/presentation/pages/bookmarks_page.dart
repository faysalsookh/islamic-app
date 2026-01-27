import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/models/bookmark.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/haptic_service.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  String? _selectedLabel;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Bookmark> _getFilteredBookmarks(List<Bookmark> bookmarks) {
    var filtered = bookmarks;

    if (_selectedLabel != null) {
      filtered = filtered.where((b) => b.label == _selectedLabel).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((b) =>
              b.surahNameEnglish.toLowerCase().contains(query) ||
              b.surahNameArabic.contains(query) ||
              b.ayahSnippet.contains(query))
          .toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  void _navigateToAyah(Bookmark bookmark) {
    HapticService().lightImpact();
    Navigator.pushNamed(
      context,
      '/quran-reader',
      arguments: {
        'surahNumber': bookmark.surahNumber,
        'ayahNumber': bookmark.ayahNumber,
      },
    );
  }

  void _showLabelEditDialog(Bookmark bookmark) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    HapticService().selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textTertiary)
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.label_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Label',
                            style: AppTypography.heading3(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Organize your bookmark',
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
                const SizedBox(height: 24),
                ...BookmarkLabels.all.map(
                  (label) => _PremiumLabelOption(
                    label: label,
                    isSelected: bookmark.label == label,
                    onTap: () {
                      HapticService().selectionClick();
                      context.read<AppStateProvider>().updateBookmark(
                            bookmark.copyWith(label: label),
                          );
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
                const SizedBox(height: 8),
                _PremiumLabelOption(
                  label: 'Remove Label',
                  isSelected: false,
                  isDestructive: true,
                  icon: Icons.remove_circle_outline_rounded,
                  onTap: () {
                    HapticService().lightImpact();
                    context.read<AppStateProvider>().updateBookmark(
                          bookmark.copyWith(label: null),
                        );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBookmarkOptions(Bookmark bookmark) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    HapticService().selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary)
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.cream.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            bookmark.surahNumber.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
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
                      Text(
                        bookmark.surahNameArabic,
                        textDirection: TextDirection.rtl,
                        style: AppTypography.surahNameArabic(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _OptionTile(
                  icon: Icons.menu_book_rounded,
                  label: 'Continue Reading',
                  subtitle: 'Go to Ayah ${bookmark.ayahNumber}',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAyah(bookmark);
                  },
                  isDark: isDark,
                ),
                _OptionTile(
                  icon: Icons.label_rounded,
                  label: 'Change Label',
                  subtitle: bookmark.label ?? 'No label assigned',
                  onTap: () {
                    Navigator.pop(context);
                    _showLabelEditDialog(bookmark);
                  },
                  isDark: isDark,
                ),
                _OptionTile(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  subtitle: 'Share this ayah',
                  onTap: () {
                    Navigator.pop(context);
                    _shareBookmark(bookmark);
                  },
                  isDark: isDark,
                ),
                _OptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  subtitle: 'Remove this bookmark',
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(bookmark);
                  },
                  isDark: isDark,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareBookmark(Bookmark bookmark) {
    final text =
        '📖 ${bookmark.surahNameEnglish} (${bookmark.surahNameArabic})\n\n'
        'Ayah ${bookmark.ayahNumber}:\n${bookmark.ayahSnippet}\n\n'
        '— Rushd App';
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.mutedTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _confirmDelete(Bookmark bookmark) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    HapticService().lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Bookmark',
              style: AppTypography.heading3(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove bookmark for ${bookmark.surahNameEnglish}, Ayah ${bookmark.ayahNumber}?',
          style: AppTypography.bodyMedium(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticService().mediumImpact();
              context.read<AppStateProvider>().removeBookmark(bookmark.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getLabelCounts(List<Bookmark> bookmarks) {
    final counts = <String, int>{};
    for (final label in BookmarkLabels.all) {
      counts[label] = bookmarks.where((b) => b.label == label).length;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'My Bookmarks',
              style: AppTypography.heading2(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final filteredBookmarks = _getFilteredBookmarks(appState.bookmarks);
          final labelCounts = _getLabelCounts(appState.bookmarks);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.fromLTRB(
                    horizontalPadding, 8, horizontalPadding, 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isSearchFocused
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: _isSearchFocused ? 0.08 : 0.04),
                        blurRadius: _isSearchFocused ? 16 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    onTap: () => setState(() => _isSearchFocused = true),
                    onEditingComplete: () {
                      setState(() => _isSearchFocused = false);
                      FocusScope.of(context).unfocus();
                    },
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search bookmarks...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _isSearchFocused
                            ? theme.colorScheme.primary
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textTertiary),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textTertiary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  children: [
                    _PremiumFilterChip(
                      label: 'All',
                      count: appState.bookmarks.length,
                      isSelected: _selectedLabel == null,
                      onTap: () {
                        HapticService().selectionClick();
                        setState(() => _selectedLabel = null);
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    ...BookmarkLabels.all.map(
                      (label) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _PremiumFilterChip(
                          label: label,
                          count: labelCounts[label] ?? 0,
                          isSelected: _selectedLabel == label,
                          onTap: () {
                            HapticService().selectionClick();
                            setState(() => _selectedLabel =
                                _selectedLabel == label ? null : label);
                          },
                          theme: theme,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bookmarks List
              Expanded(
                child: filteredBookmarks.isEmpty
                    ? _PremiumEmptyState(
                        hasBookmarks: appState.bookmarks.isNotEmpty,
                        isDark: isDark,
                        theme: theme,
                      )
                    : isTablet
                        ? GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.8,
                            ),
                            itemCount: filteredBookmarks.length,
                            itemBuilder: (context, index) {
                              return _BookmarkCard(
                                bookmark: filteredBookmarks[index],
                                onTap: () =>
                                    _navigateToAyah(filteredBookmarks[index]),
                                onLongPress: () => _showBookmarkOptions(
                                    filteredBookmarks[index]),
                                onLabelTap: () => _showLabelEditDialog(
                                    filteredBookmarks[index]),
                                isDark: isDark,
                                theme: theme,
                              );
                            },
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            itemCount: filteredBookmarks.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _BookmarkCard(
                                  bookmark: filteredBookmarks[index],
                                  onTap: () =>
                                      _navigateToAyah(filteredBookmarks[index]),
                                  onLongPress: () => _showBookmarkOptions(
                                      filteredBookmarks[index]),
                                  onLabelTap: () => _showLabelEditDialog(
                                      filteredBookmarks[index]),
                                  isDark: isDark,
                                  theme: theme,
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Bookmark Card Widget
class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onLabelTap;
  final bool isDark;
  final ThemeData theme;

  const _BookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.onLongPress,
    required this.onLabelTap,
    required this.isDark,
    required this.theme,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes < 1) return 'Just now';
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getLabelIcon(String label) {
    switch (label) {
      case 'Memorize':
        return Icons.psychology_rounded;
      case 'Favorite':
        return Icons.favorite_rounded;
      case 'Daily Read':
        return Icons.today_rounded;
      case 'Study':
        return Icons.school_rounded;
      case 'Review':
        return Icons.refresh_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top gradient accent
            Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      bookmark.surahNumber.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bookmark.surahNameEnglish,
                        style: AppTypography.heading3(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
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
                    ],
                  ),
                ),
                Text(
                  bookmark.surahNameArabic,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.surahNameArabic(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Ayah snippet
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground.withValues(alpha: 0.5)
                    : AppColors.cream.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bookmark.ayahSnippet,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.quranText(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (bookmark.label != null)
                  GestureDetector(
                    onTap: onLabelTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getLabelIcon(bookmark.label!),
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bookmark.label!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onLabelTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Add Label',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
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
          ],
        ),
      ),
    );
  }
}

// Premium Filter Chip
class _PremiumFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDark;

  const _PremiumFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isSelected ? null : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Premium Label Option
class _PremiumLabelOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDestructive;
  final IconData? icon;

  const _PremiumLabelOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
    this.icon,
  });

  IconData get _icon {
    if (icon != null) return icon!;
    switch (label) {
      case 'Memorize':
        return Icons.psychology_rounded;
      case 'Favorite':
        return Icons.favorite_rounded;
      case 'Daily Read':
        return Icons.today_rounded;
      case 'Study':
        return Icons.school_rounded;
      case 'Review':
        return Icons.refresh_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.08)
              : (isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : isDark
                      ? AppColors.darkBackground
                      : AppColors.cream.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.15)
                    : theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icon,
                size: 18,
                color: isDestructive ? AppColors.error : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? AppColors.error
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// Option Tile
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkBackground : AppColors.cream.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.12)
                    : theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? AppColors.error : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppColors.error
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// Premium Empty State
class _PremiumEmptyState extends StatelessWidget {
  final bool hasBookmarks;
  final bool isDark;
  final ThemeData theme;

  const _PremiumEmptyState({
    required this.hasBookmarks,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasBookmarks
                    ? Icons.search_off_rounded
                    : Icons.bookmark_border_rounded,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasBookmarks ? 'No matching bookmarks' : 'No bookmarks yet',
              style: AppTypography.heading2(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                hasBookmarks
                    ? 'Try adjusting your search or filters to find what you\'re looking for'
                    : 'Save your favorite ayahs while reading the Quran and access them anytime',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (!hasBookmarks) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/surah-list'),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Start Reading'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
