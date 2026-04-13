import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_tts/flutter_tts.dart';

class OutputLanguageScreen extends ConsumerStatefulWidget {
  const OutputLanguageScreen({super.key});

  @override
  ConsumerState<OutputLanguageScreen> createState() => _OutputLanguageScreenState();
}

class _OutputLanguageScreenState extends ConsumerState<OutputLanguageScreen> {
  String _selectedLanguage = 'en';
  bool _isProcessing = false;
  final FlutterTts _tts = FlutterTts();

  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'native': 'English'},
    'hi': {'name': 'Hindi', 'native': 'हिंदी'},
    'ta': {'name': 'Tamil', 'native': 'தமிழ்'},
    'bn': {'name': 'Bengali', 'native': 'বাংলা'},
    'te': {'name': 'Telugu', 'native': 'తెలుగు'},
    'mr': {'name': 'Marathi', 'native': 'मराठी'},
    'gu': {'name': 'Gujarati', 'native': 'ગુજરાતી'},
    'kn': {'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    'ml': {'name': 'Malayalam', 'native': 'മലയാളം'},
    'pa': {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
  };

  Future<void> _testTTS(String languageCode) async {
    final testTexts = {
      'en': 'Hello, this is a test message',
      'hi': 'नमस्ते, यह एक परीक्षण संदेश है',
      'ta': 'வணக்கம், இது ஒரு சோதனை செய்தி',
      'bn': 'হ্যালো, এটি একটি পরীক্ষামূলক বার্তা',
      'te': 'హలో, ఇది ఒక పరీక్ష సందేశం',
      'mr': 'नमस्कार, हा एक चाचणी संदेश आहे',
      'gu': 'હેલો, આ એક પરીક્ષણ સંદેશ છે',
      'kn': 'ನಮಸ್ಕಾರ, ಇದು ಒಂದು ಪರೀಕ್ಷಾ ಸಂದೇಶ',
      'ml': 'ഹലോ, ഇതൊരു പരീക്ഷണ സന്ദേശമാണ്',
      'pa': 'ਹੈਲੋ, ਇਹ ਇੱਕ ਟੈਸਟ ਸੰਦੇਸ਼ ਹੈ',
    };

    await _tts.setLanguage(languageCode);
    await _tts.speak(testTexts[languageCode] ?? testTexts['en']!);
  }

  Future<void> _analyzeReport() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      final images = routeArgs['images'] as List<XFile>? ?? [];
      final pdf = routeArgs['pdf'] as PlatformFile?;
      final reportType = routeArgs['reportType'] as String? ?? 'other';

      // Convert images to base64
      final List<String> imageBase64Array = [];
      for (final image in images) {
        final bytes = await image.readAsBytes();
        imageBase64Array.add(base64Encode(bytes));
      }

      // Convert PDF to base64 if exists
      String? pdfBase64;
      if (pdf != null) {
        final bytes = pdf.bytes!;
        pdfBase64 = base64Encode(bytes);
      }

      // Get current user and family context
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get selected family member if any
      String? memberId;
      String? memberName;
      // TODO: Implement family member selection logic

      // Call Cloud Function
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('analyzeReport');

      final result = await callable.call(<String, dynamic>{
        'imageBase64Array': imageBase64Array,
        'pdfBase64': pdfBase64,
        'reportType': reportType,
        'outputLanguage': _selectedLanguage,
        'memberId': memberId,
        'memberName': memberName,
      });

      final reportId = result.data['reportId'] as String;

      // Navigate to result screen
      Navigator.pushReplacementNamed(
        context,
        '/result/$reportId',
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Language'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language Selection Header
            Text(
              'In which language should we explain?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the language your family understands best',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Language Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final langCode = _languages.keys.elementAt(index);
                  final langData = _languages[langCode]!;
                  final isSelected = _selectedLanguage == langCode;

                  return _LanguageCard(
                    code: langCode,
                    name: langData['name']!,
                    native: langData['native']!,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = langCode;
                      });
                    },
                    onTestTTS: () => _testTTS(langCode),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Analyze Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _analyzeReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Analyze with AI',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String code;
  final String name;
  final String native;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onTestTTS;

  const _LanguageCard({
    required this.code,
    required this.name,
    required this.native,
    required this.isSelected,
    required this.onTap,
    required this.onTestTTS,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Theme.of(context).colorScheme.surface,
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                native,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(
                  Icons.volume_up,
                  size: 16,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                onPressed: onTestTTS,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      ),
    );
  }
}