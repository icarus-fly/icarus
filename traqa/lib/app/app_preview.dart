import 'package:flutter/material.dart';
import 'theme.dart';

class TraqaApp extends StatelessWidget {
  const TraqaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traqa',
      theme: TraqaTheme.dark,
      darkTheme: TraqaTheme.dark,
      themeMode: ThemeMode.dark,
      home: const Scaffold(
        body: Center(
          child: Text('Traqa Preview - App is working!'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}