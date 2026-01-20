import 'package:flutter/material.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../../core/utils/responsive.dart';
import '../../home/presentation/widgets/surah_list_section.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Surahs'),
        centerTitle: true,
      ),
      body: IslamicPatternBackground(
        patternColor: theme.colorScheme.primary,
        opacity: 0.03,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 16),
              itemCount: SurahData.surahs.length,
              itemBuilder: (context, index) {
                final surah = SurahData.surahs[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isTablet ? 6 : 4),
                  child: SurahListTile(surah: surah),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
