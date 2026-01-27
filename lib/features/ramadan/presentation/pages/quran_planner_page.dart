import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/quran_plan_provider.dart';
import '../../../../core/providers/ramadan_provider.dart';
import '../../../../core/models/quran_plan.dart';
import '../../../../core/models/juz.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Khatam-ul-Quran Planner page with Juz-based tracking
class QuranPlannerPage extends StatefulWidget {
  const QuranPlannerPage({super.key});

  @override
  State<QuranPlannerPage> createState() => _QuranPlannerPageState();
}

class _QuranPlannerPageState extends State<QuranPlannerPage>
    with TickerProviderStateMixin {
  int _selectedDays = 30;
  late AnimationController _progressAnimController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressAnimController,
      curve: Curves.easeOutCubic,
    );
    _progressAnimController.forward();
  }

  @override
  void dispose() {
    _progressAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final planProvider = context.watch<QuranPlanProvider>();
    final hasPlan = planProvider.hasPlan;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.pearl,
      appBar: AppBar(
        title: const Text('Khatam-ul-Quran'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        actions: [
          if (hasPlan)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _showDeleteConfirmation(context, planProvider),
              tooltip: 'Delete Plan',
            ),
        ],
      ),
      body: hasPlan
          ? _buildActivePlan(context, planProvider, isDark, theme)
          : _buildPlanCreation(context, planProvider, isDark, theme),
    );
  }

  Widget _buildActivePlan(
    BuildContext context,
    QuranPlanProvider provider,
    bool isDark,
    ThemeData theme,
  ) {
    final plan = provider.plan!;
    final percentage = plan.progressPercentage;

    return CustomScrollView(
      slivers: [
        // Progress Header
        SliverToBoxAdapter(
          child: _buildProgressHeader(plan, percentage, isDark, theme),
        ),

        // Status & Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _buildStatsRow(plan, isDark, theme),
          ),
        ),

        // Section Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap a Juz to mark as read',
                  style: AppTypography.heading4(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Juz Grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.82,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final juzNumber = index + 1;
                final juz = JuzData.getJuz(juzNumber)!;
                final isCompleted = plan.isJuzCompleted(juzNumber);
                return _buildJuzCard(
                  juz: juz,
                  isCompleted: isCompleted,
                  isDark: isDark,
                  theme: theme,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.toggleJuz(juzNumber);
                  },
                );
              },
              childCount: 30,
            ),
          ),
        ),

        // Plan Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            child: _buildPlanDetails(plan, isDark, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(
    QuranPlan plan,
    double percentage,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.mutedTealDark,
                  AppColors.emeraldGreenDark,
                ]
              : [
                  AppColors.mutedTeal,
                  AppColors.emeraldGreen,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedTeal.withOpacity(isDark ? 0.2 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'Khatam Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Circular progress
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final animatedProgress =
                  percentage * _progressAnimation.value / 100;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: CircularProgressIndicator(
                      value: animatedProgress,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan.completedCount} / ${plan.totalJuz} Juz',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Status message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  plan.isOnTrack
                      ? Icons.check_circle_outline_rounded
                      : Icons.schedule_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    plan.statusMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(QuranPlan plan, bool isDark, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            icon: Icons.today_rounded,
            label: 'Expected',
            value: '${plan.expectedJuz} Juz',
            isDark: isDark,
            theme: theme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatChip(
            icon: Icons.speed_rounded,
            label: 'Per Day',
            value: '${plan.juzPerDay.toStringAsFixed(1)}',
            isDark: isDark,
            theme: theme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatChip(
            icon: Icons.pending_outlined,
            label: 'Remaining',
            value: '${plan.remainingJuz} Juz',
            isDark: isDark,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzCard({
    required Juz juz,
    required bool isCompleted,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isCompleted
            ? (isDark ? AppColors.emeraldGreenDark : AppColors.emeraldGreen)
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? null
            : Border.all(
                color: isDark
                    ? AppColors.dividerDark
                    : AppColors.divider,
                width: 1,
              ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: AppColors.emeraldGreen.withOpacity(isDark ? 0.2 : 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                if (!isDark)
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Juz number badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.white.withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${juz.number}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Arabic name
                Text(
                  juz.nameArabic,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                    fontFamily: 'Amiri',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Transliteration
                Text(
                  juz.nameTransliteration,
                  style: TextStyle(
                    fontSize: 10,
                    color: isCompleted
                        ? Colors.white.withOpacity(0.8)
                        : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Juz number for completed state
                if (isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Juz ${juz.number}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanDetails(QuranPlan plan, bool isDark, ThemeData theme) {
    return ElegantCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Plan Details',
                style: AppTypography.heading4(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPlanDetailRow(
            'Start Date',
            DateFormat('MMM d, yyyy').format(plan.startDate),
            isDark,
          ),
          const Divider(height: 24),
          _buildPlanDetailRow(
            'Target Duration',
            '${plan.targetDays} Days',
            isDark,
          ),
          const Divider(height: 24),
          _buildPlanDetailRow(
            'Estimated Completion',
            DateFormat('MMM d, yyyy').format(
              plan.startDate.add(Duration(days: plan.targetDays)),
            ),
            isDark,
          ),
          const Divider(height: 24),
          _buildPlanDetailRow(
            'Days Remaining',
            '${plan.remainingDays} Days',
            isDark,
          ),
        ],
      ),
    );
  }

  // ─── Plan Creation Screen ─────────────────────────────────

  Widget _buildPlanCreation(
    BuildContext context,
    QuranPlanProvider provider,
    bool isDark,
    ThemeData theme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 30),
        // Icon
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: 44,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Start Your Khatam Journey',
          style: AppTypography.heading2(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Track your Quran completion by Juz.\nTap each Juz as you finish reading it.',
          style: AppTypography.bodyMedium(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        Text(
          'I want to complete in:',
          style: AppTypography.heading4(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildDurationOption(15, theme, isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildDurationOption(20, theme, isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildDurationOption(30, theme, isDark)),
          ],
        ),

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              final ramadanProvider = context.read<RamadanProvider>();
              final startDate =
                  ramadanProvider.settings.ramadanStartDate ?? DateTime.now();
              provider.createPlan(
                targetDays: _selectedDays,
                startDate: startDate,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: theme.colorScheme.primary.withOpacity(0.4),
            ),
            child: const Text(
              'Start Khatam Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Info note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.mutedTealSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '30 Juz = Complete Quran. You can tap each Juz as you finish reading it to track your progress.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationOption(int days, ThemeData theme, bool isDark) {
    final isSelected = _selectedDays == days;
    final juzPerDay = (30 / days).toStringAsFixed(1);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedDays = days);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.dividerDark : AppColors.divider),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              '$days',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
              ),
            ),
            Text(
              'Days',
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$juzPerDay juz/day',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared Helpers ───────────────────────────────────────

  Widget _buildPlanDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium(
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyLarge(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, QuranPlanProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Plan?'),
        content: const Text(
          'This will reset your Khatam progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deletePlan();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
