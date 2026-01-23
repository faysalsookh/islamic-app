import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/ramadan_provider.dart';
import '../../../../core/models/ramadan_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Full Ramadan calendar showing all 30 days with Sehri/Iftar times
class RamadanCalendarPage extends StatefulWidget {
  const RamadanCalendarPage({super.key});

  @override
  State<RamadanCalendarPage> createState() => _RamadanCalendarPageState();
}

class _RamadanCalendarPageState extends State<RamadanCalendarPage> {
  @override
  void initState() {
    super.initState();
    // Load Ramadan calendar if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RamadanProvider>();
      if (provider.ramadanCalendar.isEmpty && provider.ramadanStartDate != null) {
        provider.setRamadanStartDate(provider.ramadanStartDate!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramadan Calendar'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/daily-tracker');
            },
            tooltip: 'Daily Tracker',
          ),
          IconButton(
            icon: const Icon(Icons.auto_stories_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/quran-planner');
            },
            tooltip: 'Khatam Planner',
          ),
          IconButton(
            icon: const Icon(Icons.calculate_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/zakat-calculator');
            },
            tooltip: 'Zakat Calculator',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/ramadan-settings');
            },
            tooltip: 'Ramadan Settings',
          ),
        ],
      ),
      body: Consumer<RamadanProvider>(
        builder: (context, ramadanProvider, child) {
          if (ramadanProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!ramadanProvider.isRamadan) {
            return _buildNotRamadanView(isDark);
          }

          if (ramadanProvider.ramadanCalendar.isEmpty) {
            return _buildEmptyView(isDark);
          }

          final calendar = ramadanProvider.ramadanCalendar;
          final currentDay = ramadanProvider.currentRamadanDay;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: calendar.length,
                  itemBuilder: (context, index) {
                    final dayNumber = index + 1;
                    final prayerTimes = calendar[index];
                    final isToday = dayNumber == currentDay;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDayCard(
                        dayNumber: dayNumber,
                        prayerTimes: prayerTimes,
                        isToday: isToday,
                        isDark: isDark,
                        theme: theme,
                        use24HourFormat: ramadanProvider.settings.use24HourFormat,
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: isDark ? AppColors.darkCard : theme.colorScheme.primary.withOpacity(0.05),
                child: Text(
                  'Calculation: ${CalculationMethods.getDisplayName(ramadanProvider.settings.calculationMethod)} | Madhab: ${ramadanProvider.settings.madhab.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<RamadanProvider>(
        builder: (context, ramadanProvider, child) {
          if (!ramadanProvider.isRamadan) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/ramadan-duas');
            },
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Duas'),
            backgroundColor: theme.colorScheme.primary,
          );
        },
      ),
    );
  }

  Widget _buildDayCard({
    required int dayNumber,
    required prayerTimes,
    required bool isToday,
    required bool isDark,
    required ThemeData theme,
    required bool use24HourFormat,
  }) {
    final timeFormat = use24HourFormat ? DateFormat('HH:mm') : DateFormat('h:mm a');
    final sehriTime = timeFormat.format(prayerTimes.fajr);
    final iftarTime = timeFormat.format(prayerTimes.maghrib);
    final dateStr = DateFormat('EEEE, MMM d').format(prayerTimes.date);

    return ElegantCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: isToday
          ? (isDark 
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.primary.withOpacity(0.08))
          : (isDark ? AppColors.darkCard : Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $dayNumber',
                        style: AppTypography.heading3(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dateStr,
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
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Times
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Sehri ends',
                  time: sehriTime,
                  color: const Color(0xFF4A90E2),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeInfo(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Iftar',
                  time: iftarTime,
                  color: const Color(0xFFE8796C),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotRamadanView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 80,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'Ramadan Calendar',
              style: AppTypography.heading2(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The Ramadan calendar will be available when Ramadan begins.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge(
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

  Widget _buildEmptyView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 80,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'Location Required',
              style: AppTypography.heading2(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please enable location services to view accurate prayer times for your area.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge(
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
