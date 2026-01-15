import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';

/// Greeting header with user name and Islamic greeting
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final userName = appState.userName.isNotEmpty
            ? appState.userName
            : 'Dear Reader';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic greeting
                  Text(
                    'السَّلَامُ عَلَيْكُمْ',
                    textDirection: TextDirection.rtl,
                    style: AppTypography.arabicGreeting(
                      color: isDark
                          ? AppColors.softRose
                          : AppColors.forestGreen,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // English greeting with name
                  Row(
                    children: [
                      Text(
                        '${_getGreeting()}, ',
                        style: AppTypography.bodyLarge(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          userName,
                          style: AppTypography.heading2(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Settings/Profile icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkCard
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                icon: Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
