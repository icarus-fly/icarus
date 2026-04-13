import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TraqaTheme {
  // ── Color Palette ─────────────────────────────────────────────────────────
  static const Color bgDeep      = Color(0xFF050D09);   // near-black deep green
  static const Color bgSurface   = Color(0xFF0D1F14);   // dark surface
  static const Color bgCard      = Color(0xFF122018);   // card background
  static const Color bgCardAlt   = Color(0xFF0F1A14);   // alt card

  static const Color neonMint    = Color(0xFF00FF9F);   // primary accent (logo color)
  static const Color neonBlue    = Color(0xFF00C8FF);   // secondary accent
  static const Color neonAmber   = Color(0xFFFFC107);   // warnings / streaks
  static const Color neonRose    = Color(0xFFFF6B9D);   // family / care
  static const Color neonViolet  = Color(0xFFB388FF);   // premium features

  static const Color textPrimary  = Color(0xFFE8F5EE);  // near-white
  static const Color textSecond   = Color(0xFF8BA898);  // muted
  static const Color textTertiary = Color(0xFF4A6358);  // very muted
  static const Color textInverse  = Color(0xFF050D09);  // on neon backgrounds

  static const Color success  = Color(0xFF00FF9F);
  static const Color warning  = Color(0xFFFFC107);
  static const Color danger   = Color(0xFFFF4757);
  static const Color info     = Color(0xFF00C8FF);

  // ── Border colors ──────────────────────────────────────────────────────────
  static const Color borderFaint  = Color(0xFF1A3028);
  static const Color borderMid    = Color(0xFF234836);
  static const Color borderGlow   = Color(0xFF00FF9F);  // use at 30% opacity

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: neonMint,
        secondary: neonBlue,
        surface: bgSurface,
        error: danger,
        onPrimary: textInverse,
        onSecondary: textInverse,
        onSurface: textPrimary,
      ),

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: TextTheme(
        // Display — Playfair Display for emotional moments
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 36, fontWeight: FontWeight.w600, color: textPrimary,
        ),

        // Headlines — Space Grotesk for UI headings (futuristic, technical feel)
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),

        // Body — IBM Plex Sans (readable, technical, Indian tech scene uses it)
        bodyLarge: GoogleFonts.ibmPlexSans(
          fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.ibmPlexSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary,
          height: 1.6,
        ),
        bodySmall: GoogleFonts.ibmPlexSans(
          fontSize: 12, fontWeight: FontWeight.w400, color: textSecond,
          height: 1.5,
        ),

        // Labels — IBM Plex Mono for values, numbers, medical data
        labelLarge: GoogleFonts.ibmPlexMono(
          fontSize: 14, fontWeight: FontWeight.w500, color: neonMint,
          letterSpacing: 0.05,
        ),
        labelMedium: GoogleFonts.ibmPlexMono(
          fontSize: 12, fontWeight: FontWeight.w400, color: neonMint,
        ),
        labelSmall: GoogleFonts.ibmPlexMono(
          fontSize: 10, fontWeight: FontWeight.w400, color: textSecond,
          letterSpacing: 0.1,
        ),
      ),

      // ── Components ────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderFaint, width: 0.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonMint,
          foregroundColor: textInverse,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonMint,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: neonMint, width: 1),
          textStyle: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderFaint, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderFaint, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonMint, width: 1.5),
        ),
        hintStyle: GoogleFonts.ibmPlexSans(color: textTertiary, fontSize: 14),
        labelStyle: GoogleFonts.ibmPlexSans(color: textSecond, fontSize: 14),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgSurface,
        selectedItemColor: neonMint,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: const DividerThemeData(
        color: borderFaint, thickness: 0.5, space: 0,
      ),

      iconTheme: const IconThemeData(color: textSecond, size: 24),
      primaryIconTheme: const IconThemeData(color: neonMint, size: 24),
    );
  }
}