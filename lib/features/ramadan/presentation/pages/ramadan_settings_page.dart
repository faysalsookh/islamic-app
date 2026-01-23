import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/ramadan_provider.dart';
import '../../../../core/models/ramadan_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Comprehensive Ramadan settings page
class RamadanSettingsPage extends StatefulWidget {
  const RamadanSettingsPage({super.key});

  @override
  State<RamadanSettingsPage> createState() => _RamadanSettingsPageState();
}

class _RamadanSettingsPageState extends State<RamadanSettingsPage> {
  late RamadanSettings _settings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _settings = context.read<RamadanProvider>().settings;
  }

  void _updateSettings(RamadanSettings newSettings) {
    setState(() {
      _settings = newSettings;
      _hasChanges = true;
    });
  }

  Future<void> _saveSettings() async {
    final provider = context.read<RamadanProvider>();
    await provider.updateSettings(_settings);
    
    if (mounted) {
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramadan Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSettings,
              child: Text(
                'Save',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ramadan Dates Section
          _buildSectionHeader('Ramadan Dates', Icons.calendar_month_rounded, isDark),
          const SizedBox(height: 12),
          _buildDateSettings(isDark, theme),
          
          const SizedBox(height: 24),
          
          // Prayer Calculation Section
          _buildSectionHeader('Prayer Calculation', Icons.mosque_rounded, isDark),
          const SizedBox(height: 12),
          _buildPrayerCalculationSettings(isDark, theme),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildSectionHeader('Notifications', Icons.notifications_rounded, isDark),
          const SizedBox(height: 12),
          _buildNotificationSettings(isDark, theme),
          
          const SizedBox(height: 24),
          
          // Display Settings Section
          _buildSectionHeader('Display', Icons.display_settings_rounded, isDark),
          const SizedBox(height: 12),
          _buildDisplaySettings(isDark, theme),
          
          const SizedBox(height: 24),
          
          // Features Section
          _buildSectionHeader('Features', Icons.star_rounded, isDark),
          const SizedBox(height: 12),
          _buildFeatureSettings(isDark, theme),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.heading4(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSettings(bool isDark, ThemeData theme) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Ramadan Start Date',
              style: AppTypography.bodyLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              _settings.ramadanStartDate != null
                  ? DateFormat('EEEE, MMMM d, y').format(_settings.ramadanStartDate!)
                  : 'Not set',
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            trailing: Icon(
              Icons.edit_calendar_rounded,
              color: theme.colorScheme.primary,
            ),
            onTap: () => _selectRamadanDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCalculationSettings(bool isDark, ThemeData theme) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calculation Method
          Text(
            'Calculation Method',
            style: AppTypography.bodyLarge(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.warmBeige,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _settings.calculationMethod,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(12),
                items: CalculationMethods.methods.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: AppTypography.bodyMedium(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateSettings(_settings.copyWith(calculationMethod: value));
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Madhab
          Text(
            'Madhab (School of Thought)',
            style: AppTypography.bodyLarge(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  'Hanafi',
                  'hanafi',
                  _settings.madhab,
                  (value) => _updateSettings(_settings.copyWith(madhab: value)),
                  isDark,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  'Shafi',
                  'shafi',
                  _settings.madhab,
                  (value) => _updateSettings(_settings.copyWith(madhab: value)),
                  isDark,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(bool isDark, ThemeData theme) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        children: [
          // Sehri Notification
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Sehri Alarm',
              style: AppTypography.bodyLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Remind before Fajr time',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            value: _settings.sehriNotificationEnabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(sehriNotificationEnabled: value));
            },
          ),
          
          if (_settings.sehriNotificationEnabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.warmBeige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remind me',
                        style: AppTypography.bodyMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_settings.sehriNotificationMinutes} minutes before',
                        style: AppTypography.bodyMedium(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _settings.sehriNotificationMinutes.toDouble(),
                    min: 15,
                    max: 60,
                    divisions: 9,
                    activeColor: theme.colorScheme.primary,
                    label: '${_settings.sehriNotificationMinutes} min',
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(sehriNotificationMinutes: value.toInt()));
                    },
                  ),
                ],
              ),
            ),
          ],
          
          const Divider(height: 32),
          
          // Iftar Notification
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Iftar Alert',
              style: AppTypography.bodyLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Notify at Maghrib time',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            value: _settings.iftarNotificationEnabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(iftarNotificationEnabled: value));
            },
          ),
          
          const Divider(height: 32),
          
          // Taraweeh Reminder
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Taraweeh Reminder',
              style: AppTypography.bodyLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Remind after Isha prayer',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            value: _settings.taraweehReminderEnabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(taraweehReminderEnabled: value));
            },
          ),
          
          const Divider(height: 32),
          
          // Test Notification Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final provider = context.read<RamadanProvider>();
                
                // Request permissions first
                final hasPermission = await provider.requestNotificationPermissions();
                
                if (!hasPermission) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enable notifications in settings'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  }
                  return;
                }
                
                // Show test notification
                await provider.showTestNotification();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification sent!'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Test Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(bool isDark, ThemeData theme) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '24-Hour Time Format',
              style: AppTypography.bodyLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              _settings.use24HourFormat ? '18:30' : '6:30 PM',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            value: _settings.use24HourFormat,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(use24HourFormat: value));
            },
          ),
          
          const Divider(height: 32),
          
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Always Show Countdown',
              style: AppTypography.bodyLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Show countdown even outside Ramadan',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            value: _settings.alwaysShowCountdown,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(alwaysShowCountdown: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSettings(bool isDark, ThemeData theme) {
    return ElegantCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Daily Tracker',
              style: AppTypography.bodyLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Track prayers, fasting, and Quran reading',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            value: _settings.dailyTrackerEnabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(dailyTrackerEnabled: value));
            },
          ),
          
          const Divider(height: 32),
          
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Quran Reading Planner',
              style: AppTypography.bodyLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Plan to complete Quran in Ramadan',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            value: _settings.quranPlannerEnabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(quranPlannerEnabled: value));
            },
          ),
          
          if (_settings.quranPlannerEnabled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.warmBeige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading Goal',
                    style: AppTypography.bodyMedium(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGoalOption(15, isDark, theme),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGoalOption(20, isDark, theme),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGoalOption(30, isDark, theme),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRadioOption(
    String label,
    String value,
    String groupValue,
    Function(String) onChanged,
    bool isDark,
    ThemeData theme,
  ) {
    final isSelected = value == groupValue;
    
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyMedium(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(int days, bool isDark, ThemeData theme) {
    final isSelected = _settings.quranReadingGoalDays == days;
    
    return InkWell(
      onTap: () => _updateSettings(_settings.copyWith(quranReadingGoalDays: days)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? AppColors.dividerDark : AppColors.divider),
          ),
        ),
        child: Column(
          children: [
            Text(
              '$days',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
            Text(
              'days',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectRamadanDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _settings.ramadanStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _updateSettings(_settings.copyWith(ramadanStartDate: picked));
    }
  }
}
