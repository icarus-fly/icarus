import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/language_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'tabHistory')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'History Screen - Coming Soon',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 18,
            color: TraqaTheme.textSecond,
          ),
        ),
      ),
    );
  }
}