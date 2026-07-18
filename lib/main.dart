import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LyricCordApp()));
}

class LyricCordApp extends StatelessWidget {
  const LyricCordApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Phase 0 uses a default Material 3 seed theme. The full violet palette
    // and saved theme mode are wired in Phase 1.
    return MaterialApp(
      title: 'LyricCord',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
