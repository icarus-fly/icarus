import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class EnhancedTraqaApp extends StatelessWidget {
  const EnhancedTraqaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traqa Health',
      theme: _buildAppTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.dark,
      home: const EnhancedHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA5),
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1F2C),
        surfaceContainer: const Color(0xFF2A303C),
        surfaceContainerHigh: const Color(0xFF363B48),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1F2C),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF2A303C),
      ),
      useMaterial3: true,
    );
  }
}

class EnhancedHomeScreen extends StatelessWidget {
  const EnhancedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // App Logo with Animation
              _buildAppLogo(),

              const SizedBox(height: 32),

              // App Title
              _buildAppTitle(),

              const SizedBox(height: 16),

              // Tagline
              _buildTagline(),

              const SizedBox(height: 48),

              // Feature Grid
              _buildFeatureGrid(),

              const SizedBox(height: 48),

              // CTA Section
              _buildCTASection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BFA5), Color(0xFF009688)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.health_and_safety,
        size: 64,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAppTitle() {
    return Text(
      'Traqa Health',
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.1,
        fontFamily: 'SpaceGrotesk',
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTagline() {
    return Text(
      'Medical reports made simple for Indian families',
      style: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.grey[400],
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.9,
      children: const [
        _EnhancedFeatureCard(
          icon: Icons.upload_file,
          title: 'Upload Reports',
          description: 'Upload medical documents with ease',
          gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        _EnhancedFeatureCard(
          icon: Icons.translate,
          title: 'Simplify Language',
          description: 'AI-powered medical term translation',
          gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
        ),
        _EnhancedFeatureCard(
          icon: Icons.family_restroom,
          title: 'Family Health',
          description: 'Manage your family\'s health together',
          gradient: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
        ),
        _EnhancedFeatureCard(
          icon: Icons.timeline,
          title: 'Track Progress',
          description: 'Monitor health improvements over time',
          gradient: [Color(0xFFFF9966), Color(0xFFFF5E62)],
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ready to simplify healthcare for your family?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[300],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: Text(
            'Get Started',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {},
          child: Text(
            'Learn More →',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: const Color(0xFF00BFA5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EnhancedFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _EnhancedFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'SpaceGrotesk',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'SpaceGrotesk',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}