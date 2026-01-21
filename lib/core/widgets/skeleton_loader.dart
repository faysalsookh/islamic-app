import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shimmer effect for skeleton loading
class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkCard,
                      AppColors.darkSurface.withValues(alpha: 0.5),
                      AppColors.darkCard,
                    ]
                  : [
                      AppColors.warmBeige,
                      Colors.white.withValues(alpha: 0.5),
                      AppColors.warmBeige,
                    ],
              stops: [
                0.0,
                0.5 + _animation.value * 0.25,
                1.0,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Base skeleton box
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.warmBeige,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton for surah list items
class SurahListSkeleton extends StatelessWidget {
  final int itemCount;

  const SurahListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          itemCount,
          (index) => const _SurahItemSkeleton(),
        ),
      ),
    );
  }
}

class _SurahItemSkeleton extends StatelessWidget {
  const _SurahItemSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Number badge
          const SkeletonBox(width: 44, height: 44, borderRadius: 12),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 120, height: 16),
                const SizedBox(height: 8),
                const SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
          // Arabic name
          const SkeletonBox(width: 60, height: 24),
        ],
      ),
    );
  }
}

/// Skeleton for ayah items in Quran reader
class AyahListSkeleton extends StatelessWidget {
  final int itemCount;

  const AyahListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          itemCount,
          (index) => const _AyahItemSkeleton(),
        ),
      ),
    );
  }
}

class _AyahItemSkeleton extends StatelessWidget {
  const _AyahItemSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Arabic text lines
          const SkeletonBox(height: 28),
          const SizedBox(height: 8),
          const SkeletonBox(width: 200, height: 28),
          const SizedBox(height: 16),
          // Translation lines
          const Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 250, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 180, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for quick access cards
class QuickAccessSkeleton extends StatelessWidget {
  const QuickAccessSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 4,
          itemBuilder: (context, index) => const _QuickAccessCardSkeleton(),
        ),
      ),
    );
  }
}

class _QuickAccessCardSkeleton extends StatelessWidget {
  const _QuickAccessCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 48, height: 48, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 80, height: 16),
                SizedBox(height: 6),
                SkeletonBox(width: 50, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for continue reading card
class ContinueReadingSkeleton extends StatelessWidget {
  const ContinueReadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.forestGreen.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 24, height: 24, borderRadius: 6),
                SizedBox(width: 8),
                SkeletonBox(width: 120, height: 16),
              ],
            ),
            SizedBox(height: 16),
            SkeletonBox(width: 180, height: 24),
            SizedBox(height: 8),
            SkeletonBox(width: 100, height: 14),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: SkeletonBox(height: 8, borderRadius: 4)),
                SizedBox(width: 12),
                SkeletonBox(width: 40, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for search results
class SearchResultSkeleton extends StatelessWidget {
  final int itemCount;

  const SearchResultSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          itemCount,
          (index) => const _SearchResultItemSkeleton(),
        ),
      ),
    );
  }
}

class _SearchResultItemSkeleton extends StatelessWidget {
  const _SearchResultItemSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 36, height: 36, borderRadius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 150, height: 14),
                SizedBox(height: 4),
                SkeletonBox(width: 100, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 50, height: 20),
        ],
      ),
    );
  }
}
