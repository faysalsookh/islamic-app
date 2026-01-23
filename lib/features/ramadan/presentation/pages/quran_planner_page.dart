import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/quran_plan_provider.dart';
import '../../../../core/providers/ramadan_provider.dart';
import '../../../../core/models/quran_plan.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Khatam-ul-Quran Planner page
class QuranPlannerPage extends StatefulWidget {
  const QuranPlannerPage({super.key});

  @override
  State<QuranPlannerPage> createState() => _QuranPlannerPageState();
}

class _QuranPlannerPageState extends State<QuranPlannerPage> {
  // For plan creation
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final planProvider = context.watch<QuranPlanProvider>();
    final hasPlan = planProvider.hasPlan;

    return Scaffold(
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
    final percentage = (plan.currentPage / plan.completeQuranPages * 100).clamp(0.0, 100.0);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Status Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                AppColors.mutedTeal.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Khatam Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${plan.currentPage} / ${plan.completeQuranPages}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan.statusMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Today's Target Card
        ElegantCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Icon(
                    Icons.today_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Today\'s Goal',
                    style: AppTypography.heading4(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGoalStat(
                    'Target Page',
                    '${plan.expectedPage}',
                    isDark,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                  _buildGoalStat(
                    'Pages / Day',
                    '${plan.pagesPerDay}',
                    isDark,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                  _buildGoalStat(
                    'Remaining',
                    '${plan.remainingPages}',
                    isDark,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Update Progress Card
        ElegantCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Progress',
                style: AppTypography.heading4(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Drag slider to update your current page',
                style: AppTypography.bodySmall(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: theme.colorScheme.primary,
                    onPressed: () => provider.updateProgress(plan.currentPage - 1),
                  ),
                  Text(
                    'Page ${plan.currentPage}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: theme.colorScheme.primary,
                    onPressed: () => provider.updateProgress(plan.currentPage + 1),
                  ),
                ],
              ),
              Slider(
                value: plan.currentPage.toDouble(),
                min: 0,
                max: plan.completeQuranPages.toDouble(),
                activeColor: theme.colorScheme.primary,
                onChanged: (value) => provider.updateProgress(value.toInt()),
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Quick add 10 pages
                    provider.updateProgress(plan.currentPage + 10);
                  },
                  icon: const Icon(Icons.fast_forward_rounded),
                  label: const Text('Read 10 Pages'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Plan Details
        ElegantCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          child: Column(
            children: [
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCreation(
    BuildContext context,
    QuranPlanProvider provider,
    bool isDark,
    ThemeData theme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.book_rounded,
          size: 80,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 24),
        Text(
          'Start Your Khatam Journey',
          style: AppTypography.heading2(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Create a personalized reading plan to complete the Holy Quran during Ramadan.',
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
            Expanded(
              child: _buildDurationOption(15, theme, isDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDurationOption(20, theme, isDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDurationOption(30, theme, isDark),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              final ramadanProvider = context.read<RamadanProvider>();
              final startDate = ramadanProvider.settings.ramadanStartDate ?? DateTime.now();
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
            ),
            child: const Text(
              'Create Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationOption(int days, ThemeData theme, bool isDark) {
    final isSelected = _selectedDays == days;
    final pagesPerDay = (604 / days).ceil();
    
    return InkWell(
      onTap: () => setState(() => _selectedDays = days),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? AppColors.dividerDark : AppColors.divider),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
            Text(
              'Days',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white.withOpacity(0.9) : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '~$pagesPerDay pgs/day',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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

  void _showDeleteConfirmation(BuildContext context, QuranPlanProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
