import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en');

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('traqa_lang', languageCode);
    state = languageCode;
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('traqa_lang') ?? 'en';
  }
}