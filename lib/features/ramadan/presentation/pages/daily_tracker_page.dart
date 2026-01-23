import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/daily_tracker_provider.dart';
import '../../../../core/providers/ramadan_provider.dart';
import '../../../../core/models/daily_tracker_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Daily tracker page for Ramadan activities
class DailyTrackerPage extends StatefulWidget {
  const DailyTrackerPage({super.key});

  @override
  State<DailyTrackerPage> createState() => _DailyTrackerPageState();
}

class _DailyTrackerPageState extends State<DailyTrackerPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ramadanProvider = context.watch<RamadanProvider>();
    final trackerProvider = context.watch<DailyTrackerProvider>();
    
    final todayData = trackerProvider.getDataForDate(_selectedDate);
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => _showStatsDialog(context, ramadanProvider, trackerProvider, isDark),
            tooltip: 'View Statistics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          _buildDateSelector(isDark, theme),
          
          // Main Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Progress Card
                _buildProgressCard(todayData, isDark, theme),
                
                const SizedBox(height: 16),
                
                // Fasting Card
                _buildFastingCard(todayData, trackerProvider, isDark, theme, isToday),
                
                const SizedBox(height: 16),
                
                // Prayers Card
                _buildPrayersCard(todayData, trackerProvider, isDark, theme, isToday),
                
                const SizedBox(height: 16),
                
                // Taraweeh Card
                _buildTaraweehCard(todayData, trackerProvider, isDark, theme, isToday),
                
                const SizedBox(height: 16),
                
                // Quran Card
                _buildQuranCard(todayData, trackerProvider, isDark, theme, isToday),
                
                const SizedBox(height: 16),
                
                // Sadaqah Card
                _buildSadaqahCard(todayData, trackerProvider, isDark, theme, isToday),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE').format(_selectedDate),
                    style: AppTypography.bodyMedium(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM d, y').format(_selectedDate),
                    style: AppTypography.heading4(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _selectedDate.isBefore(DateTime.now())
                ? () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(DailyTrackerData data, bool isDark, ThemeData theme) {
    final percentage = data.completionPercentage;
    
    return ElegantCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: AppTypography.heading4(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getProgressColor(percentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(percentage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.warmBeige,
              valueColor: AlwaysStoppedAnimation(_getProgressColor(percentage)),
            ),
          ),
          if (percentage == 100) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration_rounded, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Alhamdulillah! Day Complete!',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFastingCard(
    DailyTrackerData data,
    DailyTrackerProvider provider,
    bool isDark,
    ThemeData theme,
    bool isToday,
  ) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.fasting
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.fasting ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: data.fasting ? theme.colorScheme.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fasting',
                  style: AppTypography.heading4(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  data.fasting ? 'Completed' : 'Not marked',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: data.fasting,
            activeColor: theme.colorScheme.primary,
            onChanged: isToday ? (value) => provider.toggleFasting(_selectedDate) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayersCard(
    DailyTrackerData data,
    DailyTrackerProvider provider,
    bool isDark,
    ThemeData theme,
    bool isToday,
  ) {
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final prayerNames = {
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    };

    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prayers',
                style: AppTypography.heading4(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Text(
                '${data.completedPrayers}/5',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: data.allPrayersCompleted ? AppColors.success : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prayers.map((prayer) {
              final completed = data.prayers[prayer] ?? false;
              return InkWell(
                onTap: isToday ? () => provider.togglePrayer(_selectedDate, prayer) : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: completed
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: completed ? theme.colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        completed ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: completed ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        prayerNames[prayer]!,
                        style: TextStyle(
                          color: completed ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaraweehCard(
    DailyTrackerData data,
    DailyTrackerProvider provider,
    bool isDark,
    ThemeData theme,
    bool isToday,
  ) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.taraweeh
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.taraweeh ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: data.taraweeh ? theme.colorScheme.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taraweeh',
                  style: AppTypography.heading4(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  data.taraweeh ? 'Prayed' : 'Not marked',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: data.taraweeh,
            activeColor: theme.colorScheme.primary,
            onChanged: isToday ? (value) => provider.toggleTaraweeh(_selectedDate) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuranCard(
    DailyTrackerData data,
    DailyTrackerProvider provider,
    bool isDark,
    ThemeData theme,
    bool isToday,
  ) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quran Reading',
                style: AppTypography.heading4(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Text(
                '${data.quranPages} pages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: theme.colorScheme.primary,
                onPressed: isToday && data.quranPages > 0
                    ? () => provider.updateQuranPages(_selectedDate, data.quranPages - 1)
                    : null,
              ),
              Expanded(
                child: Slider(
                  value: data.quranPages.toDouble(),
                  min: 0,
                  max: 20,
                  divisions: 20,
                  activeColor: theme.colorScheme.primary,
                  label: '${data.quranPages}',
                  onChanged: isToday
                      ? (value) => provider.updateQuranPages(_selectedDate, value.toInt())
                      : null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: theme.colorScheme.primary,
                onPressed: isToday && data.quranPages < 20
                    ? () => provider.updateQuranPages(_selectedDate, data.quranPages + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSadaqahCard(
    DailyTrackerData data,
    DailyTrackerProvider provider,
    bool isDark,
    ThemeData theme,
    bool isToday,
  ) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.sadaqah
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.sadaqah ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: data.sadaqah ? theme.colorScheme.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sadaqah (Charity)',
                  style: AppTypography.heading4(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  data.sadaqah ? 'Given today' : 'Not marked',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: data.sadaqah,
            activeColor: theme.colorScheme.primary,
            onChanged: isToday ? (value) => provider.toggleSadaqah(_selectedDate) : null,
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showStatsDialog(
    BuildContext context,
    RamadanProvider ramadanProvider,
    DailyTrackerProvider trackerProvider,
    bool isDark,
  ) {
    if (!ramadanProvider.isRamadan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statistics available during Ramadan')),
      );
      return;
    }

    final startDate = ramadanProvider.settings.ramadanStartDate;
    if (startDate == null) return;

    final endDate = startDate.add(const Duration(days: 29));
    final stats = trackerProvider.getStats(
      startDate: startDate,
      endDate: endDate,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ramadan Statistics',
                      style: AppTypography.heading3(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Streak Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '🔥',
                      '${stats.currentStreak}',
                      'Current Streak',
                      AppColors.warning,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '⭐',
                      '${stats.longestStreak}',
                      'Longest Streak',
                      theme.colorScheme.primary,
                      isDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress Stats
              _buildProgressStat(
                'Fasting',
                stats.fastingDays,
                stats.totalDays,
                stats.fastingPercentage,
                Icons.restaurant_rounded,
                theme.colorScheme.primary,
                isDark,
              ),
              
              const SizedBox(height: 12),
              
              _buildProgressStat(
                'Prayers',
                stats.completedPrayers,
                stats.totalPrayers,
                stats.prayerPercentage,
                Icons.mosque_rounded,
                AppColors.success,
                isDark,
              ),
              
              const SizedBox(height: 12),
              
              _buildProgressStat(
                'Taraweeh',
                stats.taraweehDays,
                stats.totalDays,
                stats.taraweehPercentage,
                Icons.nightlight_round_rounded,
                AppColors.mutedTeal,
                isDark,
              ),
              
              const SizedBox(height: 12),
              
              // Quran & Sadaqah
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '📖',
                      '${stats.totalQuranPages}',
                      'Quran Pages',
                      theme.colorScheme.primary,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '💝',
                      '${stats.sadaqahDays}',
                      'Charity Days',
                      AppColors.success,
                      isDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Completion Rate
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      AppColors.mutedTeal.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${stats.completedDays} of ${stats.totalDays} days completed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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

  Widget _buildStatCard(
    String emoji,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
    String label,
    int completed,
    int total,
    double percentage,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.warmBeige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTypography.bodyMedium(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '$completed/$total',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

