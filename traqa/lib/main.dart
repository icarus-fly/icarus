import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TraqaApp());
}

class TraqaApp extends StatelessWidget {
  const TraqaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traqa — Conceptual Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD9FF00), // Volt green
          secondary: Color(0xFFD9FF00),
          surface: Color(0xFF161616),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.anton(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD9FF00),
            letterSpacing: 2.0,
          ),
          titleLarge: GoogleFonts.lexend(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.lexend(
            fontSize: 14,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ),
      home: const ShowcaseScreen(),
    );
  }
}

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Header
                  Center(
                    child: Text(
                      'TRAQA',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your family's health, in words you understand.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Info Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0x4CD9FF00),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFFD9FF00),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Public Showcase Repository',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 16,
                                    color: const Color(0xFFD9FF00),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This repository is a visual and design system presentation for the Traqa project. All proprietary components, services, models, and features reside in the private companion repository.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Core Concept Highlights
                  Text(
                    'CORE CAPABILITIES',
                    style: GoogleFonts.anton(
                      fontSize: 20,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConceptTile(
                    context,
                    icon: Icons.g_translate_outlined,
                    title: '13 Indian Languages Support',
                    description:
                        'Breaking language barriers by displaying medical definitions in regional Indian languages including Hindi, Tamil, Telugu, and more.',
                  ),
                  const SizedBox(height: 16),
                  _buildConceptTile(
                    context,
                    icon: Icons.psychology_outlined,
                    title: 'AI-Powered Simplification',
                    description:
                        'Translating complex lab parameters and medical jargon into direct, actionable explanations for families.',
                  ),
                  const SizedBox(height: 16),
                  _buildConceptTile(
                    context,
                    icon: Icons.people_outline,
                    title: 'Family Health Circle',
                    description:
                        'Enabling shared health monitoring and consent-based updates among multiple family members in a single dashboard.',
                  ),
                  const SizedBox(height: 48),

                  // Footer Info
                  Text(
                    '© 2026 Traqa. All Rights Reserved.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConceptTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFD9FF00), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
