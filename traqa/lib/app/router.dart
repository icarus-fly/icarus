import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/onboarding/language_picker_screen.dart';
import '../features/onboarding/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/history/history_screen.dart';
import '../features/family/family_screen.dart';
import '../features/streak/streak_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/report/upload_screen.dart';
import '../features/report/report_type_screen.dart';
import '../features/report/output_language_screen.dart';
import '../features/report/result_screen.dart';
import '../core/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/language',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final hasLanguage = prefs.getString('traqa_lang') != null;
      final isLoggedIn = authState.value != null;

      if (!hasLanguage) return '/language';
      if (!isLoggedIn && state.matchedLocation != '/login') return '/login';
      if (isLoggedIn && state.matchedLocation == '/login') return '/history';
      return null;
    },
    routes: [
      GoRoute(path: '/language', builder: (_, __) => const LanguagePickerScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          GoRoute(path: '/family', builder: (_, __) => const FamilyScreen()),
          GoRoute(path: '/streak', builder: (_, __) => const StreakScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/upload', builder: (_, __) => const UploadScreen()),
      GoRoute(path: '/report-type', builder: (_, __) => const ReportTypeScreen()),
      GoRoute(path: '/output-language', builder: (_, __) => const OutputLanguageScreen()),
      GoRoute(
        path: '/result/:reportId',
        builder: (context, state) => ResultScreen(
          reportId: state.pathParameters['reportId']!,
        ),
      ),
    ],
  );
});