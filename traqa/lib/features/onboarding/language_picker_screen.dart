import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../../shared/widgets/traqa_logo.dart';
import '../../shared/widgets/futuristic_bg.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/language_provider.dart';

class LanguagePickerScreen extends ConsumerStatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  ConsumerState<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends ConsumerState<LanguagePickerScreen> {
  String? selectedLang;

  final languages = [
    {'code': 'hi', 'native': 'हिंदी', 'english': 'Hindi'},
    {'code': 'ta', 'native': 'தமிழ்', 'english': 'Tamil'},
    {'code': 'bn', 'native': 'বাংলা', 'english': 'Bengali'},
    {'code': 'te', 'native': 'తెలుగు', 'english': 'Telugu'},
    {'code': 'mr', 'native': 'मराठी', 'english': 'Marathi'},
    {'code': 'gu', 'native': 'ગુજરાતી', 'english': 'Gujarati'},
    {'code': 'kn', 'native': 'ಕನ್ನಡ', 'english': 'Kannada'},
    {'code': 'ml', 'native': 'മലയാളം', 'english': 'Malayalam'},
    {'code': 'pa', 'native': 'ਪੰਜਾਬੀ', 'english': 'Punjabi'},
    {'code': 'or', 'native': 'ଓଡ଼ିଆ', 'english': 'Odia'},
    {'code': 'as', 'native': 'অসমীয়া', 'english': 'Assamese'},
    {'code': 'ur', 'native': 'اردو', 'english': 'Urdu'},
    {'code': 'en', 'native': 'English', 'english': 'English'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FuturisticBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Logo
              const TraqaLogo(size: 80),
              const SizedBox(height: 8),
              // App name
              Text('TRAQA', style: GoogleFonts.spaceGrotesk(
                fontSize: 28, fontWeight: FontWeight.w700,
                color: TraqaTheme.neonMint, letterSpacing: 6,
              )),
              const SizedBox(height: 24),
              // Heading
              Text('Apni bhasha chuniye', style: GoogleFonts.playfairDisplay(
                fontSize: 22, fontWeight: FontWeight.w600,
                color: TraqaTheme.textPrimary,
              )),
              Text('Choose your language', style: GoogleFonts.ibmPlexSans(
                fontSize: 14, color: TraqaTheme.textSecond,
              )),
              const SizedBox(height: 24),
              // Language grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = selectedLang == lang['code'];
                    return GestureDetector(
                      onTap: () => setState(() => selectedLang = lang['code']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                            ? TraqaTheme.neonMint.withOpacity(0.15)
                            : TraqaTheme.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                              ? TraqaTheme.neonMint
                              : TraqaTheme.borderFaint,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lang['native']!, style: GoogleFonts.notoSans(
                              fontSize: 18, fontWeight: FontWeight.w600,
                              color: isSelected
                                ? TraqaTheme.neonMint
                                : TraqaTheme.textPrimary,
                            )),
                            const SizedBox(height: 2),
                            Text(lang['english']!, style: GoogleFonts.ibmPlexSans(
                              fontSize: 11, color: TraqaTheme.textSecond,
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Continue button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: selectedLang == null ? null : () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('traqa_lang', selectedLang!);
                    ref.read(languageProvider.notifier).setLanguage(selectedLang!);
                    if (context.mounted) context.go('/login');
                  },
                  child: Text(selectedLang == null
                    ? 'Select a language'
                    : 'Continue →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}