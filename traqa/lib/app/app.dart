import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import 'theme.dart';

class TraqaApp extends ConsumerWidget {
  const TraqaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Traqa',
      theme: TraqaTheme.dark,
      darkTheme: TraqaTheme.dark,
      themeMode: ThemeMode.dark,    // Always dark
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}