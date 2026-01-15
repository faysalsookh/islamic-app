import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/elegant_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 8),
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Column(
                children: [
                  _SettingsTile(
                    title: 'App Theme',
                    subtitle: _getThemeName(appState.themeMode),
                    icon: Icons.palette_rounded,
                    onTap: () {
                      _showThemeSelector(context);
                    },
                  ),
                  _SettingsTile(
                    title: 'Night Mode',
                    subtitle: 'Protect your eyes',
                    icon: Icons.nightlight_round,
                    trailing: Switch.adaptive(
                      value: appState.themeMode == AppThemeMode.dark,
                      onChanged: (value) {
                         appState.setThemeMode(
                           value ? AppThemeMode.dark : AppThemeMode.light,
                         );
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: 'Reading'),
          const SizedBox(height: 8),
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Column(
                children: [
                   _SettingsTile(
                    title: 'Arabic Font Style',
                    subtitle: 'Amiri (Classic)',
                    icon: Icons.text_fields_rounded,
                    onTap: () {}, // TODO: Implement selection
                  ),
                  _SettingsTile(
                    title: 'Translation Language',
                    subtitle: 'English',
                    icon: Icons.translate_rounded,
                    onTap: () {}, // TODO: Implement selection
                  ),
                  _SettingsTile(
                    title: 'Left-Handed Mode',
                    subtitle: 'Optimize controls for left hand',
                    icon: Icons.pan_tool_rounded,
                    trailing: Switch.adaptive(
                      value: appState.isLeftHanded,
                      onChanged: (value) {
                        appState.setLeftHanded(value);
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: 'Support'),
          const SizedBox(height: 8),
          _SettingsTile(
            title: 'Rate App',
            subtitle: 'Share your feedback',
            icon: Icons.star_outline_rounded,
            onTap: () {},
          ),
          _SettingsTile(
            title: 'Share App',
            subtitle: 'With friends and family',
            icon: Icons.share_rounded,
            onTap: () {},
          ),
          _SettingsTile(
            title: 'About Us',
            subtitle: 'Version 1.0.0',
            icon: Icons.info_outline_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.roseGold:
        return 'Rose Gold';
      case AppThemeMode.oliveCream:
        return 'Olive & Cream';
    }
  }

  void _showThemeSelector(BuildContext context) {
    // Reuse the theme logic from onboarding or create a dialog here
    // For brevity, we'll just toggle through modes cyclically or show a simple dialog
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
       builder: (context) {
         return Container(
           padding: const EdgeInsets.symmetric(vertical: 24),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                Text('Select Theme', style: AppTypography.heading2()),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Light'),
                  onTap: () {
                    appState.setThemeMode(AppThemeMode.light);
                    Navigator.pop(context);
                  },
                  trailing: appState.themeMode == AppThemeMode.light ? const Icon(Icons.check) : null,
                ),
                ListTile(
                  title: const Text('Dark'),
                  onTap: () {
                    appState.setThemeMode(AppThemeMode.dark);
                    Navigator.pop(context);
                  },
                   trailing: appState.themeMode == AppThemeMode.dark ? const Icon(Icons.check) : null,
                ),
                ListTile(
                  title: const Text('Rose Gold'),
                  onTap: () {
                    appState.setThemeMode(AppThemeMode.roseGold);
                    Navigator.pop(context);
                  },
                   trailing: appState.themeMode == AppThemeMode.roseGold ? const Icon(Icons.check) : null,
                ),
                ListTile(
                  title: const Text('Olive & Cream'),
                  onTap: () {
                    appState.setThemeMode(AppThemeMode.oliveCream);
                    Navigator.pop(context);
                  },
                   trailing: appState.themeMode == AppThemeMode.oliveCream ? const Icon(Icons.check) : null,
                ),
             ],
           ),
         );
       }
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.label(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElegantCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading3(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else 
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
