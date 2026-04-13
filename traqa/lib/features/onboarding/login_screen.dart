import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/theme.dart';
import '../../shared/widgets/traqa_logo.dart';
import '../../shared/widgets/futuristic_bg.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/language_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final auth = ref.read(authProvider);

    return Scaffold(
      body: FuturisticBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 1.05),
                    duration: const Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Column(
                      children: [
                        const TraqaLogo(size: 120),
                        const SizedBox(height: 16),
                        // TRAQA wordmark
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [TraqaTheme.neonMint, TraqaTheme.neonBlue],
                          ).createShader(bounds),
                          child: Text('TRAQA', style: GoogleFonts.spaceGrotesk(
                            fontSize: 42, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: 8,
                          )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get(lang, 'tagline'),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16, color: TraqaTheme.textSecond,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),

                  // Google Sign-In button
                  GestureDetector(
                    onTap: () async {
                      try {
                        await auth.signInWithGoogle();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $e')),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TraqaTheme.borderFaint),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/logo/google.svg', height: 24),
                          const SizedBox(width: 12),
                          Text(
                            AppStrings.get(lang, 'signInGoogle'),
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 16, fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F1F1F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    '🔒 Your reports are private and never shared',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12, color: TraqaTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}