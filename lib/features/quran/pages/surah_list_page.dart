import 'package:flutter/material.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../home/presentation/widgets/surah_list_section.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Surahs'),
        centerTitle: true,
      ),
      body: IslamicPatternBackground(
        patternColor: theme.colorScheme.primary,
        opacity: 0.03,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: SurahData.surahs.length,
          itemBuilder: (context, index) {
            final surah = SurahData.surahs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SurahListTile(surah: surah),
            );
          },
        ),
      ),
    );
  }
}
