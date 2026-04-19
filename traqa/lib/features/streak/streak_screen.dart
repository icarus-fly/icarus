import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/language_provider.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'tabStreak')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Streak Screen - Coming Soon',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 18,
            color: TraqaTheme.textSecond,
          ),
        ),
      ),
    );
  }
}